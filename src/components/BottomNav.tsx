import React from 'react';
import { Home, Map, PlusCircle, MessageCircle, User } from 'lucide-react';

interface BottomNavProps {
  activeTab: 'home' | 'map' | 'create' | 'messages' | 'profile';
  onTabChange: (tab: 'home' | 'map' | 'create' | 'messages' | 'profile') => void;
}

export function BottomNav({ activeTab, onTabChange }: BottomNavProps) {
  const tabs = [
    { id: 'home' as const, icon: Home, label: 'Home' },
    { id: 'map' as const, icon: Map, label: 'Map' },
    { id: 'create' as const, icon: PlusCircle, label: 'Create' },
    { id: 'messages' as const, icon: MessageCircle, label: 'Chat' },
    { id: 'profile' as const, icon: User, label: 'Profile' }
  ];

  return (
    <div className="bg-white border-t border-[#E0E0E0] sticky bottom-0 z-50">
      <div className="max-w-md mx-auto px-2 py-2 flex items-center justify-around">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;
          
          return (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
              className={`flex flex-col items-center gap-1 px-4 py-2 rounded-lg transition-all ${
                isActive 
                  ? 'text-[#006D3B] bg-[#E8F5F0]' 
                  : 'text-[#999999] hover:text-[#666666]'
              }`}
            >
              <Icon size={24} strokeWidth={isActive ? 2.5 : 2} />
              <span className={`text-xs ${isActive ? 'font-semibold' : ''}`}>{tab.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
