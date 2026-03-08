import React from 'react';
import { AppBar } from '../AppBar';
import { FoodListingCard } from '../FoodListingCard';
import { Filter } from 'lucide-react';

interface HomeScreenProps {
  onFoodItemClick: (id: string) => void;
  onTabChange: (tab: string) => void;
}

export function HomeScreen({ onFoodItemClick, onTabChange }: HomeScreenProps) {
  const foodItems = [
    {
      id: '1',
      image: 'https://images.unsplash.com/photo-1605719161691-5d9771fc144f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpbmRpYW4lMjBmb29kJTIwcGxhdGV8ZW58MXx8fHwxNzYyNDA0MzExfDA&ixlib=rb-4.1.0&q=80&w=1080',
      title: 'Homemade Biryani',
      hostName: 'Priya',
      hostAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
      price: 80,
      distance: '0.5 km',
      cuisine: 'Indian',
      isVeg: true,
      rating: 4.8
    },
    {
      id: '2',
      image: 'https://images.unsplash.com/photo-1614442316719-1e38c661c29c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaXp6YSUyMGhvbWVtYWRlfGVufDF8fHx8MTc2MjMyNzYzNXww&ixlib=rb-4.1.0&q=80&w=1080',
      title: 'Fresh Margherita Pizza',
      hostName: 'Raj',
      hostAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
      price: 'free',
      distance: '1.2 km',
      cuisine: 'Italian',
      isVeg: true,
      rating: 4.9
    },
    {
      id: '3',
      image: 'https://images.unsplash.com/photo-1644704001249-0d9dbb842238?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwYXN0YSUyMGRpbm5lcnxlbnwxfHx8fDE3NjIzNTI1NTB8MA&ixlib=rb-4.1.0&q=80&w=1080',
      title: 'Creamy Pasta Bowl',
      hostName: 'Sarah',
      hostAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop',
      price: 60,
      distance: '2.1 km',
      cuisine: 'Italian',
      isVeg: true,
      rating: 4.7
    },
    {
      id: '4',
      image: 'https://images.unsplash.com/photo-1705933774160-24298027a349?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkZXNzZXJ0JTIwY2FrZXxlbnwxfHx8fDE3NjIzMDY1MTJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      title: 'Chocolate Cake',
      hostName: 'Amit',
      hostAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
      price: 'free',
      distance: '0.8 km',
      cuisine: 'Dessert',
      isVeg: true,
      rating: 5.0
    },
    {
      id: '5',
      image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzYWxhZCUyMGJvd2x8ZW58MXx8fHwxNzYyMzY3MDY4fDA&ixlib=rb-4.1.0&q=80&w=1080',
      title: 'Fresh Garden Salad',
      hostName: 'Maya',
      hostAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
      price: 40,
      distance: '1.5 km',
      cuisine: 'Healthy',
      isVeg: true,
      rating: 4.6
    },
    {
      id: '6',
      image: 'https://images.unsplash.com/photo-1694076544200-08114d9f2ef6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdXN0YWluYWJsZSUyMGZvb2R8ZW58MXx8fHwxNzYyNDA0MzEzfDA&ixlib=rb-4.1.0&q=80&w=1080',
      title: 'Organic Veggie Bowl',
      hostName: 'Kiran',
      hostAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop',
      price: 70,
      distance: '3.0 km',
      cuisine: 'Healthy',
      isVeg: true,
      rating: 4.8
    }
  ];

  return (
    // Reduced overall bottom padding to minimize extra overscroll
    <div className="min-h-screen bg-[#F5F5F5] pb-8">
      <AppBar 
        showLogo 
        logoSize="large"
        showNotifications 
        onNotifications={() => console.log('Notifications clicked')}
      />
      
      {/* Search Bar */}
      <div className="px-4 py-3 bg-white">
        <div className="flex gap-2">
          <input
            type="text"
            placeholder="Search for food..."
            className="flex-1 px-4 py-2 border border-[#E0E0E0] rounded-xl focus:outline-none focus:border-[#006D3B] focus:ring-2 focus:ring-[#006D3B]/20"
          />
          <button 
            className="p-2 bg-[#006D3B] text-white rounded-xl hover:bg-[#008C4D] transition-colors"
            onClick={() => console.log('Filter clicked')}
          >
            <Filter size={18} />
          </button>
        </div>
      </div>
      
      {/* Category Chips */}
      <div className="px-4 py-2 bg-white border-b border-[#E0E0E0] overflow-x-auto">
        <div className="flex gap-2">
          {['All', 'Free', 'Indian', 'Italian', 'Dessert', 'Healthy'].map((category) => (
            <button
              key={category}
              className={`px-4 py-2 rounded-full whitespace-nowrap transition-all ${
                category === 'All'
                  ? 'bg-[#006D3B] text-white'
                  : 'bg-white text-[#006D3B] border border-[#006D3B] hover:bg-[#E8F5F0]'
              }`}
            >
              {category}
            </button>
          ))}
        </div>
      </div>
      
      {/* Food Grid */}
      <div className="px-4 py-3">
        <div className="grid grid-cols-1 gap-3">
          {foodItems.map((item) => (
            <FoodListingCard
              key={item.id}
              {...item}
              onClick={() => onFoodItemClick(item.id)}
            />
          ))}
        </div>
      </div>
    </div>
  );
}
