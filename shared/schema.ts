import { sql } from "drizzle-orm";
import { pgTable, text, varchar, integer, decimal, timestamp } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

export const vehicles = pgTable("vehicles", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  make: text("make").notNull(),
  model: text("model").notNull(),
  year: integer("year").notNull(),
  licensePlate: text("license_plate").notNull().unique(),
  vin: text("vin"),
  mileage: integer("mileage"),
  price: decimal("price", { precision: 10, scale: 2 }),
  status: text("status").notNull().default("available"), // available, in-use, maintenance, sold
  mediaFiles: text("media_files").array().default([]), // Array of file paths
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export const insertVehicleSchema = createInsertSchema(vehicles).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
}).extend({
  year: z.number().min(1900).max(2030),
  mileage: z.number().min(0).optional(),
  price: z.number().min(0).optional(),
  status: z.enum(["available", "in-use", "maintenance", "sold"]),
});

export type InsertVehicle = z.infer<typeof insertVehicleSchema>;
export type Vehicle = typeof vehicles.$inferSelect;
