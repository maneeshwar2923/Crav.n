import React, { useState } from 'react';
import { AppBar } from '../AppBar';
import { CravnButton } from '../CravnButton';
import { Camera, MapPin, Upload } from 'lucide-react';

interface CreateListingScreenProps {
  onPublish: () => void;
  onBack: () => void;
}

export function CreateListingScreen({ onPublish, onBack }: CreateListingScreenProps) {
  const [currentStep, setCurrentStep] = useState(1);
  const [isFree, setIsFree] = useState(false);
  const totalSteps = 5;
  
  const progress = (currentStep / totalSteps) * 100;
  
  const handleNext = () => {
    if (currentStep < totalSteps) {
      setCurrentStep(currentStep + 1);
    } else {
      onPublish();
    }
  };
  
  const handleBack = () => {
    if (currentStep > 1) {
      setCurrentStep(currentStep - 1);
    } else {
      onBack();
    }
  };
  
  return (
    <div className="min-h-screen bg-white flex flex-col">
      <AppBar 
        title="Create Listing" 
        showBack 
        onBack={handleBack}
      />
      
      {/* Progress Bar */}
      <div className="px-4 py-4">
        <div className="flex items-center justify-between mb-2">
          <span className="text-[#666666] text-sm">Step {currentStep} of {totalSteps}</span>
          <span className="text-[#006D3B]">{Math.round(progress)}%</span>
        </div>
        <div className="h-2 bg-[#E8F5F0] rounded-full overflow-hidden">
          <div 
            className="h-full bg-[#006D3B] transition-all duration-300"
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>
      
      <div className="flex-1 overflow-y-auto px-4 py-6">
        {/* Step 1: Photos */}
        {currentStep === 1 && (
          <div className="space-y-4">
            <div>
              <h2 className="text-[#1A1A1A] mb-2 text-xl font-bold">Add Photos</h2>
              <p className="text-[#666666]">Upload at least 1 photo of your food</p>
            </div>
            
            <div className="grid grid-cols-2 gap-4">
              <button className="aspect-square border-2 border-dashed border-[#006D3B] rounded-2xl flex flex-col items-center justify-center gap-3 hover:bg-[#E8F5F0] transition-colors">
                <Camera className="text-[#006D3B]" size={32} />
                <span className="text-[#006D3B] text-sm">Take Photo</span>
              </button>
              
              <button className="aspect-square border-2 border-dashed border-[#006D3B] rounded-2xl flex flex-col items-center justify-center gap-3 hover:bg-[#E8F5F0] transition-colors">
                <Upload className="text-[#006D3B]" size={32} />
                <span className="text-[#006D3B] text-sm">Upload</span>
              </button>
            </div>
            
            <div className="bg-[#E8F5F0] border border-[#006D3B] rounded-xl p-4">
              <p className="text-[#006D3B] text-sm">
                📸 <strong>Tip:</strong> Clear, well-lit photos get 3x more reservations!
              </p>
            </div>
          </div>
        )}
        
        {/* Step 2: Basic Info */}
        {currentStep === 2 && (
          <div className="space-y-6">
            <div>
              <h2 className="text-[#1A1A1A] mb-2 text-xl font-bold">Basic Details</h2>
              <p className="text-[#666666]">Tell us about your food</p>
            </div>
            
            <div>
              <label className="text-[#666666] text-sm mb-2 block">Dish Name *</label>
              <input
                type="text"
                placeholder="e.g., Homemade Biryani"
                className="w-full px-4 py-3 border border-[#E0E0E0] rounded-xl focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20"
              />
            </div>
            
            <div>
              <label className="text-[#666666] text-sm mb-2 block">Description *</label>
              <textarea
                placeholder="Describe your food, ingredients, taste..."
                rows={4}
                className="w-full px-4 py-3 border border-[#E0E0E0] rounded-xl focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20 resize-none"
              />
            </div>
            
            <div>
              <label className="text-[#666666] text-sm mb-2 block">Cuisine Type *</label>
              <select className="w-full px-4 py-3 border border-[#E0E0E0] rounded-xl focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20 bg-white">
                <option>Select cuisine</option>
                <option>Indian</option>
                <option>Italian</option>
                <option>Chinese</option>
                <option>Mexican</option>
                <option>Dessert</option>
                <option>Other</option>
              </select>
            </div>
            
            <div>
              <label className="text-[#666666] text-sm mb-2 block">Dietary Type *</label>
              <div className="flex gap-3">
                <button className="flex-1 py-3 border-2 border-[#006D3B] bg-[#006D3B] text-white rounded-xl">
                  🥬 Veg
                </button>
                <button className="flex-1 py-3 border-2 border-[#E0E0E0] text-[#666666] rounded-xl hover:border-[#006D3B]">
                  🍗 Non-Veg
                </button>
              </div>
            </div>
          </div>
        )}
        
        {/* Step 3: Quantity & Pricing */}
        {currentStep === 3 && (
          <div className="space-y-6">
            <div>
              <h2 className="text-[#1A1A1A] mb-2 text-xl font-bold">Quantity & Price</h2>
              <p className="text-[#666666]">Set your portions and pricing</p>
            </div>
            
            <div>
              <label className="text-[#666666] text-sm mb-2 block">Serves *</label>
              <select className="w-full px-4 py-3 border border-[#E0E0E0] rounded-xl focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20 bg-white">
                <option>Select servings</option>
                <option>1 person</option>
                <option>2 persons</option>
                <option>3-4 persons</option>
                <option>5+ persons</option>
              </select>
            </div>
            
            <div className="bg-[#E8F5F0] rounded-xl p-4">
              <div className="flex items-center justify-between mb-2">
                <div>
                  <h3 className="text-[#1A1A1A] mb-1 font-bold">Offer for Free?</h3>
                  <p className="text-[#666666] text-sm">Share food without charging</p>
                </div>
                <button
                  onClick={() => setIsFree(!isFree)}
                  className={`w-14 h-8 rounded-full transition-colors relative ${
                    isFree ? 'bg-[#006D3B]' : 'bg-[#BDBDBD]'
                  }`}
                >
                  <div className={`absolute top-1 w-6 h-6 rounded-full bg-white transition-transform ${
                    isFree ? 'translate-x-7' : 'translate-x-1'
                  }`} />
                </button>
              </div>
            </div>
            
            {!isFree && (
              <div>
                <label className="text-[#666666] text-sm mb-2 block">Price (₹) *</label>
                <div className="relative">
                  <span className="absolute left-4 top-1/2 -translate-y-1/2 text-[#666666]">₹</span>
                  <input
                    type="number"
                    placeholder="0"
                    className="w-full pl-10 pr-4 py-3 border border-[#E0E0E0] rounded-xl focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20"
                  />
                </div>
                <p className="text-[#666666] text-sm mt-2">
                  💡 Suggested: ₹50-150 based on quantity
                </p>
              </div>
            )}
          </div>
        )}
        
        {/* Step 4: Availability */}
        {currentStep === 4 && (
          <div className="space-y-6">
            <div>
              <h2 className="text-[#1A1A1A] mb-2 text-xl font-bold">Availability</h2>
              <p className="text-[#666666]">When can people collect the food?</p>
            </div>
            
            <div>
              <label className="text-[#666666] text-sm mb-2 block">Available Date *</label>
              <input
                type="date"
                className="w-full px-4 py-3 border border-[#E0E0E0] rounded-xl focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20"
              />
            </div>
            
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="text-[#666666] text-sm mb-2 block">From Time *</label>
                <input
                  type="time"
                  className="w-full px-4 py-3 border border-[#E0E0E0] rounded-xl focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20"
                />
              </div>
              <div>
                <label className="text-[#666666] text-sm mb-2 block">To Time *</label>
                <input
                  type="time"
                  className="w-full px-4 py-3 border border-[#E0E0E0] rounded-xl focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20"
                />
              </div>
            </div>
            
            <div className="bg-[#FFF3E0] border border-[#FFA726] rounded-xl p-4">
              <p className="text-[#FFA726] text-sm">
                ⏰ <strong>Best before:</strong> Make sure to mention if food needs to be collected by a specific time
              </p>
            </div>
          </div>
        )}
        
        {/* Step 5: Location */}
        {currentStep === 5 && (
          <div className="space-y-6">
            <div>
              <h2 className="text-[#1A1A1A] mb-2 text-xl font-bold">Pickup Location</h2>
              <p className="text-[#666666]">Where should people collect from?</p>
            </div>
            
            <div className="bg-[#E8F5F0] rounded-2xl h-48 flex items-center justify-center overflow-hidden relative">
              <svg className="w-full h-full" xmlns="http://www.w3.org/2000/svg">
                <defs>
                  <pattern id="locationGrid" width="30" height="30" patternUnits="userSpaceOnUse">
                    <path d="M 30 0 L 0 0 0 30" fill="none" stroke="#D0E8DC" strokeWidth="0.5"/>
                  </pattern>
                </defs>
                <rect width="100%" height="100%" fill="url(#locationGrid)" />
              </svg>
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="w-16 h-16 bg-[#006D3B] rounded-full flex items-center justify-center shadow-lg">
                  <MapPin className="text-white" size={32} />
                </div>
              </div>
            </div>
            
            <CravnButton variant="outline" fullWidth>
              <MapPin size={20} />
              Use Current Location
            </CravnButton>
            
            <div>
              <label className="text-[#666666] text-sm mb-2 block">Address *</label>
              <textarea
                placeholder="Enter your pickup address..."
                rows={3}
                className="w-full px-4 py-3 border border-[#E0E0E0] rounded-xl focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20 resize-none"
              />
            </div>
            
            <div>
              <label className="text-[#666666] text-sm mb-2 block">Landmark (Optional)</label>
              <input
                type="text"
                placeholder="e.g., Near Metro Station"
                className="w-full px-4 py-3 border border-[#E0E0E0] rounded-xl focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20"
              />
            </div>
          </div>
        )}
      </div>
      
      {/* Bottom CTA */}
      <div className="border-t border-[#E0E0E0] p-4">
        <CravnButton 
          variant="primary" 
          size="large" 
          fullWidth
          onClick={handleNext}
        >
          {currentStep === totalSteps ? 'Publish Listing' : 'Next'}
        </CravnButton>
      </div>
    </div>
  );
}
