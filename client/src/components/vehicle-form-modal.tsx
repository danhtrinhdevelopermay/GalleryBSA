import { useState, useRef } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { CloudUpload, X, Save, Image as ImageIcon, Video } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { insertVehicleSchema, type Vehicle } from "@shared/schema";
import { apiRequest } from "@/lib/queryClient";

interface VehicleFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  vehicle?: Vehicle | null;
}

interface MediaFile {
  file: File;
  preview: string;
  type: 'image' | 'video';
}

export default function VehicleFormModal({ isOpen, onClose, vehicle }: VehicleFormModalProps) {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [mediaFiles, setMediaFiles] = useState<MediaFile[]>([]);
  const [isDragging, setIsDragging] = useState(false);

  const form = useForm({
    resolver: zodResolver(insertVehicleSchema),
    defaultValues: {
      make: vehicle?.make || "",
      model: vehicle?.model || "",
      year: vehicle?.year || new Date().getFullYear(),
      licensePlate: vehicle?.licensePlate || "",
      vin: vehicle?.vin || "",
      mileage: vehicle?.mileage || undefined,
      price: vehicle?.price ? parseFloat(vehicle.price) : undefined,
      status: vehicle?.status || "available",
      mediaFiles: vehicle?.mediaFiles || [],
    },
  });

  const mutation = useMutation({
    mutationFn: async (data: FormData) => {
      const url = vehicle ? `/api/vehicles/${vehicle.id}` : "/api/vehicles";
      const method = vehicle ? "PATCH" : "POST";
      
      const response = await fetch(url, {
        method,
        body: data,
      });
      
      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || "Failed to save vehicle");
      }
      
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/vehicles"] });
      toast({
        title: "Success",
        description: vehicle ? "Vehicle updated successfully" : "Vehicle created successfully",
      });
      onClose();
      form.reset();
      setMediaFiles([]);
    },
    onError: (error) => {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  const handleFileSelect = (files: FileList | null) => {
    if (!files) return;

    const newFiles: MediaFile[] = [];
    
    Array.from(files).forEach((file) => {
      if (file.size > 10 * 1024 * 1024) {
        toast({
          title: "File too large",
          description: `${file.name} is larger than 10MB`,
          variant: "destructive",
        });
        return;
      }

      const isImage = file.type.startsWith('image/');
      const isVideo = file.type.startsWith('video/');
      
      if (!isImage && !isVideo) {
        toast({
          title: "Invalid file type",
          description: `${file.name} is not a supported media file`,
          variant: "destructive",
        });
        return;
      }

      const preview = URL.createObjectURL(file);
      newFiles.push({
        file,
        preview,
        type: isImage ? 'image' : 'video',
      });
    });

    setMediaFiles(prev => [...prev, ...newFiles]);
  };

  const removeMediaFile = (index: number) => {
    setMediaFiles(prev => {
      const file = prev[index];
      URL.revokeObjectURL(file.preview);
      return prev.filter((_, i) => i !== index);
    });
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    handleFileSelect(e.dataTransfer.files);
  };

  const onSubmit = (data: any) => {
    const formData = new FormData();
    
    // Append form data
    Object.keys(data).forEach(key => {
      if (data[key] !== undefined && data[key] !== "" && key !== "mediaFiles") {
        formData.append(key, data[key].toString());
      }
    });

    // Append media files
    mediaFiles.forEach((mediaFile) => {
      formData.append('media', mediaFile.file);
    });

    mutation.mutate(formData);
  };

  const handleClose = () => {
    // Clean up object URLs
    mediaFiles.forEach(file => URL.revokeObjectURL(file.preview));
    setMediaFiles([]);
    form.reset();
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={handleClose}>
      <DialogContent className="max-w-4xl max-h-screen overflow-y-auto">
        <DialogHeader>
          <DialogTitle>
            {vehicle ? "Edit Vehicle" : "Add New Vehicle"}
          </DialogTitle>
        </DialogHeader>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            {/* Vehicle Information */}
            <div>
              <h4 className="text-lg font-medium text-secondary mb-4">Vehicle Information</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <FormField
                  control={form.control}
                  name="make"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Make</FormLabel>
                      <FormControl>
                        <Input placeholder="e.g., Toyota" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="model"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Model</FormLabel>
                      <FormControl>
                        <Input placeholder="e.g., Camry" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="year"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Year</FormLabel>
                      <FormControl>
                        <Input 
                          type="number" 
                          min="1900" 
                          max="2030" 
                          {...field}
                          onChange={(e) => field.onChange(parseInt(e.target.value))}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="licensePlate"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>License Plate</FormLabel>
                      <FormControl>
                        <Input placeholder="ABC-1234" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="vin"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>VIN</FormLabel>
                      <FormControl>
                        <Input placeholder="17-digit VIN" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="mileage"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Mileage</FormLabel>
                      <FormControl>
                        <Input 
                          type="number" 
                          placeholder="50000" 
                          {...field}
                          onChange={(e) => field.onChange(e.target.value ? parseInt(e.target.value) : undefined)}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="price"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Price</FormLabel>
                      <FormControl>
                        <Input 
                          type="number" 
                          step="0.01" 
                          placeholder="25000" 
                          {...field}
                          onChange={(e) => field.onChange(e.target.value ? parseFloat(e.target.value) : undefined)}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="status"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Status</FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger>
                            <SelectValue placeholder="Select Status" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          <SelectItem value="available">Available</SelectItem>
                          <SelectItem value="in-use">In Use</SelectItem>
                          <SelectItem value="maintenance">Maintenance</SelectItem>
                          <SelectItem value="sold">Sold</SelectItem>
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
            </div>

            {/* Media Upload */}
            <div>
              <h4 className="text-lg font-medium text-secondary mb-4">Media Upload</h4>
              
              <div
                className={`border-2 border-dashed rounded-lg p-8 text-center transition-colors ${
                  isDragging ? "border-primary bg-blue-50" : "border-gray-300"
                }`}
                onDragOver={handleDragOver}
                onDragLeave={handleDragLeave}
                onDrop={handleDrop}
              >
                <CloudUpload className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <p className="text-lg text-gray-600 mb-2">Drag and drop images or videos here</p>
                <p className="text-sm text-gray-500 mb-4">or click to browse files</p>
                <Button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  className="bg-primary hover:bg-blue-700"
                >
                  Choose Files
                </Button>
                <p className="text-xs text-gray-500 mt-4">
                  Supported formats: JPEG, PNG, GIF, MP4, WebM (Max 10MB per file)
                </p>
                <input
                  ref={fileInputRef}
                  type="file"
                  multiple
                  accept="image/*,video/*"
                  className="hidden"
                  onChange={(e) => handleFileSelect(e.target.files)}
                />
              </div>

              {/* Media Preview */}
              {mediaFiles.length > 0 && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
                  {mediaFiles.map((mediaFile, index) => (
                    <div key={index} className="relative bg-gray-100 rounded-lg overflow-hidden aspect-square">
                      {mediaFile.type === 'image' ? (
                        <img
                          src={mediaFile.preview}
                          alt={`Preview ${index + 1}`}
                          className="w-full h-full object-cover"
                        />
                      ) : (
                        <video
                          src={mediaFile.preview}
                          className="w-full h-full object-cover"
                          muted
                        />
                      )}
                      <Button
                        type="button"
                        size="sm"
                        variant="destructive"
                        className="absolute top-2 right-2 w-6 h-6 p-0"
                        onClick={() => removeMediaFile(index)}
                      >
                        <X className="w-3 h-3" />
                      </Button>
                      <div className="absolute bottom-2 left-2 bg-black bg-opacity-50 text-white px-2 py-1 rounded text-xs">
                        {mediaFile.type === 'image' ? (
                          <ImageIcon className="w-3 h-3" />
                        ) : (
                          <Video className="w-3 h-3" />
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Form Actions */}
            <div className="flex items-center justify-end space-x-4 pt-6 border-t border-gray-200">
              <Button type="button" variant="outline" onClick={handleClose}>
                Cancel
              </Button>
              <Button 
                type="submit" 
                disabled={mutation.isPending}
                className="bg-primary hover:bg-blue-700"
              >
                <Save className="w-4 h-4 mr-2" />
                {mutation.isPending ? "Saving..." : "Save Vehicle"}
              </Button>
            </div>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
