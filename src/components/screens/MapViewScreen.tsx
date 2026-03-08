import React, { useState } from 'react';
import { Search, Navigation, X } from 'lucide-react';
import { CravnButton } from '../CravnButton';
import { ImageWithFallback } from '../figma/ImageWithFallback';

interface MapViewScreenProps {
  onFoodItemClick: (id: string) => void;
}

export function MapViewScreen({ onFoodItemClick }: MapViewScreenProps) {
  const [selectedMarker, setSelectedMarker] = useState<string | null>('1');
  
  const markers = [
    {
      id: '1',
      position: { top: '30%', left: '40%' },
      price: 80,
      image: 'https://images.unsplash.com/photo-1605719161691-5d9771fc144f?w=400',
      title: 'Homemade Biryani',
      distance: '0.5 km',
      hostName: 'Priya'
    },
    {
      id: '2',
      position: { top: '50%', left: '60%' },
      price: 'free',
      image: 'https://images.unsplash.com/photo-1614442316719-1e38c661c29c?w=400',
      title: 'Fresh Margherita Pizza',
      distance: '1.2 km',
      hostName: 'Raj'
    },
    {
      id: '3',
      position: { top: '60%', left: '30%' },
      price: 60,
      image: 'https://images.unsplash.com/photo-1644704001249-0d9dbb842238?w=400',
      title: 'Creamy Pasta Bowl',
      distance: '2.1 km',
      hostName: 'Sarah'
    }
  ];
  
  const selectedMarkerData = markers.find(m => m.id === selectedMarker);
  
  return (
    <div className="relative h-screen overflow-hidden">
      {/* Map Background - Simulated */}
      <div className="absolute inset-0 bg-[#E8F5F0]">
        {/* Simplified map-like background */}
        <svg className="w-full h-full" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
              <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#D0E8DC" strokeWidth="0.5"/>
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#grid)" />
          
          {/* Roads */}
          <line x1="0" y1="30%" x2="100%" y2="30%" stroke="#C0D8CC" strokeWidth="3" />
          <line x1="0" y1="60%" x2="100%" y2="60%" stroke="#C0D8CC" strokeWidth="3" />
          <line x1="40%" y1="0" x2="40%" y2="100%" stroke="#C0D8CC" strokeWidth="3" />
          <line x1="70%" y1="0" x2="70%" y2="100%" stroke="#C0D8CC" strokeWidth="3" />
        </svg>
        
        {/* Food Markers */}
        {markers.map((marker) => (
          <button
            key={marker.id}
            className="absolute transform -translate-x-1/2 -translate-y-full transition-all hover:scale-110"
            style={{ top: marker.position.top, left: marker.position.left }}
            onClick={() => setSelectedMarker(marker.id)}
          >
            <div className="relative">
              {/* Pin */}
              <div className={`w-12 h-12 rounded-full ${
                marker.price === 'free' ? 'bg-[#4CAF50]' : 'bg-[#006D3B]'
              } shadow-[0_4px_12px_rgba(0,109,59,0.4)] flex items-center justify-center border-4 border-white`}>
                <div className="text-white">
                  {marker.price === 'free' ? (
                    <span className="text-xs">FREE</span>
                  ) : (
                    <span className="text-sm">₹{marker.price}</span>
                  )}
                </div>
              </div>
              {/* Pointer */}
              <div className={`absolute left-1/2 -translate-x-1/2 w-0 h-0 border-l-[8px] border-l-transparent border-r-[8px] border-r-transparent ${
                marker.price === 'free' ? 'border-t-[12px] border-t-[#4CAF50]' : 'border-t-[12px] border-t-[#006D3B]'
              }`} />
            </div>
          </button>
        ))}
      </div>
      
      {/* Floating Search Bar */}
      <div className="absolute top-4 left-4 right-4 z-10">
        <div className="bg-white rounded-xl shadow-lg px-4 py-3 flex items-center gap-3">
          <Search className="text-[#006D3B]" size={20} />
          <input
            type="text"
            placeholder="Search location..."
            className="flex-1 outline-none"
          />
        </div>
      </div>
      
      {/* My Location FAB */}
      <button className="absolute bottom-32 right-4 z-10 w-14 h-14 bg-white rounded-full shadow-lg flex items-center justify-center hover:bg-[#E8F5F0] transition-colors">
        <Navigation className="text-[#006D3B]" size={24} />
      </button>
      
      {/* Bottom Sheet - Food Preview */}
      {selectedMarkerData && (
        <div className="absolute bottom-0 left-0 right-0 z-20 bg-white rounded-t-3xl shadow-2xl">
          <div className="px-4 py-6">
            {/* Handle */}
            <div className="w-12 h-1 bg-[#E0E0E0] rounded-full mx-auto mb-4" />
            
            {/* Content */}
            <div className="flex gap-4">
              {/* Image */}
              <div className="w-28 h-28 rounded-2xl overflow-hidden flex-shrink-0">
                <ImageWithFallback
                  src={selectedMarkerData.image}
                  alt={selectedMarkerData.title}
                  className="w-full h-full object-cover"
                />
              </div>
              
              {/* Info */}
              <div className="flex-1">
                <div className="flex items-start justify-between mb-2">
                  <div>
                    <h3 className="text-[#1A1A1A] mb-1">{selectedMarkerData.title}</h3>
                    <p className="text-[#666666] text-sm">{selectedMarkerData.distance} • by {selectedMarkerData.hostName}</p>
                  </div>
                  <button 
                    onClick={() => setSelectedMarker(null)}
                    className="p-1 hover:bg-[#E8F5F0] rounded-lg transition-colors"
                  >
                    <X className="text-[#666666]" size={20} />
                  </button>
                </div>
                
                <div className="flex items-center gap-2 mt-3">
                  <div className={`px-3 py-1.5 rounded-full text-white ${
                    selectedMarkerData.price === 'free' ? 'bg-[#4CAF50]' : 'bg-[#006D3B]'
                  }`}>
                    {selectedMarkerData.price === 'free' ? 'FREE' : `₹${selectedMarkerData.price}`}
                  </div>
                  <CravnButton
                    variant="primary"
                    size="small"
                    onClick={() => onFoodItemClick(selectedMarkerData.id)}
                    className="flex-1"
                  >
                    View Details
                  </CravnButton>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
