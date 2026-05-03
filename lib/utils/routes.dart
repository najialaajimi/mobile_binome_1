class AppRoutes {
  static const splash = '/';
  static const profileChoice = '/profile-choice';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';

  // Tenant
  static const tenantHome = '/tenant/home';
  static const tenantSearch = '/tenant/search';
  static const tenantFavorites = '/tenant/favorites';
  static const tenantBookings = '/tenant/bookings';
  static const tenantProfile = '/tenant/profile';
  static const listingDetail = '/listing/detail';

  // Owner
  static const ownerDashboard = '/owner/dashboard';
  static const ownerListings = '/owner/listings';
  static const ownerCreateListing = '/owner/create-listing';
  static const ownerApplications = '/owner/applications';
  static const ownerAgenda = '/owner/agenda';
  static const ownerProfile = '/owner/profile';

  // Admin
  static const adminDashboard = '/admin/dashboard';

  // Messaging
  static const conversations = '/messages/conversations';
  static const chat = '/messages/chat';

  // AI features
  static const aiRecommendations = '/tenant/ai-recommendations';
  static const preferences = '/tenant/preferences';
  static const roommateFinder = '/tenant/roommate-finder';
  static const listingReviews = '/listing/reviews';
  static const priceSuggestion = '/owner/price-suggestion';
  static const photoAnalysis = '/owner/photo-analysis';
  static const textFraudAnalysis = '/owner/text-fraud-analysis';
  static const virtualTour = '/listing/virtual-tour';
}
