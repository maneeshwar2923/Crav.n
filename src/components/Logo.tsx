import React from 'react';
// Use the exported logo from the project's assets folder. Placed at `assets/images/Logo.png`
const logoImage = '/assets/images/Logo.png';

interface LogoProps {
  size?: 'small' | 'medium' | 'large';
  variant?: 'full' | 'icon';
  theme?: 'light' | 'dark';
  className?: string;
}

export function Logo({ 
  size = 'medium', 
  variant = 'full', 
  theme = 'light',
  className = '' 
}: LogoProps) {
  const sizeMap = {
    small: { height: 'h-8', width: 'w-auto' },
    medium: { height: 'h-16', width: 'w-auto' },
    large: { height: 'h-32', width: 'w-auto' }
  };

  const heightClass = sizeMap[size].height;
  
  // For icon variant, we'll show a square crop of the logo
  if (variant === 'icon') {
    return (
      <div className={className}>
        <img 
          src={logoImage} 
          alt="Crav'n" 
          className={`${heightClass} w-auto object-contain`}
        />
      </div>
    );
  }

  // Full logo
  return (
    <div className={`flex items-center ${className}`}>
      <img 
        src={logoImage} 
        alt="Crav'n" 
        className={`${heightClass} w-auto object-contain`}
      />
    </div>
  );
}
