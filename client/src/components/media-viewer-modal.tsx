import { useState, useEffect } from "react";
import { Dialog, DialogContent } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { X, ChevronLeft, ChevronRight, ZoomIn, ZoomOut, Download } from "lucide-react";

interface MediaViewerModalProps {
  isOpen: boolean;
  media: string[];
  currentIndex: number;
  onClose: () => void;
}

export default function MediaViewerModal({ isOpen, media, currentIndex, onClose }: MediaViewerModalProps) {
  const [index, setIndex] = useState(currentIndex);
  const [zoom, setZoom] = useState(1);

  useEffect(() => {
    setIndex(currentIndex);
    setZoom(1);
  }, [currentIndex, isOpen]);

  const currentMedia = media[index];
  const isVideo = currentMedia?.includes('.mp4') || currentMedia?.includes('.webm');

  const nextMedia = () => {
    if (index < media.length - 1) {
      setIndex(index + 1);
      setZoom(1);
    }
  };

  const prevMedia = () => {
    if (index > 0) {
      setIndex(index - 1);
      setZoom(1);
    }
  };

  const handleZoomIn = () => {
    setZoom(prev => Math.min(prev + 0.25, 3));
  };

  const handleZoomOut = () => {
    setZoom(prev => Math.max(prev - 0.25, 0.25));
  };

  const handleDownload = () => {
    if (currentMedia) {
      const link = document.createElement('a');
      link.href = currentMedia;
      link.download = currentMedia.split('/').pop() || 'media';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  };

  const handleKeyDown = (e: KeyboardEvent) => {
    if (!isOpen) return;
    
    switch (e.key) {
      case 'ArrowLeft':
        prevMedia();
        break;
      case 'ArrowRight':
        nextMedia();
        break;
      case 'Escape':
        onClose();
        break;
    }
  };

  useEffect(() => {
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, index]);

  if (!isOpen || media.length === 0) return null;

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-none w-full h-full p-0 bg-black bg-opacity-90 border-none">
        <div className="relative w-full h-full flex items-center justify-center">
          {/* Close Button */}
          <Button
            variant="ghost"
            size="sm"
            className="absolute top-4 right-4 text-white hover:text-gray-300 z-10"
            onClick={onClose}
          >
            <X className="w-6 h-6" />
          </Button>

          {/* Media Container */}
          <div className="relative w-full h-full flex items-center justify-center">
            {currentMedia && (
              <div 
                className="max-w-full max-h-full"
                style={{ transform: `scale(${zoom})` }}
              >
                {isVideo ? (
                  <video
                    src={currentMedia}
                    controls
                    className="max-w-full max-h-full object-contain"
                    autoPlay
                  />
                ) : (
                  <img
                    src={currentMedia}
                    alt={`Media ${index + 1}`}
                    className="max-w-full max-h-full object-contain"
                  />
                )}
              </div>
            )}

            {/* Navigation Buttons */}
            {media.length > 1 && (
              <>
                <Button
                  variant="ghost"
                  size="sm"
                  className="absolute left-4 top-1/2 transform -translate-y-1/2 text-white hover:text-gray-300"
                  onClick={prevMedia}
                  disabled={index === 0}
                >
                  <ChevronLeft className="w-8 h-8" />
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  className="absolute right-4 top-1/2 transform -translate-y-1/2 text-white hover:text-gray-300"
                  onClick={nextMedia}
                  disabled={index === media.length - 1}
                >
                  <ChevronRight className="w-8 h-8" />
                </Button>
              </>
            )}
          </div>

          {/* Controls */}
          <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 bg-black bg-opacity-50 rounded-lg px-4 py-2 flex items-center space-x-4">
            {!isVideo && (
              <>
                <Button
                  variant="ghost"
                  size="sm"
                  className="text-white hover:text-gray-300"
                  onClick={handleZoomIn}
                  disabled={zoom >= 3}
                >
                  <ZoomIn className="w-4 h-4" />
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  className="text-white hover:text-gray-300"
                  onClick={handleZoomOut}
                  disabled={zoom <= 0.25}
                >
                  <ZoomOut className="w-4 h-4" />
                </Button>
              </>
            )}
            
            {media.length > 1 && (
              <span className="text-white text-sm">
                {index + 1} / {media.length}
              </span>
            )}
            
            <Button
              variant="ghost"
              size="sm"
              className="text-white hover:text-gray-300"
              onClick={handleDownload}
            >
              <Download className="w-4 h-4" />
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
