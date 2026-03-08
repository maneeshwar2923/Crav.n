import React from 'react';
import { ArrowLeft, Search, MoreVertical, Bell } from 'lucide-react';
import { Logo } from './Logo';

interface AppBarProps {
  title?: string;
  showBack?: boolean;
  showLogo?: boolean;
  /** logo size when showing the logo (small | medium | large) */
  logoSize?: 'small' | 'medium' | 'large';
  showSearch?: boolean;
  showNotifications?: boolean;
  showMenu?: boolean;
  onBack?: () => void;
  onSearch?: () => void;
  onNotifications?: () => void;
  onMenu?: () => void;
}

export function AppBar({
  title,
  showBack = false,
  showLogo = false,
  logoSize = 'small',
  showSearch = false,
  showNotifications = false,
  showMenu = false,
  onBack,
  onSearch,
  onNotifications,
  onMenu
}: AppBarProps) {
  return (
    <div className="bg-[#006D3B] text-white shadow-[0_2px_8px_rgba(0,109,59,0.15)] sticky top-0 z-50">
      <div className="px-4 py-3 flex items-center justify-between max-w-md mx-auto">
        {/* Left Section */}
        <div className="flex items-center gap-3">
          {showBack && (
            <button 
              onClick={onBack}
              className="p-2 -ml-2 hover:bg-white/10 rounded-lg transition-colors"
            >
              <ArrowLeft size={24} />
            </button>
          )}
          
          {showLogo && (
            <Logo size={logoSize} variant="full" theme="dark" />
          )}
          
          {title && !showLogo && (
            <h1 className="text-xl font-bold">{title}</h1>
          )}
        </div>
        
        {/* Right Section */}
        <div className="flex items-center gap-2">
          {showSearch && (
            <button 
              onClick={onSearch}
              className="p-2 hover:bg-white/10 rounded-lg transition-colors"
            >
              <Search size={20} />
            </button>
          )}
          
          {showNotifications && (
            <button 
              onClick={onNotifications}
              className="p-2 hover:bg-white/10 rounded-lg transition-colors relative"
            >
              <Bell size={20} />
              <div className="absolute top-1.5 right-1.5 w-2 h-2 bg-[#F44336] rounded-full" />
            </button>
          )}
          
          {showMenu && (
            <button 
              onClick={onMenu}
              className="p-2 hover:bg-white/10 rounded-lg transition-colors"
            >
              <MoreVertical size={20} />
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
