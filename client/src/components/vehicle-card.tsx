import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Edit, Images, Trash2 } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { apiRequest } from "@/lib/queryClient";
import type { Vehicle } from "@shared/schema";

interface VehicleCardProps {
  vehicle: Vehicle;
  onEdit: () => void;
  onViewMedia: (media: string[], startIndex?: number) => void;
}

export default function VehicleCard({ vehicle, onEdit, onViewMedia }: VehicleCardProps) {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [isDeleting, setIsDeleting] = useState(false);

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      await apiRequest("DELETE", `/api/vehicles/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/vehicles"] });
      toast({
        title: "Success",
        description: "Vehicle deleted successfully",
      });
    },
    onError: () => {
      toast({
        title: "Error",
        description: "Failed to delete vehicle",
        variant: "destructive",
      });
    },
    onSettled: () => {
      setIsDeleting(false);
    },
  });

  const handleDelete = () => {
    if (confirm("Are you sure you want to delete this vehicle?")) {
      setIsDeleting(true);
      deleteMutation.mutate(vehicle.id);
    }
  };

  const getStatusVariant = (status: string) => {
    switch (status) {
      case "available": return "success";
      case "in-use": return "warning";
      case "maintenance": return "destructive";
      case "sold": return "secondary";
      default: return "secondary";
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case "available": return "Available";
      case "in-use": return "In Use";
      case "maintenance": return "Maintenance";
      case "sold": return "Sold";
      default: return status;
    }
  };

  const primaryImage = vehicle.mediaFiles?.[0];
  const mediaCount = vehicle.mediaFiles?.length || 0;

  return (
    <Card className="overflow-hidden hover:shadow-md transition-shadow cursor-pointer">
      <div className="relative h-48 bg-gray-100">
        {primaryImage ? (
          <img
            src={primaryImage}
            alt={`${vehicle.make} ${vehicle.model}`}
            className="w-full h-full object-cover"
            onClick={() => onViewMedia(vehicle.mediaFiles || [])}
          />
        ) : (
          <div 
            className="w-full h-full flex items-center justify-center text-gray-400"
            onClick={() => onViewMedia([])}
          >
            <div className="text-center">
              <Images className="w-12 h-12 mx-auto mb-2" />
              <p className="text-sm">No image</p>
            </div>
          </div>
        )}
        
        {mediaCount > 0 && (
          <div className="absolute top-3 right-3 bg-black bg-opacity-50 text-white px-2 py-1 rounded text-sm">
            <Images className="w-3 h-3 inline mr-1" />
            {mediaCount}
          </div>
        )}
        
        <div className="absolute bottom-3 left-3">
          <Badge 
            variant={getStatusVariant(vehicle.status)}
            className="text-white font-medium"
          >
            {getStatusLabel(vehicle.status)}
          </Badge>
        </div>
      </div>
      
      <CardContent className="p-6">
        <div className="flex justify-between items-start mb-2">
          <h3 className="text-lg font-semibold text-secondary">
            {vehicle.year} {vehicle.make} {vehicle.model}
          </h3>
          {vehicle.price && (
            <span className="text-accent font-bold">
              ${parseFloat(vehicle.price).toLocaleString()}
            </span>
          )}
        </div>
        
        <div className="space-y-2 text-sm text-gray-600">
          <div className="flex justify-between">
            <span>License Plate:</span>
            <span className="font-medium">{vehicle.licensePlate}</span>
          </div>
          {vehicle.mileage && (
            <div className="flex justify-between">
              <span>Mileage:</span>
              <span className="font-medium">{vehicle.mileage.toLocaleString()} miles</span>
            </div>
          )}
          <div className="flex justify-between">
            <span>Year:</span>
            <span className="font-medium">{vehicle.year}</span>
          </div>
        </div>
        
        <div className="flex items-center space-x-2 mt-4 pt-4 border-t border-gray-100">
          <Button
            onClick={onEdit}
            className="flex-1 bg-primary hover:bg-blue-700 text-white"
            size="sm"
          >
            <Edit className="w-3 h-3 mr-1" />
            Edit
          </Button>
          
          <Button
            onClick={() => onViewMedia(vehicle.mediaFiles || [])}
            variant="outline"
            size="sm"
            className="px-3"
          >
            <Images className="w-4 h-4" />
          </Button>
          
          <Button
            onClick={handleDelete}
            variant="outline"
            size="sm"
            className="px-3 text-error hover:text-error"
            disabled={isDeleting}
          >
            <Trash2 className="w-4 h-4" />
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
