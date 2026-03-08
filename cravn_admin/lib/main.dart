import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/supabase_admin_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseAdminService.initialize();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('[main] Firebase initialized');
  } catch (e) {
    debugPrint('[main] Firebase initialize failed: $e');
  }
  
  runApp(const CravnAdminApp());
}
