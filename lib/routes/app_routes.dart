import 'package:flutter/material.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/splash_screen.dart';
import '../features/home/presentation/screens/onboarding_screens.dart';
import '../features/home/presentation/screens/food_detail_screen.dart';
import '../features/host/presentation/screens/create_listing_screen.dart';
import '../features/home/presentation/screens/map_view_screen.dart';
import '../features/home/presentation/screens/chat_screen.dart';
import '../features/home/presentation/screens/orders_screen.dart';
import '../features/home/presentation/screens/profile_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/phone_verification_screen.dart';
import '../features/profile/presentation/screens/notification_settings_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String foodDetail = '/food';
  static const String createListing = '/create';
  static const String map = '/map';
  static const String chat = '/chat';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String phoneVerify = '/phone-verify';
  static const String notificationSettings = '/notification-settings';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreens(),
    home: (context) => const HomeScreen(),
    foodDetail: (context) => const FoodDetailScreen(),
    createListing: (context) => const CreateListingScreen(),
    map: (context) => const MapViewScreen(),
    chat: (context) => const ChatScreen(),
    orders: (context) => const OrdersScreen(),
    profile: (context) => const ProfileScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignUpScreen(),
    phoneVerify: (context) => const PhoneVerificationScreen(),
    notificationSettings: (context) => const NotificationSettingsScreen(),
  };
}

