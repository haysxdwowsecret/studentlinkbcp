
class GreetingUtils {
  /// Get time-based greeting (Good morning, Good afternoon, Good evening)
  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening';
    } else {
      return 'Good evening';
    }
  }
  
  /// Get full greeting with user's first name
  static String getFullGreeting(String fullName) {
    final greeting = getTimeBasedGreeting();
    final firstName = _getFirstName(fullName);
    return '$greeting $firstName';
  }
  
  /// Extract first name from full name
  static String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'Student';
    
    final nameParts = fullName.trim().split(' ');
    return nameParts.isNotEmpty ? nameParts.first : 'Student';
  }
}
