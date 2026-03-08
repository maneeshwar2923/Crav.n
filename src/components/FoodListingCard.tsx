import React from 'react';
import { MapPin, Circle } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface FoodListingCardProps {
  image: string;
  title: string;
  hostName: string;
  hostAvatar: string;
  price: number | 'free';
  distance: string;
  cuisine: string;
  isVeg?: boolean;
  rating?: number;
  onClick?: () => void;
}

export function FoodListingCard({
  image,
  title,
  hostName,
  hostAvatar,
  price,
  distance,
  cuisine,
  isVeg = true,
  rating,
  onClick
}: FoodListingCardProps) {
  return (
    <div 
      className="bg-white rounded-2xl overflow-hidden border border-[#E8F5F0] shadow-[0_2px_8px_rgba(0,0,0,0.08)] hover:border-[#006D3B] transition-all duration-200 cursor-pointer"
      onClick={onClick}
    >
      {/* Image Container (reduced height to save vertical space) */}
      <div className="relative h-36 overflow-hidden">
        <ImageWithFallback
          src={image}
          alt={title}
          className="w-full h-full object-cover"
        />
        {/* Gradient Overlay */}
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/20 to-transparent" />
        
        {/* Price Badge (more compact) */}
        <div className="absolute top-3 right-3">
          {price === 'free' ? (
            <div className="bg-[#4CAF50] text-white px-2 py-1 rounded-full text-sm font-bold shadow-lg">
              FREE
            </div>
          ) : (
            <div className="bg-[#006D3B] text-white px-2 py-1 rounded-full font-bold shadow-lg">
              ₹{price}
            </div>
          )}
        </div>
        
        {/* Title Overlay */}
        <div className="absolute bottom-3 left-3 right-3">
          <h3 className="text-white text-lg font-bold line-clamp-1">{title}</h3>
        </div>
        
        {/* Host Avatar (slightly smaller) */}
        <div className="absolute bottom-3 right-3">
          <ImageWithFallback
            src={hostAvatar}
            alt={hostName}
            className="w-9 h-9 rounded-full border-2 border-white object-cover"
          />
        </div>
      </div>
      
      {/* Content */}
      <div className="p-3">
        <div className="flex items-center justify-between mb-1">
          <div className="flex items-center gap-2 text-[#666666] text-sm">
            <MapPin size={14} />
            <span>{distance}</span>
          </div>
          
          <div className="flex items-center gap-2">
            {isVeg && (
              <div className="w-5 h-5 border-2 border-[#4CAF50] rounded flex items-center justify-center">
                <Circle className="text-[#4CAF50] fill-[#4CAF50]" size={8} />
              </div>
            )}
            {rating && (
              <div className="flex items-center gap-1 text-sm">
                <span className="text-[#FFC107]">★</span>
                <span className="text-[#666666]">{rating}</span>
              </div>
            )}
          </div>
        </div>
        
        <div className="text-[#666666] text-sm">
          {cuisine}
        </div>
      </div>
    </div>
  );
}
