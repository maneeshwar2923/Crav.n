import React, { useState } from 'react';
import { SplashScreen } from './components/screens/SplashScreen';
import { OnboardingScreens } from './components/screens/OnboardingScreens';
import { HomeScreen } from './components/screens/HomeScreen';
import { MapViewScreen } from './components/screens/MapViewScreen';
import { FoodDetailScreen } from './components/screens/FoodDetailScreen';
import { CreateListingScreen } from './components/screens/CreateListingScreen';
import { ProfileScreen } from './components/screens/ProfileScreen';
import { OrdersScreen } from './components/screens/OrdersScreen';
import { ChatScreen } from './components/screens/ChatScreen';
import { BottomNav } from './components/BottomNav';
import { Logo } from './components/Logo';

type Screen = 
  | 'splash'
  | 'onboarding'
  | 'home'
  | 'map'
  | 'foodDetail'
  | 'create'
  | 'messages'
  | 'profile'
  | 'orders'
  | 'chat';

type Tab = 'home' | 'map' | 'create' | 'messages' | 'profile';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('splash');
  const [activeTab, setActiveTab] = useState<Tab>('home');
  const [selectedFoodId, setSelectedFoodId] = useState<string | null>(null);
  
  // Simulate splash screen
  React.useEffect(() => {
    if (currentScreen === 'splash') {
      const timer = setTimeout(() => {
        setCurrentScreen('onboarding');
      }, 2000);
      return () => clearTimeout(timer);
    }
  }, [currentScreen]);
  
  const handleOnboardingComplete = () => {
    setCurrentScreen('home');
  };
  
  const handleFoodItemClick = (id: string) => {
    setSelectedFoodId(id);
    setCurrentScreen('foodDetail');
  };
  
  const handleTabChange = (tab: Tab) => {
    setActiveTab(tab);
    
    switch (tab) {
      case 'home':
        setCurrentScreen('home');
        break;
      case 'map':
        setCurrentScreen('map');
        break;
      case 'create':
        setCurrentScreen('create');
        break;
      case 'messages':
        setCurrentScreen('orders');
        break;
      case 'profile':
        setCurrentScreen('profile');
        break;
    }
  };
  
  const handleReserve = () => {
    alert('Reservation confirmed! Check your orders.');
    setCurrentScreen('orders');
    setActiveTab('messages');
  };
  
  const handlePublish = () => {
    alert('Listing published successfully!');
    setCurrentScreen('home');
    setActiveTab('home');
  };
  
  // Screens without bottom nav
  const screensWithoutNav: Screen[] = ['splash', 'onboarding', 'foodDetail', 'create', 'chat'];
  const showBottomNav = !screensWithoutNav.includes(currentScreen);
  
  return (
    <div className="min-h-screen bg-[#F5F5F5]">
      <div className="mobile-container">
      {/* Render current screen */}
      {currentScreen === 'splash' && <SplashScreen />}
      
      {currentScreen === 'onboarding' && (
        <OnboardingScreens onComplete={handleOnboardingComplete} />
      )}
      
      {currentScreen === 'home' && (
        <HomeScreen 
          onFoodItemClick={handleFoodItemClick}
          onTabChange={(tab) => console.log('Tab:', tab)}
        />
      )}
      
      {currentScreen === 'map' && (
        <MapViewScreen onFoodItemClick={handleFoodItemClick} />
      )}
      
      {currentScreen === 'foodDetail' && (
        <FoodDetailScreen 
          onBack={() => setCurrentScreen('home')}
          onReserve={handleReserve}
        />
      )}
      
      {currentScreen === 'create' && (
        <CreateListingScreen 
          onPublish={handlePublish}
          onBack={() => {
            setCurrentScreen('home');
            setActiveTab('home');
          }}
        />
      )}
      
      {currentScreen === 'profile' && <ProfileScreen />}
      
      {currentScreen === 'orders' && <OrdersScreen />}
      
      {currentScreen === 'chat' && (
        <ChatScreen onBack={() => setCurrentScreen('orders')} />
      )}
      
      {/* Bottom Navigation */}
      {showBottomNav && (
        <BottomNav activeTab={activeTab} onTabChange={handleTabChange} />
      )}
      </div>
    </div>
  );
}
