import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF003c8f);
  static const primaryLight = Color(0xFF5e92f3);
  static const secondary = Color(0xFFFFA000);
  static const secondaryDark = Color(0xFFc67100);
  static const secondaryLight = Color(0xFFffd149);
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFD32F2F);
  static const success = Color(0xFF388E3C);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const cardShadow = Color(0x14000000);
}

class AppConstants {
  static const appName = 'Logement';
  static const appTagline = 'Trouvez votre chez-vous';

  static const roleTenant = 'tenant';
  static const roleOwner = 'owner';
  static const roleAdmin = 'admin';

  static const propertyTypes = [
    'apartment',
    'house',
    'studio',
    'room',
    'colocation',
  ];

  static const propertyTypeLabels = {
    'apartment': 'Appartement',
    'house': 'Maison',
    'studio': 'Studio',
    'room': 'Chambre',
    'colocation': 'Colocation',
  };

  static const propertyTypeIcons = {
    'apartment': Icons.apartment,
    'house': Icons.house,
    'studio': Icons.meeting_room,
    'room': Icons.bed,
    'colocation': Icons.people,
  };

  static const List<Color> listingColors = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFE65100),
    Color(0xFF00695C),
    Color(0xFF4527A0),
    Color(0xFF283593),
    Color(0xFF558B2F),
  ];
}
