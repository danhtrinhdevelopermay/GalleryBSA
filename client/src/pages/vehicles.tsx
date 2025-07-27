import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import Header from "@/components/header";
import SearchFilterBar from "@/components/search-filter-bar";
import VehicleCard from "@/components/vehicle-card";
import VehicleFormModal from "@/components/vehicle-form-modal";
import MediaViewerModal from "@/components/media-viewer-modal";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";
import type { Vehicle } from "@shared/schema";

export default function Vehicles() {
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [editingVehicle, setEditingVehicle] = useState<Vehicle | null>(null);
  const [mediaViewerData, setMediaViewerData] = useState<{
    isOpen: boolean;
    media: string[];
    currentIndex: number;
  }>({ isOpen: false, media: [], currentIndex: 0 });
  
  const [searchQuery, setSearchQuery] = useState("");
  const [filterMake, setFilterMake] = useState("");
  const [filterYear, setFilterYear] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 6;

  const { data: vehicles = [], isLoading } = useQuery<Vehicle[]>({
    queryKey: ["/api/vehicles", searchQuery, filterMake, filterYear],
    queryFn: async () => {
      const params = new URLSearchParams();
      if (searchQuery) params.append("search", searchQuery);
      if (filterMake) params.append("make", filterMake);
      if (filterYear) params.append("year", filterYear);
      
      const response = await fetch(`/api/vehicles?${params}`);
      if (!response.ok) throw new Error("Failed to fetch vehicles");
      return response.json();
    },
  });

  // Pagination
  const totalPages = Math.ceil(vehicles.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedVehicles = vehicles.slice(startIndex, startIndex + itemsPerPage);

  const handleEditVehicle = (vehicle: Vehicle) => {
    setEditingVehicle(vehicle);
  };

  const handleViewMedia = (media: string[], startIndex = 0) => {
    setMediaViewerData({
      isOpen: true,
      media,
      currentIndex: startIndex,
    });
  };

  const closeMediaViewer = () => {
    setMediaViewerData({ isOpen: false, media: [], currentIndex: 0 });
  };

  const uniqueMakes = [...new Set(vehicles.map(v => v.make))];

  return (
    <div className="min-h-screen bg-neutral-bg">
      <Header />
      
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Page Header */}
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8">
          <div>
            <h2 className="text-3xl font-bold text-secondary mb-2">Vehicle Fleet</h2>
            <p className="text-gray-600">Manage your vehicle inventory with media support</p>
          </div>
          <Button 
            onClick={() => setIsAddModalOpen(true)}
            className="mt-4 sm:mt-0 bg-primary hover:bg-blue-700 text-white"
          >
            <Plus className="w-4 h-4 mr-2" />
            Add Vehicle
          </Button>
        </div>

        {/* Search and Filter */}
        <SearchFilterBar
          searchQuery={searchQuery}
          onSearchChange={setSearchQuery}
          filterMake={filterMake}
          onMakeChange={setFilterMake}
          filterYear={filterYear}
          onYearChange={setFilterYear}
          uniqueMakes={uniqueMakes}
        />

        {/* Vehicle Grid */}
        {isLoading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
                <div className="h-48 bg-gray-200 animate-pulse" />
                <div className="p-6">
                  <div className="h-6 bg-gray-200 rounded animate-pulse mb-4" />
                  <div className="space-y-2">
                    <div className="h-4 bg-gray-200 rounded animate-pulse" />
                    <div className="h-4 bg-gray-200 rounded animate-pulse" />
                    <div className="h-4 bg-gray-200 rounded animate-pulse" />
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : vehicles.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-gray-400 text-6xl mb-4">🚗</div>
            <h3 className="text-xl font-semibold text-gray-600 mb-2">No vehicles found</h3>
            <p className="text-gray-500 mb-6">
              {searchQuery || filterMake || filterYear 
                ? "Try adjusting your search filters"
                : "Get started by adding your first vehicle"
              }
            </p>
            <Button 
              onClick={() => setIsAddModalOpen(true)}
              className="bg-primary hover:bg-blue-700 text-white"
            >
              <Plus className="w-4 h-4 mr-2" />
              Add Vehicle
            </Button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
            {paginatedVehicles.map((vehicle) => (
              <VehicleCard
                key={vehicle.id}
                vehicle={vehicle}
                onEdit={() => handleEditVehicle(vehicle)}
                onViewMedia={handleViewMedia}
              />
            ))}
          </div>
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-between bg-white rounded-lg shadow-sm border border-gray-200 px-6 py-4">
            <div className="text-sm text-gray-600">
              Showing {startIndex + 1} to {Math.min(startIndex + itemsPerPage, vehicles.length)} of {vehicles.length} vehicles
            </div>
            <div className="flex items-center space-x-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                disabled={currentPage === 1}
              >
                Previous
              </Button>
              {[...Array(totalPages)].map((_, i) => (
                <Button
                  key={i + 1}
                  variant={currentPage === i + 1 ? "default" : "outline"}
                  size="sm"
                  onClick={() => setCurrentPage(i + 1)}
                  className={currentPage === i + 1 ? "bg-primary text-white" : ""}
                >
                  {i + 1}
                </Button>
              ))}
              <Button
                variant="outline"
                size="sm"
                onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                disabled={currentPage === totalPages}
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </div>

      {/* Modals */}
      <VehicleFormModal
        isOpen={isAddModalOpen || !!editingVehicle}
        onClose={() => {
          setIsAddModalOpen(false);
          setEditingVehicle(null);
        }}
        vehicle={editingVehicle}
      />

      <MediaViewerModal
        isOpen={mediaViewerData.isOpen}
        media={mediaViewerData.media}
        currentIndex={mediaViewerData.currentIndex}
        onClose={closeMediaViewer}
      />
    </div>
  );
}
