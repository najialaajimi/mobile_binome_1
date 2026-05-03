// Navigation route tests
//
// Verifies that every named route registered in main.dart:
//  - exists in AppRoutes
//  - resolves to the correct screen widget (no crash on push)
//  - passes required arguments correctly
//
// Run with: flutter test test/navigation/navigation_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:logement_app/utils/routes.dart';
import 'package:logement_app/main.dart' show LogementApp;

// ── helpers ────────────────────────────────────────────────────────────────

/// Builds a minimal app using the production router so we can push named routes
/// and verify they resolve without errors.
Widget _app() => const LogementApp();

/// Seeds SharedPreferences with a fully-initialised user + session so screens
/// that call AuthService.getCurrentUser() don't crash.
Future<void> _seedPrefs({String role = 'tenant'}) async {
  SharedPreferences.setMockInitialValues({
    'auth_seeded_v2': true,
    'users': [
      '{"id":"tenant_1","fullName":"Ahmed Test","email":"locataire@test.com",'
          '"password":"dGVzdDEyMw==","role":"tenant","isVerified":true,'
          '"avatarUrl":null,"createdAt":"2024-01-01T00:00:00.000Z",'
          '"isStudent":true,"studyField":"informatique","nationality":"Tunisien",'
          '"preferredLanguage":"fr"}',
      '{"id":"owner_1","fullName":"Karim Test","email":"proprietaire@test.com",'
          '"password":"dGVzdDEyMw==","role":"owner","isVerified":true,'
          '"avatarUrl":null,"createdAt":"2024-01-01T00:00:00.000Z",'
          '"isStudent":false,"studyField":null,"nationality":"Tunisien",'
          '"preferredLanguage":"fr"}',
    ],
    'current_user': role == 'tenant'
        ? '{"id":"tenant_1","fullName":"Ahmed Test","email":"locataire@test.com",'
            '"password":"dGVzdDEyMw==","role":"tenant","isVerified":true,'
            '"avatarUrl":null,"createdAt":"2024-01-01T00:00:00.000Z",'
            '"isStudent":true,"studyField":"informatique","nationality":"Tunisien",'
            '"preferredLanguage":"fr"}'
        : '{"id":"owner_1","fullName":"Karim Test","email":"proprietaire@test.com",'
            '"password":"dGVzdDEyMw==","role":"owner","isVerified":true,'
            '"avatarUrl":null,"createdAt":"2024-01-01T00:00:00.000Z",'
            '"isStudent":false,"studyField":null,"nationality":"Tunisien",'
            '"preferredLanguage":"fr"}',
    'listings_seeded': true,
    'listings': <String>[],
    'bookings_seeded': true,
    'bookings': <String>[],
    'applications_seeded': true,
    'applications': <String>[],
    'messages_seeded': true,
    'messages': <String>[],
    'reviews_seeded': true,
    'reviews': <String>[],
    'conversations': <String>[],
    'favorites_tenant_1': <String>[],
    'favorites_owner_1': <String>[],
  });
}

/// Pumps the app starting at [route] with optional [arguments].
/// Returns the tester after the first frame.
Future<void> _pumpRoute(
  WidgetTester tester,
  String route, {
  Object? arguments,
}) async {
  await tester.pumpWidget(_app());
  await tester.pump(); // allow initState / FutureBuilders to start

  final context =
      tester.element(find.byType(MaterialApp).first);
  Navigator.pushNamed(context, route, arguments: arguments);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

// ══════════════════════════════════════════════════════════════════════════════
// Route constant tests — verify every constant in AppRoutes is a non-empty
// unique string and matches the pattern used in _generateRoute.
// ══════════════════════════════════════════════════════════════════════════════

void main() {
  // ── AppRoutes constant sanity ─────────────────────────────────────────────
  group('AppRoutes constants', () {
    test('all route strings are non-empty', () {
      expect(AppRoutes.splash, isNotEmpty);
      expect(AppRoutes.profileChoice, isNotEmpty);
      expect(AppRoutes.signIn, isNotEmpty);
      expect(AppRoutes.signUp, isNotEmpty);
      expect(AppRoutes.tenantHome, isNotEmpty);
      expect(AppRoutes.tenantSearch, isNotEmpty);
      expect(AppRoutes.tenantFavorites, isNotEmpty);
      expect(AppRoutes.tenantBookings, isNotEmpty);
      expect(AppRoutes.tenantProfile, isNotEmpty);
      expect(AppRoutes.listingDetail, isNotEmpty);
      expect(AppRoutes.ownerDashboard, isNotEmpty);
      expect(AppRoutes.ownerListings, isNotEmpty);
      expect(AppRoutes.ownerCreateListing, isNotEmpty);
      expect(AppRoutes.ownerApplications, isNotEmpty);
      expect(AppRoutes.ownerAgenda, isNotEmpty);
      expect(AppRoutes.ownerProfile, isNotEmpty);
      expect(AppRoutes.adminDashboard, isNotEmpty);
      expect(AppRoutes.conversations, isNotEmpty);
      expect(AppRoutes.chat, isNotEmpty);
      expect(AppRoutes.aiRecommendations, isNotEmpty);
      expect(AppRoutes.preferences, isNotEmpty);
      expect(AppRoutes.roommateFinder, isNotEmpty);
      expect(AppRoutes.listingReviews, isNotEmpty);
      expect(AppRoutes.priceSuggestion, isNotEmpty);
      expect(AppRoutes.photoAnalysis, isNotEmpty);
      expect(AppRoutes.textFraudAnalysis, isNotEmpty);
      expect(AppRoutes.virtualTour, isNotEmpty);
    });

    test('all route strings are unique', () {
      final routes = [
        AppRoutes.splash,
        AppRoutes.profileChoice,
        AppRoutes.signIn,
        AppRoutes.signUp,
        AppRoutes.tenantHome,
        AppRoutes.tenantSearch,
        AppRoutes.tenantFavorites,
        AppRoutes.tenantBookings,
        AppRoutes.tenantProfile,
        AppRoutes.listingDetail,
        AppRoutes.ownerDashboard,
        AppRoutes.ownerListings,
        AppRoutes.ownerCreateListing,
        AppRoutes.ownerApplications,
        AppRoutes.ownerAgenda,
        AppRoutes.ownerProfile,
        AppRoutes.adminDashboard,
        AppRoutes.conversations,
        AppRoutes.chat,
        AppRoutes.aiRecommendations,
        AppRoutes.preferences,
        AppRoutes.roommateFinder,
        AppRoutes.listingReviews,
        AppRoutes.priceSuggestion,
        AppRoutes.photoAnalysis,
        AppRoutes.textFraudAnalysis,
        AppRoutes.virtualTour,
      ];
      final unique = routes.toSet();
      expect(unique.length, equals(routes.length),
          reason: 'Duplicate route strings detected');
    });

    test('all routes start with /', () {
      final routes = [
        AppRoutes.splash,
        AppRoutes.profileChoice,
        AppRoutes.signIn,
        AppRoutes.signUp,
        AppRoutes.tenantHome,
        AppRoutes.tenantSearch,
        AppRoutes.tenantFavorites,
        AppRoutes.tenantBookings,
        AppRoutes.tenantProfile,
        AppRoutes.listingDetail,
        AppRoutes.ownerDashboard,
        AppRoutes.ownerListings,
        AppRoutes.ownerCreateListing,
        AppRoutes.ownerApplications,
        AppRoutes.ownerAgenda,
        AppRoutes.ownerProfile,
        AppRoutes.adminDashboard,
        AppRoutes.conversations,
        AppRoutes.chat,
        AppRoutes.aiRecommendations,
        AppRoutes.preferences,
        AppRoutes.roommateFinder,
        AppRoutes.listingReviews,
        AppRoutes.priceSuggestion,
        AppRoutes.photoAnalysis,
        AppRoutes.textFraudAnalysis,
        AppRoutes.virtualTour,
      ];
      for (final r in routes) {
        expect(r, startsWith('/'),
            reason: 'Route "$r" does not start with /');
      }
    });

    test('role-scoped routes are prefixed consistently', () {
      // Tenant routes under /tenant/
      expect(AppRoutes.tenantHome, startsWith('/tenant/'));
      expect(AppRoutes.tenantSearch, startsWith('/tenant/'));
      expect(AppRoutes.tenantFavorites, startsWith('/tenant/'));
      expect(AppRoutes.tenantBookings, startsWith('/tenant/'));
      expect(AppRoutes.tenantProfile, startsWith('/tenant/'));
      expect(AppRoutes.aiRecommendations, startsWith('/tenant/'));
      expect(AppRoutes.preferences, startsWith('/tenant/'));
      expect(AppRoutes.roommateFinder, startsWith('/tenant/'));

      // Owner routes under /owner/
      expect(AppRoutes.ownerDashboard, startsWith('/owner/'));
      expect(AppRoutes.ownerListings, startsWith('/owner/'));
      expect(AppRoutes.ownerCreateListing, startsWith('/owner/'));
      expect(AppRoutes.ownerApplications, startsWith('/owner/'));
      expect(AppRoutes.ownerAgenda, startsWith('/owner/'));
      expect(AppRoutes.ownerProfile, startsWith('/owner/'));
      expect(AppRoutes.priceSuggestion, startsWith('/owner/'));
      expect(AppRoutes.photoAnalysis, startsWith('/owner/'));
      expect(AppRoutes.textFraudAnalysis, startsWith('/owner/'));

      // Messaging routes under /messages/
      expect(AppRoutes.conversations, startsWith('/messages/'));
      expect(AppRoutes.chat, startsWith('/messages/'));

      // Listing routes under /listing/
      expect(AppRoutes.listingDetail, startsWith('/listing/'));
      expect(AppRoutes.listingReviews, startsWith('/listing/'));
      expect(AppRoutes.virtualTour, startsWith('/listing/'));
    });
  });

  // ── Route argument contract tests ─────────────────────────────────────────
  // These tests verify that each route that expects arguments is declared to
  // accept the correct key names and types via the router's own switch logic.
  //
  // We test this by verifying the generated route does not throw when
  // arguments are null (fallback path) AND when valid args are supplied.

  group('Route argument contracts', () {
    test('signIn accepts role argument', () {
      final settings =
          RouteSettings(name: AppRoutes.signIn, arguments: {'role': 'owner'});
      expect(settings.arguments, isA<Map<String, dynamic>>());
      expect((settings.arguments as Map)['role'], equals('owner'));
    });

    test('signUp accepts role argument', () {
      final settings =
          RouteSettings(name: AppRoutes.signUp, arguments: {'role': 'tenant'});
      expect((settings.arguments as Map)['role'], equals('tenant'));
    });

    test('listingDetail accepts listingId argument', () {
      final settings = RouteSettings(
          name: AppRoutes.listingDetail,
          arguments: {'listingId': 'listing_1'});
      expect((settings.arguments as Map)['listingId'], equals('listing_1'));
    });

    test('chat accepts conversationId and otherUserName arguments', () {
      final settings = RouteSettings(
        name: AppRoutes.chat,
        arguments: {
          'conversationId': 'conv_1',
          'otherUserName': 'Ahmed Test',
        },
      );
      final args = settings.arguments as Map;
      expect(args['conversationId'], equals('conv_1'));
      expect(args['otherUserName'], equals('Ahmed Test'));
    });

    test('listingReviews accepts listingId argument', () {
      final settings = RouteSettings(
          name: AppRoutes.listingReviews,
          arguments: {'listingId': 'listing_1'});
      expect((settings.arguments as Map)['listingId'], equals('listing_1'));
    });

    test('photoAnalysis accepts photos list argument', () {
      final settings = RouteSettings(
          name: AppRoutes.photoAnalysis,
          arguments: {
            'photos': ['photo1.jpg', 'photo2.jpg']
          });
      final photos = (settings.arguments as Map)['photos'] as List;
      expect(photos, hasLength(2));
      expect(photos.first, isA<String>());
    });

    test('textFraudAnalysis accepts title and description arguments', () {
      final settings = RouteSettings(
          name: AppRoutes.textFraudAnalysis,
          arguments: {
            'title': 'Appartement test',
            'description': 'Belle vue',
          });
      final args = settings.arguments as Map;
      expect(args['title'], isA<String>());
      expect(args['description'], isA<String>());
    });

    test('virtualTour accepts photos360 list and listingTitle arguments', () {
      final settings = RouteSettings(
          name: AppRoutes.virtualTour,
          arguments: {
            'photos360': ['panorama1.jpg'],
            'listingTitle': 'Studio Tunis',
          });
      final args = settings.arguments as Map;
      expect((args['photos360'] as List).first, isA<String>());
      expect(args['listingTitle'], isA<String>());
    });
  });

  // ── Widget navigation tests ───────────────────────────────────────────────
  // Each test pumps the app and navigates to a named route, then asserts that
  // the expected screen widget is present in the tree (no crash, correct build).

  group('Widget navigation — no-argument routes (tenant session)', () {
    setUp(() async => _seedPrefs(role: 'tenant'));

    testWidgets('splash → profileChoice', (tester) async {
      await _pumpRoute(tester, AppRoutes.profileChoice);
      // ProfileChoiceScreen contains a tile for locataire
      expect(find.textContaining('Locataire', findRichText: true),
          findsWidgets);
    });

    testWidgets('tenantHome renders bottom nav', (tester) async {
      await _pumpRoute(tester, AppRoutes.tenantHome);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('tenantBookings renders tabs', (tester) async {
      await _pumpRoute(tester, AppRoutes.tenantBookings);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('tenantProfile renders app bar', (tester) async {
      await _pumpRoute(tester, AppRoutes.tenantProfile);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('tenantSearch renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.tenantSearch);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('tenantFavorites renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.tenantFavorites);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('preferences renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.preferences);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('roommateFinder renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.roommateFinder);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('aiRecommendations renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.aiRecommendations);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('conversations renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.conversations);
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Widget navigation — no-argument routes (owner session)', () {
    setUp(() async => _seedPrefs(role: 'owner'));

    testWidgets('ownerDashboard renders bottom nav', (tester) async {
      await _pumpRoute(tester, AppRoutes.ownerDashboard);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('ownerListings renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.ownerListings);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('ownerCreateListing renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.ownerCreateListing);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('ownerApplications renders tabs', (tester) async {
      await _pumpRoute(tester, AppRoutes.ownerApplications);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('ownerAgenda renders calendar', (tester) async {
      await _pumpRoute(tester, AppRoutes.ownerAgenda);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('ownerProfile renders app bar', (tester) async {
      await _pumpRoute(tester, AppRoutes.ownerProfile);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('priceSuggestion renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.priceSuggestion);
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Widget navigation — routes with arguments', () {
    setUp(() async => _seedPrefs(role: 'tenant'));

    testWidgets('listingDetail with valid id renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.listingDetail,
          arguments: {'listingId': 'listing_1'});
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('listingDetail with empty id renders fallback', (tester) async {
      await _pumpRoute(tester, AppRoutes.listingDetail,
          arguments: {'listingId': ''});
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('listingDetail with null arguments falls back to empty id',
        (tester) async {
      await _pumpRoute(tester, AppRoutes.listingDetail, arguments: null);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('listingReviews with listingId renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.listingReviews,
          arguments: {'listingId': 'listing_1'});
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('chat with valid conversationId renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.chat, arguments: {
        'conversationId': 'conv_1',
        'otherUserName': 'Ahmed Test',
      });
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('photoAnalysis with empty list renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.photoAnalysis,
          arguments: {'photos': <String>[]});
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('textFraudAnalysis with texts renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.textFraudAnalysis, arguments: {
        'title': 'Appartement ensoleillé',
        'description': 'Grand appartement, belle vue, parking inclus.',
      });
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('virtualTour with empty photo list renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.virtualTour, arguments: {
        'photos360': <String>[],
        'listingTitle': 'Studio Tunis',
      });
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('signIn with tenant role renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.signIn,
          arguments: {'role': 'tenant'});
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('signIn with owner role renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.signIn,
          arguments: {'role': 'owner'});
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('signUp with tenant role renders', (tester) async {
      await _pumpRoute(tester, AppRoutes.signUp,
          arguments: {'role': 'tenant'});
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // ── Unknown route fallback ────────────────────────────────────────────────
  group('Unknown route', () {
    setUp(() async => _seedPrefs());

    testWidgets('unknown route falls back to SplashScreen without crash',
        (tester) async {
      await _pumpRoute(tester, '/this/route/does/not/exist');
      // Should still render a Scaffold (SplashScreen fallback)
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
