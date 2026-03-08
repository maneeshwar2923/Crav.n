import React from 'react';
import { Logo } from '../Logo';
import { Loader2 } from 'lucide-react';

export function SplashScreen() {
  return (
    <div className="min-h-screen bg-white flex flex-col items-center justify-center px-6 relative overflow-hidden">
      {/* Subtle Food Pattern Background */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-10 left-10 text-6xl">🍕</div>
        <div className="absolute top-32 right-20 text-5xl">🥗</div>
        <div className="absolute bottom-40 left-16 text-7xl">🍜</div>
        <div className="absolute bottom-20 right-12 text-6xl">🍰</div>
        <div className="absolute top-1/2 left-1/3 text-5xl">🥘</div>
      </div>
      
      {/* Content */}
      <div className="relative z-10 flex flex-col items-center">
        <Logo size="large" variant="full" theme="light" />
        
        <p className="mt-8 text-[#006D3B] text-center max-w-xs font-semibold text-lg">
          Save Food. Save Money. Save Planet.
        </p>
        
        <div className="mt-12">
          <Loader2 className="text-[#006D3B] animate-spin" size={32} />
        </div>
      </div>
    </div>
  );
}
