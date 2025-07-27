import { type Vehicle, type InsertVehicle } from "@shared/schema";
import { randomUUID } from "crypto";

export interface IStorage {
  getUser(id: string): Promise<{ id: string; username: string } | undefined>;
  getUserByUsername(username: string): Promise<{ id: string; username: string } | undefined>;
  createUser(user: { username: string; password: string }): Promise<{ id: string; username: string; password: string }>;
  
  // Vehicle methods
  getVehicles(): Promise<Vehicle[]>;
  getVehicle(id: string): Promise<Vehicle | undefined>;
  createVehicle(vehicle: InsertVehicle): Promise<Vehicle>;
  updateVehicle(id: string, updates: Partial<InsertVehicle>): Promise<Vehicle | undefined>;
  deleteVehicle(id: string): Promise<boolean>;
  searchVehicles(query: string, filters: { make?: string; year?: string }): Promise<Vehicle[]>;
}

export class MemStorage implements IStorage {
  private users: Map<string, { id: string; username: string; password: string }>;
  private vehicles: Map<string, Vehicle>;

  constructor() {
    this.users = new Map();
    this.vehicles = new Map();
  }

  async getUser(id: string): Promise<{ id: string; username: string } | undefined> {
    const user = this.users.get(id);
    return user ? { id: user.id, username: user.username } : undefined;
  }

  async getUserByUsername(username: string): Promise<{ id: string; username: string } | undefined> {
    const user = Array.from(this.users.values()).find((u) => u.username === username);
    return user ? { id: user.id, username: user.username } : undefined;
  }

  async createUser(insertUser: { username: string; password: string }): Promise<{ id: string; username: string; password: string }> {
    const id = randomUUID();
    const user = { ...insertUser, id };
    this.users.set(id, user);
    return user;
  }

  async getVehicles(): Promise<Vehicle[]> {
    return Array.from(this.vehicles.values()).sort((a, b) => 
      new Date(b.createdAt || 0).getTime() - new Date(a.createdAt || 0).getTime()
    );
  }

  async getVehicle(id: string): Promise<Vehicle | undefined> {
    return this.vehicles.get(id);
  }

  async createVehicle(insertVehicle: InsertVehicle): Promise<Vehicle> {
    const id = randomUUID();
    const now = new Date();
    const vehicle: Vehicle = {
      ...insertVehicle,
      id,
      mediaFiles: insertVehicle.mediaFiles || [],
      createdAt: now,
      updatedAt: now,
    };
    this.vehicles.set(id, vehicle);
    return vehicle;
  }

  async updateVehicle(id: string, updates: Partial<InsertVehicle>): Promise<Vehicle | undefined> {
    const vehicle = this.vehicles.get(id);
    if (!vehicle) return undefined;

    const updatedVehicle: Vehicle = {
      ...vehicle,
      ...updates,
      updatedAt: new Date(),
    };
    this.vehicles.set(id, updatedVehicle);
    return updatedVehicle;
  }

  async deleteVehicle(id: string): Promise<boolean> {
    return this.vehicles.delete(id);
  }

  async searchVehicles(query: string, filters: { make?: string; year?: string }): Promise<Vehicle[]> {
    const vehicles = Array.from(this.vehicles.values());
    
    return vehicles.filter(vehicle => {
      const matchesQuery = !query || 
        vehicle.make.toLowerCase().includes(query.toLowerCase()) ||
        vehicle.model.toLowerCase().includes(query.toLowerCase()) ||
        vehicle.licensePlate.toLowerCase().includes(query.toLowerCase());
      
      const matchesMake = !filters.make || vehicle.make.toLowerCase() === filters.make.toLowerCase();
      const matchesYear = !filters.year || vehicle.year.toString() === filters.year;
      
      return matchesQuery && matchesMake && matchesYear;
    }).sort((a, b) => 
      new Date(b.createdAt || 0).getTime() - new Date(a.createdAt || 0).getTime()
    );
  }
}

export const storage = new MemStorage();
