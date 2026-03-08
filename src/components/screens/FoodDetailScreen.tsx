import React, { useState } from 'react';
import { ArrowLeft, Circle, MapPin, Clock, Calendar, Star, Phone, MessageCircle, Share2 } from 'lucide-react';
import { CravnButton } from '../CravnButton';
import { ImageWithFallback } from '../figma/ImageWithFallback';

interface FoodDetailScreenProps {
  onBack: () => void;
  onReserve: () => void;
}

export function FoodDetailScreen({ onBack, onReserve }: FoodDetailScreenProps) {
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  
  const images = [
    'https://images.unsplash.com/photo-1605719161691-5d9771fc144f?w=800',
    'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800',
    'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=800'
  ];
  
  return (
    <div className="min-h-screen bg-white pb-24">
      {/* Image Carousel */}
      <div className="relative h-80">
        <ImageWithFallback
          src={images[currentImageIndex]}
          alt="Food"
          className="w-full h-full object-cover"
        />
        
        {/* Gradient Overlay */}
        <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent" />
        
        {/* Back Button */}
        <button 
          onClick={onBack}
          className="absolute top-4 left-4 w-10 h-10 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center shadow-lg hover:bg-white transition-colors"
        >
          <ArrowLeft className="text-[#1A1A1A]" size={20} />
        </button>
        
        {/* Share Button */}
        <button className="absolute top-4 right-4 w-10 h-10 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center shadow-lg hover:bg-white transition-colors">
          <Share2 className="text-[#1A1A1A]" size={20} />
        </button>
        
        {/* Page Indicators */}
        <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-2">
          {images.map((_, index) => (
            <button
              key={index}
              onClick={() => setCurrentImageIndex(index)}
              className={`h-2 rounded-full transition-all ${
                index === currentImageIndex 
                  ? 'w-6 bg-white' 
                  : 'w-2 bg-white/50'
              }`}
            />
          ))}
        </div>
      </div>
      
      {/* Content */}
      <div className="px-4 py-6 space-y-6">
        {/* Title & Price */}
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <h1 className="text-[#1A1A1A] mb-2 text-2xl font-bold">Homemade Biryani</h1>
            <div className="flex items-center gap-3">
              <div className="flex items-center gap-1">
                <div className="w-5 h-5 border-2 border-[#4CAF50] rounded flex items-center justify-center">
                  <Circle className="text-[#4CAF50] fill-[#4CAF50]" size={8} />
                </div>
                <span className="text-[#666666] text-sm">Pure Veg</span>
              </div>
              <div className="flex items-center gap-1">
                <Star className="text-[#FFC107] fill-[#FFC107]" size={16} />
                <span className="text-[#1A1A1A]">4.8</span>
                <span className="text-[#666666] text-sm">(24 reviews)</span>
              </div>
            </div>
          </div>
          <div className="bg-[#006D3B] text-white px-4 py-2 rounded-xl font-bold text-xl">
            ₹80
          </div>
        </div>
        
        {/* Host Card */}
        <div className="bg-[#E8F5F0] rounded-2xl p-4">
          <div className="flex items-center gap-3">
            <ImageWithFallback
              src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop"
              alt="Priya"
              className="w-14 h-14 rounded-full object-cover"
            />
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-1">
                <h3 className="text-[#1A1A1A] font-bold">Priya Sharma</h3>
                <div className="bg-[#006D3B] text-white px-2 py-0.5 rounded-full text-xs font-semibold">
                  Verified
                </div>
              </div>
              <p className="text-[#666666] text-sm">Host since 2023 • 45 shares</p>
            </div>
            <div className="flex gap-2">
              <button className="w-10 h-10 bg-white rounded-full flex items-center justify-center hover:bg-[#006D3B] hover:text-white transition-colors">
                <Phone size={18} />
              </button>
              <button className="w-10 h-10 bg-white rounded-full flex items-center justify-center hover:bg-[#006D3B] hover:text-white transition-colors">
                <MessageCircle size={18} />
              </button>
            </div>
          </div>
        </div>
        
        {/* Description */}
        <div className="bg-white border border-[#E8F5F0] rounded-2xl p-4">
          <h3 className="text-[#1A1A1A] mb-2 font-bold">Description</h3>
          <p className="text-[#666666]">
            Authentic homemade Hyderabadi biryani made with premium basmati rice, 
            aromatic spices, and fresh vegetables. Prepared with love and care. 
            Perfect for lunch or dinner. Contains mild spices suitable for all ages.
          </p>
        </div>
        
        {/* Tags */}
        <div className="flex flex-wrap gap-2">
          <div className="px-3 py-1.5 bg-[#E8F5F0] text-[#006D3B] rounded-full text-sm">
            Indian Cuisine
          </div>
          <div className="px-3 py-1.5 bg-[#E8F5F0] text-[#006D3B] rounded-full text-sm">
            Spicy
          </div>
          <div className="px-3 py-1.5 bg-[#E8F5F0] text-[#006D3B] rounded-full text-sm">
            Serves 2-3
          </div>
          <div className="px-3 py-1.5 bg-[#FFF3E0] text-[#FFA726] rounded-full text-sm">
            Best before 8 PM
          </div>
        </div>
        
        {/* Details */}
        <div className="bg-white border border-[#E8F5F0] rounded-2xl p-4 space-y-3">
          <div className="flex items-center gap-3">
            <MapPin className="text-[#006D3B]" size={20} />
            <div className="flex-1">
              <p className="text-[#1A1A1A] font-semibold">0.5 km away</p>
              <p className="text-[#666666] text-sm">Sector 12, HSR Layout, Bangalore</p>
            </div>
            <CravnButton variant="outline" size="small">
              Directions
            </CravnButton>
          </div>
          
          <div className="h-px bg-[#E0E0E0]" />
          
          <div className="flex items-center gap-3">
            <Clock className="text-[#006D3B]" size={20} />
            <div>
              <p className="text-[#1A1A1A] font-semibold">Available Today</p>
              <p className="text-[#666666] text-sm">5:00 PM - 8:00 PM</p>
            </div>
          </div>
          
          <div className="h-px bg-[#E0E0E0]" />
          
          <div className="flex items-center gap-3">
            <Calendar className="text-[#006D3B]" size={20} />
            <div>
              <p className="text-[#1A1A1A] font-semibold">Pickup</p>
              <p className="text-[#666666] text-sm">Come collect from my place</p>
            </div>
          </div>
        </div>
        
        {/* Mini Map Placeholder */}
        <div className="bg-[#E8F5F0] rounded-2xl h-48 flex items-center justify-center overflow-hidden relative">
          <svg className="w-full h-full" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <pattern id="miniGrid" width="30" height="30" patternUnits="userSpaceOnUse">
                <path d="M 30 0 L 0 0 0 30" fill="none" stroke="#D0E8DC" strokeWidth="0.5"/>
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#miniGrid)" />
            <line x1="0" y1="50%" x2="100%" y2="50%" stroke="#C0D8CC" strokeWidth="2" />
            <line x1="50%" y1="0" x2="50%" y2="100%" stroke="#C0D8CC" strokeWidth="2" />
          </svg>
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="w-12 h-12 bg-[#006D3B] rounded-full flex items-center justify-center shadow-lg">
              <MapPin className="text-white" size={24} />
            </div>
          </div>
        </div>
      </div>
      
      {/* Sticky Bottom CTA */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-[#E0E0E0] p-4 shadow-lg">
        <CravnButton 
          variant="primary" 
          size="large" 
          fullWidth
          onClick={onReserve}
        >
          Reserve for ₹80
        </CravnButton>
      </div>
    </div>
  );
}
