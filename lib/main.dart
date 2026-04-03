import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/listing_service.dart';
import 'services/booking_service.dart';
import 'services/message_service.dart';
import 'services/application_service.dart';
import 'utils/theme.dart';
import 'utils/routes.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_choice_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/tenant/home_screen.dart';
import 'screens/tenant/search_screen.dart';
import 'screens/tenant/listing_detail_screen.dart';
import 'screens/tenant/favorites_screen.dart';
import 'screens/tenant/bookings_screen.dart';
import 'screens/tenant/profile_screen.dart';
import 'screens/owner/dashboard_screen.dart';
import 'screens/owner/listings_screen.dart';
import 'screens/owner/create_listing_screen.dart';
import 'screens/owner/applications_screen.dart';
import 'screens/owner/agenda_screen.dart';
import 'screens/owner/profile_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/messaging/conversations_screen.dart';
import 'screens/messaging/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for date formatting in French
  await initializeDateFormatting('fr_FR', null);

  // Initialize storage
  await StorageService.instance.init();

  // Initialize services with seed data
  await AuthService().init();
  await ListingService().init();
  await BookingService().init();
  await MessageService().init();
  await ApplicationService().init();

  runApp(const LogementApp());
}

class LogementApp extends StatelessWidget {
  const LogementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logement',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _route(const SplashScreen());

      case AppRoutes.profileChoice:
        return _route(const ProfileChoiceScreen());

      case AppRoutes.signIn:
        final args = settings.arguments as Map<String, dynamic>?;
        final role = args?['role'] as String? ?? 'tenant';
        return _route(SignInScreen(role: role));

      case AppRoutes.signUp:
        final args = settings.arguments as Map<String, dynamic>?;
        final role = args?['role'] as String? ?? 'tenant';
        return _route(SignUpScreen(role: role));

      // Tenant routes
      case AppRoutes.tenantHome:
        return _route(const TenantHomeScreen());

      case AppRoutes.tenantSearch:
        return _route(const SearchScreen());

      case AppRoutes.listingDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final listingId = args?['listingId'] as String? ?? '';
        return _route(ListingDetailScreen(listingId: listingId));

      case AppRoutes.tenantFavorites:
        return _route(const FavoritesScreen());

      case AppRoutes.tenantBookings:
        return _route(const BookingsScreen());

      case AppRoutes.tenantProfile:
        return _route(const TenantProfileScreen());

      // Owner routes
      case AppRoutes.ownerDashboard:
        return _route(const OwnerDashboardScreen());

      case AppRoutes.ownerListings:
        return _route(const OwnerListingsScreen());

      case AppRoutes.ownerCreateListing:
        return _route(const CreateListingScreen());

      case AppRoutes.ownerApplications:
        return _route(const ApplicationsScreen());

      case AppRoutes.ownerAgenda:
        return _route(const AgendaScreen());

      case AppRoutes.ownerProfile:
        return _route(const OwnerProfileScreen());

      // Admin routes
      case AppRoutes.adminDashboard:
        return _route(const AdminDashboardScreen());

      // Messaging routes
      case AppRoutes.conversations:
        return _route(const ConversationsScreen());

      case AppRoutes.chat:
        final args = settings.arguments as Map<String, dynamic>?;
        final conversationId = args?['conversationId'] as String? ?? '';
        final otherUserName = args?['otherUserName'] as String? ?? 'Contact';
        return _route(ChatScreen(
          conversationId: conversationId,
          otherUserName: otherUserName,
        ));

      default:
        return _route(const SplashScreen());
    }
  }

  MaterialPageRoute<dynamic> _route(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
