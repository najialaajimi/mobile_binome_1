class UserPreferences {
  final String userId;
  final double? budgetMin;
  final double? budgetMax;
  final List<String> preferredTypes;
  final String lifestyle;
  final bool isStudent;
  final String studyField;
  final String nearUniversity;
  final String preferredLanguage;
  final String nationality;
  final int? minRooms;
  final int? maxRooms;
  final double? minSurface;
  final bool? wantFurnished;
  final int leaseDurationMonths;
  final List<String> searchHistory;

  const UserPreferences({
    required this.userId,
    this.budgetMin,
    this.budgetMax,
    this.preferredTypes = const [],
    this.lifestyle = 'any',
    this.isStudent = false,
    this.studyField = '',
    this.nearUniversity = 'any',
    this.preferredLanguage = 'fr',
    this.nationality = '',
    this.minRooms,
    this.maxRooms,
    this.minSurface,
    this.wantFurnished,
    this.leaseDurationMonths = 6,
    this.searchHistory = const [],
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'preferredTypes': preferredTypes,
        'lifestyle': lifestyle,
        'isStudent': isStudent,
        'studyField': studyField,
        'nearUniversity': nearUniversity,
        'preferredLanguage': preferredLanguage,
        'nationality': nationality,
        'minRooms': minRooms,
        'maxRooms': maxRooms,
        'minSurface': minSurface,
        'wantFurnished': wantFurnished,
        'leaseDurationMonths': leaseDurationMonths,
        'searchHistory': searchHistory,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        userId: json['userId'] as String,
        budgetMin: (json['budgetMin'] as num?)?.toDouble(),
        budgetMax: (json['budgetMax'] as num?)?.toDouble(),
        preferredTypes: json['preferredTypes'] != null
            ? List<String>.from(json['preferredTypes'] as List)
            : [],
        lifestyle: json['lifestyle'] as String? ?? 'any',
        isStudent: json['isStudent'] as bool? ?? false,
        studyField: json['studyField'] as String? ?? '',
        nearUniversity: json['nearUniversity'] as String? ?? 'any',
        preferredLanguage: json['preferredLanguage'] as String? ?? 'fr',
        nationality: json['nationality'] as String? ?? '',
        minRooms: json['minRooms'] as int?,
        maxRooms: json['maxRooms'] as int?,
        minSurface: (json['minSurface'] as num?)?.toDouble(),
        wantFurnished: json['wantFurnished'] as bool?,
        leaseDurationMonths: json['leaseDurationMonths'] as int? ?? 6,
        searchHistory: json['searchHistory'] != null
            ? List<String>.from(json['searchHistory'] as List)
            : [],
      );

  UserPreferences copyWith({
    String? userId,
    double? budgetMin,
    double? budgetMax,
    List<String>? preferredTypes,
    String? lifestyle,
    bool? isStudent,
    String? studyField,
    String? nearUniversity,
    String? preferredLanguage,
    String? nationality,
    int? minRooms,
    int? maxRooms,
    double? minSurface,
    bool? wantFurnished,
    int? leaseDurationMonths,
    List<String>? searchHistory,
  }) =>
      UserPreferences(
        userId: userId ?? this.userId,
        budgetMin: budgetMin ?? this.budgetMin,
        budgetMax: budgetMax ?? this.budgetMax,
        preferredTypes: preferredTypes ?? this.preferredTypes,
        lifestyle: lifestyle ?? this.lifestyle,
        isStudent: isStudent ?? this.isStudent,
        studyField: studyField ?? this.studyField,
        nearUniversity: nearUniversity ?? this.nearUniversity,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        nationality: nationality ?? this.nationality,
        minRooms: minRooms ?? this.minRooms,
        maxRooms: maxRooms ?? this.maxRooms,
        minSurface: minSurface ?? this.minSurface,
        wantFurnished: wantFurnished ?? this.wantFurnished,
        leaseDurationMonths: leaseDurationMonths ?? this.leaseDurationMonths,
        searchHistory: searchHistory ?? this.searchHistory,
      );
}
