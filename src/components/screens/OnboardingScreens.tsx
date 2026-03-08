import React, { useState } from 'react';
import { CravnButton } from '../CravnButton';
import { MapPin, Heart, Users } from 'lucide-react';

interface OnboardingScreensProps {
  onComplete: () => void;
}

export function OnboardingScreens({ onComplete }: OnboardingScreensProps) {
  const [currentScreen, setCurrentScreen] = useState(0);
  
  const screens = [
    {
      title: 'Reduce Food Waste',
      description: 'Share excess food with your community instead of throwing it away',
      illustration: (
        <div className="w-full h-64 flex items-center justify-center gap-8">
          <div className="flex flex-col items-center gap-4">
            <div className="text-6xl">🗑️</div>
            <div className="text-red-500 line-through">Waste</div>
          </div>
          <div className="text-4xl text-[#006D3B]">→</div>
          <div className="flex flex-col items-center gap-4">
            <div className="text-6xl">🤝</div>
            <div className="text-[#006D3B]">Share</div>
          </div>
        </div>
      )
    },
    {
      title: 'Find Food Nearby',
      description: 'Discover delicious meals shared by people in your neighborhood',
      illustration: (
        <div className="w-full h-64 flex items-center justify-center relative">
          <div className="w-64 h-64 rounded-3xl bg-[#E8F5F0] flex items-center justify-center relative overflow-hidden">
            <MapPin className="text-[#006D3B] absolute" size={80} style={{ top: '20%', left: '30%' }} />
            <MapPin className="text-[#006D3B] absolute" size={60} style={{ top: '50%', left: '60%' }} />
            <MapPin className="text-[#006D3B] absolute" size={70} style={{ top: '60%', left: '20%' }} />
            <div className="absolute inset-0 bg-gradient-to-br from-[#006D3B]/10 to-transparent" />
          </div>
        </div>
      )
    },
    {
      title: 'Eco-Friendly Community',
      description: 'Join thousands making a difference, one meal at a time',
      illustration: (
        <div className="w-full h-64 flex items-center justify-center">
          <div className="flex items-center gap-4">
            <div className="flex flex-col items-center gap-2">
              <div className="w-20 h-20 rounded-full bg-[#006D3B] flex items-center justify-center">
                <Users className="text-white" size={40} />
              </div>
              <div className="text-sm text-[#666666]">Community</div>
            </div>
            <Heart className="text-[#4CAF50]" size={40} fill="#4CAF50" />
            <div className="flex flex-col items-center gap-2">
              <div className="text-6xl">🌍</div>
              <div className="text-sm text-[#666666]">Planet</div>
            </div>
          </div>
        </div>
      )
    }
  ];
  
  const handleNext = () => {
    if (currentScreen < screens.length - 1) {
      setCurrentScreen(currentScreen + 1);
    } else {
      onComplete();
    }
  };
  
  const handleSkip = () => {
    onComplete();
  };
  
  return (
    <div className="min-h-screen bg-white flex flex-col">
      <div className="flex-1 flex flex-col items-center justify-center px-6 py-12">
        {/* Progress Indicators */}
        <div className="flex gap-2 mb-12">
          {screens.map((_, index) => (
            <div
              key={index}
              className={`h-1.5 rounded-full transition-all ${
                index === currentScreen 
                  ? 'w-8 bg-[#006D3B]' 
                  : 'w-1.5 bg-[#E0E0E0]'
              }`}
            />
          ))}
        </div>
        
        {/* Illustration */}
        <div className="mb-8">
          {screens[currentScreen].illustration}
        </div>
        
        {/* Content */}
        <div className="text-center max-w-sm">
          <h2 className="text-[#006D3B] mb-4 font-bold text-2xl">
            {screens[currentScreen].title}
          </h2>
          <p className="text-[#666666] text-base">
            {screens[currentScreen].description}
          </p>
        </div>
      </div>
      
      {/* Navigation Buttons */}
      <div className="px-6 pb-8 flex gap-4">
        <CravnButton
          variant="outline"
          size="large"
          onClick={handleSkip}
          className="flex-1"
        >
          Skip
        </CravnButton>
        <CravnButton
          variant="primary"
          size="large"
          onClick={handleNext}
          className="flex-1"
        >
          {currentScreen === screens.length - 1 ? 'Get Started' : 'Next'}
        </CravnButton>
      </div>
    </div>
  );
}
