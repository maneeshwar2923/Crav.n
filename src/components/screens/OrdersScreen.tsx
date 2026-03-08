import React from 'react';
import { AppBar } from '../AppBar';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { MapPin, Clock, CheckCircle, Package } from 'lucide-react';
import { CravnButton } from '../CravnButton';

export function OrdersScreen() {
  const orders = [
    {
      id: '1',
      image: 'https://images.unsplash.com/photo-1605719161691-5d9771fc144f?w=400',
      title: 'Homemade Biryani',
      host: 'Priya Sharma',
      status: 'confirmed',
      price: 80,
      pickupTime: 'Today, 6:00 PM - 8:00 PM',
      address: 'Sector 12, HSR Layout'
    },
    {
      id: '2',
      image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      title: 'Fresh Garden Salad',
      host: 'Maya Patel',
      status: 'completed',
      price: 40,
      pickupTime: 'Yesterday, 5:00 PM',
      address: 'Koramangala 4th Block'
    },
    {
      id: '3',
      image: 'https://images.unsplash.com/photo-1614442316719-1e38c661c29c?w=400',
      title: 'Fresh Margherita Pizza',
      host: 'Raj Kumar',
      status: 'pending',
      price: 'free',
      pickupTime: 'Tomorrow, 7:00 PM - 9:00 PM',
      address: 'Indiranagar'
    }
  ];
  
  const getStatusConfig = (status: string) => {
    switch (status) {
      case 'confirmed':
        return { color: 'text-[#4CAF50]', bg: 'bg-[#E8F5F0]', label: 'Confirmed', icon: CheckCircle };
      case 'completed':
        return { color: 'text-[#666666]', bg: 'bg-[#F5F5F5]', label: 'Completed', icon: CheckCircle };
      case 'pending':
        return { color: 'text-[#FFA726]', bg: 'bg-[#FFF3E0]', label: 'Pending', icon: Clock };
      default:
        return { color: 'text-[#666666]', bg: 'bg-[#F5F5F5]', label: 'Unknown', icon: Package };
    }
  };
  
  return (
    <div className="min-h-screen bg-[#F5F5F5] pb-20">
      <AppBar title="My Orders" />
      
      <div className="px-4 py-6 space-y-4">
        {orders.map((order) => {
          const statusConfig = getStatusConfig(order.status);
          const StatusIcon = statusConfig.icon;
          
          return (
            <div key={order.id} className="bg-white rounded-2xl overflow-hidden shadow-sm">
              <div className="flex gap-4 p-4">
                {/* Image */}
                <div className="w-20 h-20 rounded-xl overflow-hidden flex-shrink-0">
                  <ImageWithFallback
                    src={order.image}
                    alt={order.title}
                    className="w-full h-full object-cover"
                  />
                </div>
                
                {/* Info */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between mb-2">
                    <h3 className="text-[#1A1A1A] line-clamp-1">{order.title}</h3>
                    <div className={`px-2 py-1 rounded-full text-xs ${statusConfig.bg} ${statusConfig.color} flex items-center gap-1 whitespace-nowrap ml-2`}>
                      <StatusIcon size={12} />
                      {statusConfig.label}
                    </div>
                  </div>
                  
                  <p className="text-[#666666] text-sm mb-2">by {order.host}</p>
                  
                  <div className="flex items-center gap-2 text-[#666666] text-sm mb-2">
                    <Clock size={14} />
                    <span className="line-clamp-1">{order.pickupTime}</span>
                  </div>
                  
                  <div className="flex items-center gap-2 text-[#666666] text-sm">
                    <MapPin size={14} />
                    <span className="line-clamp-1">{order.address}</span>
                  </div>
                </div>
              </div>
              
              {/* Actions */}
              {order.status === 'confirmed' && (
                <div className="border-t border-[#E0E0E0] p-4 flex gap-2">
                  <CravnButton variant="outline" size="small" className="flex-1">
                    Get Directions
                  </CravnButton>
                  <CravnButton variant="primary" size="small" className="flex-1">
                    Contact Host
                  </CravnButton>
                </div>
              )}
              
              {order.status === 'completed' && (
                <div className="border-t border-[#E0E0E0] p-4">
                  <CravnButton variant="outline" size="small" fullWidth>
                    Rate Experience
                  </CravnButton>
                </div>
              )}
            </div>
          );
        })}
      </div>
      
      {/* Empty State Example (commented out) */}
      {/* <div className="flex flex-col items-center justify-center py-20 px-6">
        <Package className="text-[#BDBDBD] mb-4" size={64} />
        <h3 className="text-[#1A1A1A] mb-2">No orders yet</h3>
        <p className="text-[#666666] text-center mb-6">
          Start exploring and reserve delicious food near you
        </p>
        <CravnButton variant="primary">
          Explore Food
        </CravnButton>
      </div> */}
    </div>
  );
}
