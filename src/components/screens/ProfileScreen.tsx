import React from 'react';
import { AppBar } from '../AppBar';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { Edit2, Star, Package, Award, Heart, Settings, HelpCircle, LogOut, ChevronRight } from 'lucide-react';

export function ProfileScreen() {
  const stats = [
    { label: 'Food Shared', value: '12', icon: Package },
    { label: 'Rating', value: '4.8', icon: Star },
    { label: 'Impact', value: '8kg', icon: Award }
  ];
  
  const menuItems = [
    { label: 'My Listings', icon: Package, badge: '3 active' },
    { label: 'Favorites', icon: Heart, badge: null },
    { label: 'Settings', icon: Settings, badge: null },
    { label: 'Help & Support', icon: HelpCircle, badge: null },
    { label: 'Logout', icon: LogOut, badge: null, danger: true }
  ];
  
  return (
    <div className="min-h-screen bg-[#F5F5F5] pb-20">
      <AppBar title="Profile" showMenu onMenu={() => console.log('Menu')} />
      
      {/* Profile Header */}
      <div className="bg-[#006D3B] pt-6 pb-12 px-4">
        <div className="flex flex-col items-center">
          <div className="relative">
            <ImageWithFallback
              src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop"
              alt="Profile"
              className="w-24 h-24 rounded-full border-4 border-white object-cover"
            />
            <button className="absolute bottom-0 right-0 w-8 h-8 bg-white rounded-full flex items-center justify-center shadow-lg">
              <Edit2 className="text-[#006D3B]" size={14} />
            </button>
          </div>
          
          <div className="mt-4 text-center">
            <div className="flex items-center justify-center gap-2 mb-1">
              <h2 className="text-white text-xl font-bold">Priya Sharma</h2>
              <div className="bg-white/20 text-white px-2 py-0.5 rounded-full text-xs">
                Verified
              </div>
            </div>
            <p className="text-white/80 text-sm">Member since Jan 2024</p>
          </div>
        </div>
      </div>
      
      {/* Stats Cards */}
      <div className="px-4 -mt-8 mb-6">
        <div className="bg-white rounded-2xl shadow-lg p-4">
          <div className="grid grid-cols-3 divide-x divide-[#E0E0E0]">
            {stats.map((stat, index) => {
              const Icon = stat.icon;
              return (
                <div key={index} className="flex flex-col items-center py-2">
                  <Icon className="text-[#006D3B] mb-2" size={24} />
                  <div className="text-[#1A1A1A] mb-1 text-xl font-bold">{stat.value}</div>
                  <div className="text-[#666666] text-xs text-center">{stat.label}</div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
      
      {/* Impact Badge */}
      <div className="px-4 mb-6">
        <div className="bg-gradient-to-r from-[#006D3B] to-[#008C4D] rounded-2xl p-6 text-white">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="mb-2 text-xl font-bold">Eco Warrior 🌱</h3>
              <p className="text-white/90 text-sm mb-3">You've saved 8kg of food from waste!</p>
              <div className="bg-white/20 rounded-full h-2 overflow-hidden">
                <div className="bg-white h-full w-4/5" />
              </div>
              <p className="text-white/80 text-xs mt-2">2kg to next badge</p>
            </div>
          </div>
        </div>
      </div>
      
      {/* Menu Items */}
      <div className="px-4">
        <div className="bg-white rounded-2xl overflow-hidden divide-y divide-[#E0E0E0]">
          {menuItems.map((item, index) => {
            const Icon = item.icon;
            return (
              <button
                key={index}
                className={`w-full flex items-center gap-4 p-4 hover:bg-[#F5F5F5] transition-colors ${
                  item.danger ? 'text-[#F44336]' : 'text-[#1A1A1A]'
                }`}
              >
                <Icon size={20} className={item.danger ? 'text-[#F44336]' : 'text-[#006D3B]'} />
                <span className="flex-1 text-left">{item.label}</span>
                {item.badge && (
                  <span className="text-[#666666] text-sm">{item.badge}</span>
                )}
                <ChevronRight size={20} className="text-[#BDBDBD]" />
              </button>
            );
          })}
        </div>
      </div>
      
      {/* App Version */}
      <div className="px-4 mt-6 text-center">
        <p className="text-[#999999] text-sm">Crav'n v1.0.0</p>
      </div>
    </div>
  );
}
