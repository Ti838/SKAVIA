import 'package:flutter/foundation.dart';

/// Central reactive language localization service for SKAVIA.
/// Supports seamless 1-tap instant switching between English and Bengali (বাংলা)
/// matching bKash's world-class bilingual experience with zero reload glitches.
class AppLanguageService {
  static final AppLanguageService _instance = AppLanguageService._internal();
  factory AppLanguageService() => _instance;
  AppLanguageService._internal();

  /// Reactive notifier holding currently active language code ('en' or 'bn')
  static final ValueNotifier<String> localeNotifier = ValueNotifier<String>(
    'en',
  );

  static bool get isBengali => localeNotifier.value == 'bn';

  static void toggleLanguage() {
    localeNotifier.value = isBengali ? 'en' : 'bn';
  }

  static void setLanguage(String code) {
    if (code == 'en' || code == 'bn') {
      localeNotifier.value = code;
    }
  }

  /// Bilingual translation dictionary
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'SKAVIA',
      'client_mode': 'Client Mode',
      'worker_mode': 'Worker Mode',
      'client': 'Client',
      'worker': 'Worker',
      'hello': 'Hello',
      'welcome_subtitle': 'Verified on-demand services in',
      'worker_hub_title': 'Worker & Client Hub',
      'worker_hub_subtitle': 'Manage shifts, live requests & earnings',
      'search_hint': 'Search services, skills, or people...',
      'radar_title': 'Radar',
      'pros_active': 'Pros Active',
      'min_arrival': 'min arrival',
      'expand_radar': 'Radar',
      'book_service': 'Book Service',
      'post_job': 'Post Job',
      'earn_shifts': 'Earn / Shifts',
      'skavia_ai': 'SKAVIA AI',
      'skavia_ai_badge': 'SKAVIA AI',
      'skavia_ai_desc':
          'Proprietary AI diagnostics & instant project estimation',
      'active_service': 'Live Service in Progress',
      'view_otp': 'View Job OTP',
      'verified_shield': 'SKAVIA Verified Shield',
      'escrow_active': 'Escrow Protection Active',
      'featured_services': 'Featured Services',
      'see_all': 'See All',
      'electrical_title': 'Electrical Repair & Wiring',
      'electrical_desc': 'Certified Master Electricians',
      'ac_title': 'HVAC & AC Maintenance',
      'ac_desc': 'Gas Refill, Servicing & Repair',
      'plumbing_title': 'Sanitary & Plumbing',
      'plumbing_desc': 'Pipe Fitting & Water Systems',
      'turnkey_title': 'Business & Office Turnkey Hub',
      'turnkey_desc': 'Full setup for Office, Showroom or IT Hub with a Dedicated Team Leader.',
      'nid_verified': '100% NID Verified',
      'escrow_protected': 'Escrow Protected',
      'helpline': '24/7 Helpline',
      'earnings': 'Earnings',
      'completed_jobs': 'Completed',
      'available_jobs': 'Available for Jobs in',
      'offline': 'Currently Offline',
      'incoming_requests': 'Incoming Job Requests',
      'no_requests': 'No pending job requests',
      'radar_active':
          'Radar active • You will be alerted when a client books nearby',
      'review': 'Review',
      'profile': 'Profile',
      'messages': 'Messages',
      'services': 'Services',
      'home': 'Home',
      'saved_addresses': 'Saved Addresses',
      'my_bookings': 'My Bookings & Invoices',
      'turnkey_projects': 'Turnkey Business Projects',
      'trade_skills': 'Skills & Trade Certificates',
      'payout_account': 'Payout Account (bKash / Nagad)',
      'switch_to_worker': 'Switch to Worker Mode',
      'language': 'Language / ভাষা',
      'change_photo': 'Change Profile Photo',
      'edit_profile': 'Edit Personal Info',
      'delete_account': 'Delete Account',
      'logout': 'Sign Out of Account',
      'select_location': 'Select Service Location',
      'detect_gps': 'Detect Real GPS Location',
      'dhaka_zones': 'Dhaka Operating Zones',
      'quick_booking': 'Quick Booking',
      'starting_rate': 'Starting Rate',
      'book_now': 'Book Now',
      'dismiss': 'Dismiss',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'live_job_feed': 'Live Job Feed',
      'browse_jobs': 'Browse Jobs',
      'open_jobs': 'Open Opportunities',
      'projects': 'Projects',
    },
    'bn': {
      'app_name': 'স্ক্যাভিয়া',
      'client_mode': 'ক্লায়েন্ট মোড',
      'worker_mode': 'ওয়ার্কার মোড',
      'client': 'ক্লায়েন্ট',
      'worker': 'ওয়ার্কার',
      'hello': 'হ্যালো',
      'welcome_subtitle': 'ভেরিফায়েড অন-ডিমান্ড সার্ভিসেস —',
      'worker_hub_title': 'ওয়ার্কার ও ক্লায়েন্ট হাব',
      'worker_hub_subtitle': 'শিফট, লাইভ রিকোয়েস্ট ও উপার্জন পরিচালনা করুন',
      'search_hint': 'সার্ভিস, স্কিল বা কর্মী খুঁজুন...',
      'radar_title': 'রাডার',
      'pros_active': 'জন কারিগর সক্রিয়',
      'min_arrival': 'মিনিটে আগমন',
      'expand_radar': 'রাডার',
      'book_service': 'সার্ভিস বুক',
      'post_job': 'কাজ পোস্ট',
      'earn_shifts': 'আয় / শিফট',
      'skavia_ai': 'স্ক্যাভিয়া এআই',
      'skavia_ai_badge': 'স্ক্যাভিয়া এআই',
      'skavia_ai_desc':
          'স্বত্বাধিকারী এআই ডায়াগনস্টিক ও তাৎক্ষণিক প্রকল্প হিসাব',
      'active_service': 'রানিং সার্ভিস ট্র্যাকিং',
      'view_otp': 'জব ওটিপি দেখুন',
      'verified_shield': 'স্ক্যাভিয়া ভেরিফায়েড শিল্ড',
      'escrow_active': 'এসক্রো সুরক্ষা সক্রিয়',
      'featured_services': 'জনপ্রিয় সার্ভিসসমূহ',
      'see_all': 'সবগুলো দেখুন',
      'electrical_title': 'ইলেকট্রিক্যাল মেরামত ও ওয়্যারিং',
      'electrical_desc': 'সনদপ্রাপ্ত মাস্টার ইলেকট্রিশিয়ান',
      'ac_title': 'এইচভিএসি ও এসি মেইনটেন্যান্স',
      'ac_desc': 'গ্যাস রিফিল, সার্ভিসিং ও মেরামত',
      'plumbing_title': 'স্যানিটারি ও প্লাম্বিং',
      'plumbing_desc': 'পাইপ ফিটিং ও পানির মোটর সিস্টেম',
      'turnkey_title': 'টার্নকি অফিস ও বাণিজ্যিক সলিউশন',
      'turnkey_desc':
          'অফিস, শোরুম বা আইটি হাব সম্পূর্ণ সেটআপ—ডেডিকেটেড টিম লিডারসহ।',
      'nid_verified': '১০০% এনআইডি ভেরিফায়েড',
      'escrow_protected': 'এসক্রো সুরক্ষিত',
      'helpline': '২৪/৭ হেল্পলাইন',
      'earnings': 'মোট উপার্জন',
      'completed_jobs': 'সম্পন্ন কাজ',
      'available_jobs': 'কাজের জন্য প্রস্তুত —',
      'offline': 'বর্তমানে অফলাইন',
      'incoming_requests': 'ইনকামিং জব রিকোয়েস্ট',
      'no_requests': 'কোনো পেন্ডিং রিকোয়েস্ট নেই',
      'radar_active': 'রাডার সক্রিয় • ক্লায়েন্ট ডাকলে অ্যালার্ট পাবেন',
      'review': 'রিভিউ',
      'profile': 'প্রোফাইল',
      'messages': 'মেসেজ',
      'services': 'সার্ভিসসমূহ',
      'home': 'হোম',
      'saved_addresses': 'সংরক্ষিত ঠিকানা',
      'my_bookings': 'বুকিং ও ভ্যাট ইনভয়েস',
      'turnkey_projects': 'টার্নকি প্রজেক্ট হাব',
      'trade_skills': 'ট্রেড স্কিলস ও সার্টিফিকেট',
      'payout_account': 'টাকা তোলার অ্যাকাউন্ট (বিকাশ / নগদ)',
      'switch_to_worker': 'ওয়ার্কার মোডে যান',
      'language': 'ভাষা / Language',
      'change_photo': 'প্রোফাইল ছবি পরিবর্তন',
      'edit_profile': 'তথ্য এডিট করুন',
      'delete_account': 'অ্যাকাউন্ট মুছে ফেলুন',
      'logout': 'লগআউট করুন',
      'select_location': 'সার্ভিস এরিয়া নির্বাচন',
      'detect_gps': 'আসল GPS লোকেশন ডিটেক্ট করুন',
      'dhaka_zones': 'ঢাকার কর্মএলাকাসমূহ',
      'quick_booking': '১-ট্যাপ কুইক বুকিং',
      'starting_rate': 'শুরুর মূল্য',
      'book_now': 'বুক করুন',
      'dismiss': 'বন্ধ করুন',
      'cancel': 'বাতিল',
      'confirm': 'নিশ্চিত করুন',
      'live_job_feed': 'লাইভ কাজের ফিড',
      'browse_jobs': 'সব কাজ ব্রাউজ করুন',
      'open_jobs': 'কাজের সুযোগ',
      'projects': 'প্রজেক্ট',
    },
  };

  /// Translate key into currently active language
  static String tr(String key) {
    final lang = localeNotifier.value;
    return _localizedValues[lang]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
