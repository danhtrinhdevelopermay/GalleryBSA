import express, { type Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import multer from "multer";
import path from "path";
import fs from "fs";
import { insertVehicleSchema } from "@shared/schema";
import { z } from "zod";

// Ensure uploads directory exists
const uploadsDir = path.join(process.cwd(), "server", "uploads");
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file uploads
const storage_multer = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage_multer,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedMimes = [
      'image/jpeg', 'image/png', 'image/gif',
      'video/mp4', 'video/webm'
    ];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, GIF, MP4, and WebM files are allowed.'));
    }
  }
});

export async function registerRoutes(app: Express): Promise<Server> {
  // Serve uploaded files statically
  app.use('/uploads', (req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    next();
  });
  app.use('/uploads', express.static(uploadsDir));

  // Get all vehicles with optional search and filters
  app.get("/api/vehicles", async (req, res) => {
    try {
      const { search = "", make = "", year = "" } = req.query;
      
      if (search || make || year) {
        const vehicles = await storage.searchVehicles(
          search as string,
          { make: make as string, year: year as string }
        );
        res.json(vehicles);
      } else {
        const vehicles = await storage.getVehicles();
        res.json(vehicles);
      }
    } catch (error) {
      res.status(500).json({ message: "Failed to fetch vehicles" });
    }
  });

  // Get single vehicle
  app.get("/api/vehicles/:id", async (req, res) => {
    try {
      const vehicle = await storage.getVehicle(req.params.id);
      if (!vehicle) {
        return res.status(404).json({ message: "Vehicle not found" });
      }
      res.json(vehicle);
    } catch (error) {
      res.status(500).json({ message: "Failed to fetch vehicle" });
    }
  });

  // Create new vehicle
  app.post("/api/vehicles", upload.array('media', 10), async (req, res) => {
    try {
      const vehicleData = {
        ...req.body,
        year: parseInt(req.body.year),
        mileage: req.body.mileage ? parseInt(req.body.mileage) : undefined,
        price: req.body.price ? parseFloat(req.body.price) : undefined,
      };

      // Add uploaded file paths
      const files = req.files as Express.Multer.File[];
      if (files && files.length > 0) {
        vehicleData.mediaFiles = files.map(file => `/uploads/${file.filename}`);
      }

      const validatedData = insertVehicleSchema.parse(vehicleData);
      const vehicle = await storage.createVehicle(validatedData);
      res.status(201).json(vehicle);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Validation error", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to create vehicle" });
    }
  });

  // Update vehicle
  app.patch("/api/vehicles/:id", upload.array('media', 10), async (req, res) => {
    try {
      const vehicleData = {
        ...req.body,
        year: req.body.year ? parseInt(req.body.year) : undefined,
        mileage: req.body.mileage ? parseInt(req.body.mileage) : undefined,
        price: req.body.price ? parseFloat(req.body.price) : undefined,
      };

      // Handle new uploaded files
      const files = req.files as Express.Multer.File[];
      if (files && files.length > 0) {
        const existingVehicle = await storage.getVehicle(req.params.id);
        const existingFiles = existingVehicle?.mediaFiles || [];
        const newFiles = files.map(file => `/uploads/${file.filename}`);
        vehicleData.mediaFiles = [...existingFiles, ...newFiles];
      }

      // Remove undefined values to avoid overwriting with undefined
      Object.keys(vehicleData).forEach(key => {
        if (vehicleData[key] === undefined) {
          delete vehicleData[key];
        }
      });

      const vehicle = await storage.updateVehicle(req.params.id, vehicleData);
      if (!vehicle) {
        return res.status(404).json({ message: "Vehicle not found" });
      }
      res.json(vehicle);
    } catch (error) {
      res.status(500).json({ message: "Failed to update vehicle" });
    }
  });

  // Delete vehicle
  app.delete("/api/vehicles/:id", async (req, res) => {
    try {
      const vehicle = await storage.getVehicle(req.params.id);
      if (!vehicle) {
        return res.status(404).json({ message: "Vehicle not found" });
      }

      // Delete associated media files
      if (vehicle.mediaFiles && vehicle.mediaFiles.length > 0) {
        vehicle.mediaFiles.forEach(filePath => {
          const fullPath = path.join(process.cwd(), "server", filePath.replace("/uploads", "uploads"));
          if (fs.existsSync(fullPath)) {
            fs.unlinkSync(fullPath);
          }
        });
      }

      const deleted = await storage.deleteVehicle(req.params.id);
      if (!deleted) {
        return res.status(404).json({ message: "Vehicle not found" });
      }
      res.json({ message: "Vehicle deleted successfully" });
    } catch (error) {
      res.status(500).json({ message: "Failed to delete vehicle" });
    }
  });

  // Remove specific media file from vehicle
  app.delete("/api/vehicles/:id/media", async (req, res) => {
    try {
      const { filePath } = req.body;
      const vehicle = await storage.getVehicle(req.params.id);
      
      if (!vehicle) {
        return res.status(404).json({ message: "Vehicle not found" });
      }

      const updatedMediaFiles = (vehicle.mediaFiles || []).filter(file => file !== filePath);
      
      // Delete file from filesystem
      const fullPath = path.join(process.cwd(), "server", filePath.replace("/uploads", "uploads"));
      if (fs.existsSync(fullPath)) {
        fs.unlinkSync(fullPath);
      }

      const updatedVehicle = await storage.updateVehicle(req.params.id, {
        mediaFiles: updatedMediaFiles
      });

      res.json(updatedVehicle);
    } catch (error) {
      res.status(500).json({ message: "Failed to remove media file" });
    }
  });

  const httpServer = createServer(app);
  return httpServer;
}
