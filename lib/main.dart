import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/route_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/rep_provider.dart';
import 'providers/visit_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/rep_dashboard_provider.dart';
import 'providers/admin_dashboard_provider.dart';
import 'providers/report_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/location_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboards/admin_dashboard.dart';
import 'screens/dashboards/rep_dashboard.dart';
import 'screens/dashboards/customer_dashboard.dart';
import 'screens/splash/splash_loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => RepProvider()),
        ChangeNotifierProvider(create: (_) => VisitProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => RepDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SalePro',
          themeMode: settings.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading spinner while checking initial auth state
        if (authProvider.isLoading) {
          return const SplashLoadingScreen();
        }

        // If no user is logged in, show Login Screen
        if (authProvider.currentUserModel == null) {
          return const LoginScreen();
        }

        // Navigate based on Role
        final role = authProvider.currentUserModel!.role.toLowerCase();
        switch (role) {
          case 'admin':
            return const AdminDashboard();
          case 'rep':
            return const RepDashboard();
          case 'customer':
          default:
            return const CustomerDashboard();
        }
      },
    );
  }
}
