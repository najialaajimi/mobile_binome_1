// Bottom-navigation tab tests
//
// Verifies that tapping each tab in the owner and tenant bottom navigation bars
// switches to the expected page without errors.
//
// Run with: flutter test test/navigation/bottom_navigation_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:logement_app/main.dart' show LogementApp;
import 'package:logement_app/utils/routes.dart';

// ── helpers ──────────────────────────────────────────────────────────────────

Future<void> _seedPrefs({String role = 'tenant'}) async {
  final tenantJson =
      '{"id":"tenant_1","fullName":"Ahmed Test","email":"locataire@test.com",'
      '"password":"dGVzdDEyMw==","role":"tenant","isVerified":true,'
      '"avatarUrl":null,"createdAt":"2024-01-01T00:00:00.000Z",'
      '"isStudent":true,"studyField":"informatique","nationality":"Tunisien",'
      '"preferredLanguage":"fr"}';

  final ownerJson =
      '{"id":"owner_1","fullName":"Karim Test","email":"proprietaire@test.com",'
      '"password":"dGVzdDEyMw==","role":"owner","isVerified":true,'
      '"avatarUrl":null,"createdAt":"2024-01-01T00:00:00.000Z",'
      '"isStudent":false,"studyField":null,"nationality":"Tunisien",'
      '"preferredLanguage":"fr"}';

  SharedPreferences.setMockInitialValues({
    'auth_seeded_v2': true,
    'users': [tenantJson, ownerJson],
    'current_user': role == 'tenant' ? tenantJson : ownerJson,
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

/// Navigates to [route] and waits for the page to settle.
Future<void> _goto(WidgetTester tester, String route) async {
  await tester.pumpWidget(const LogementApp());
  await tester.pump();
  final ctx = tester.element(find.byType(MaterialApp).first);
  Navigator.pushReplacementNamed(ctx, route);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

// ═════════════════════════════════════════════════════════════════════════════

void main() {
  // ── Tenant bottom navigation ─────────────────────────────────────────────

  group('Tenant bottom navigation (TenantHomeScreen)', () {
    setUp(() async => _seedPrefs(role: 'tenant'));

    testWidgets('renders 5-item bottom navigation bar', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.items.length, equals(5));
    });

    testWidgets('tab 0 — Accueil is the default selected tab', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.currentIndex, equals(0));
    });

    testWidgets('tab 1 — Recherche is tappable', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);

      await tester.tap(find.byIcon(Icons.search).first);
      await tester.pumpAndSettle();

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.currentIndex, equals(1));
    });

    testWidgets('tab 2 — Favoris is tappable', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);

      await tester.tap(find.byIcon(Icons.favorite_outline).first);
      await tester.pumpAndSettle();

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.currentIndex, equals(2));
    });

    testWidgets('tab 3 — Visites is tappable', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);

      await tester.tap(find.byIcon(Icons.calendar_today_outlined).first);
      await tester.pumpAndSettle();

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.currentIndex, equals(3));
    });

    testWidgets('tab 4 — Profil is tappable', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);

      await tester.tap(find.byIcon(Icons.person_outline).first);
      await tester.pumpAndSettle();

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.currentIndex, equals(4));
    });

    testWidgets('bottom nav label Accueil is displayed', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);
      expect(find.text('Accueil'), findsWidgets);
    });

    testWidgets('bottom nav label Recherche is displayed', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);
      expect(find.text('Recherche'), findsWidgets);
    });

    testWidgets('bottom nav label Favoris is displayed', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);
      expect(find.text('Favoris'), findsWidgets);
    });

    testWidgets('bottom nav label Visites is displayed', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);
      expect(find.text('Visites'), findsWidgets);
    });

    testWidgets('bottom nav label Profil is displayed', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);
      expect(find.text('Profil'), findsWidgets);
    });
  });

  // ── Owner bottom navigation ───────────────────────────────────────────────

  group('Owner bottom navigation (OwnerDashboardScreen)', () {
    setUp(() async => _seedPrefs(role: 'owner'));

    testWidgets('renders 5-item bottom navigation bar', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.items.length, equals(5));
    });

    testWidgets('tab 0 — Tableau de bord is default', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.currentIndex, equals(0));
    });

    testWidgets('tab 1 — Annonces is tappable', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);

      await tester.tap(find.byIcon(Icons.list_alt_outlined).first);
      await tester.pumpAndSettle();

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.currentIndex, equals(1));
    });

    testWidgets('tab 2 — Candidatures is tappable', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);

      await tester.tap(find.byIcon(Icons.assignment_outlined).first);
      await tester.pumpAndSettle();

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.currentIndex, equals(2));
    });

    testWidgets('tab 3 — Agenda is tappable', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);

      await tester.tap(find.byIcon(Icons.calendar_month_outlined).first);
      await tester.pumpAndSettle();

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.currentIndex, equals(3));
    });

    testWidgets('tab 4 — Profil is tappable', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);

      // Person icon — also appears in top items on the dashboard; target last
      final personIcons = find.byIcon(Icons.person_outline);
      await tester.tap(personIcons.last);
      await tester.pumpAndSettle();

      final bar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar));
      expect(bar.currentIndex, equals(4));
    });

    testWidgets('bottom nav label Tableau de bord is displayed',
        (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);
      expect(find.text('Tableau de bord'), findsWidgets);
    });

    testWidgets('bottom nav label Annonces is displayed', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);
      expect(find.text('Annonces'), findsWidgets);
    });

    testWidgets('bottom nav label Candidatures is displayed', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);
      expect(find.text('Candidatures'), findsWidgets);
    });

    testWidgets('bottom nav label Agenda is displayed', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);
      expect(find.text('Agenda'), findsWidgets);
    });

    testWidgets('bottom nav label Profil is displayed', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);
      expect(find.text('Profil'), findsWidgets);
    });
  });

  // ── Owner tab content spot-checks ────────────────────────────────────────

  group('Owner tab content', () {
    setUp(() async => _seedPrefs(role: 'owner'));

    testWidgets('Agenda tab shows calendar grid', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);

      await tester.tap(find.byIcon(Icons.calendar_month_outlined).first);
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('Candidatures tab shows TabBar', (tester) async {
      await _goto(tester, AppRoutes.ownerDashboard);

      await tester.tap(find.byIcon(Icons.assignment_outlined).first);
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
    });
  });

  // ── Tenant tab content spot-checks ───────────────────────────────────────

  group('Tenant tab content', () {
    setUp(() async => _seedPrefs(role: 'tenant'));

    testWidgets('Visites tab shows TabBar with Calendrier tab', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);

      await tester.tap(find.byIcon(Icons.calendar_today_outlined).first);
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Calendrier'), findsOneWidget);
    });

    testWidgets('Profil tab shows logout button', (tester) async {
      await _goto(tester, AppRoutes.tenantHome);

      await tester.tap(find.byIcon(Icons.person_outline).first);
      await tester.pumpAndSettle();

      expect(find.text('Se déconnecter'), findsOneWidget);
    });
  });
}
