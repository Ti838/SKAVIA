/**
 * SKAVIA Centralized Localization Dictionaries
 * Full bilingual support: English ('en') and Bangla Bangladesh ('bn')
 */

export type LanguageCode = 'en' | 'bn';

export interface TranslationDictionary {
  // Brand & Slogans
  brandName: string;
  brandTagline: string;
  ecosystemSubtitle: string;
  oneAccountableOrg: string;
  eightBranches: string;
  
  // Navigation Links
  navAbout: string;
  navHowItWorks: string;
  navBranches: string;
  navSolutions: string;
  navBecomeWorker: string;
  navFaq: string;
  navContact: string;
  navPortalSignIn: string;
  navGetApp: string;
  navDashboard: string;
  navWorkerConsole: string;
  navCustomerPortal: string;
  navBusinessPortal: string;
  navBookings: string;
  navVerifications: string;
  navTeams: string;
  navDisputes: string;
  navCustomers: string;
  navWorkers: string;
  navServices: string;
  navFinance: string;
  navReports: string;
  navAdmins: string;
  navSecurity: string;
  navReleases: string;
  navSettings: string;
  
  // Navigation Sections
  sectionOperations: string;
  sectionPlatform: string;
  sectionGovernance: string;
  sectionPortals: string;
  
  // Mobile Drawer & Roles
  menuTitle: string;
  menuClose: string;
  activeLocation: string;
  changeLocation: string;
  selectLocation: string;
  guestUser: string;
  roleSwitcherTitle: string;
  roleIndividualCustomer: string;
  roleBusinessClient: string;
  roleWorker: string;
  roleAdminPortal: string;
  downloadApkTitle: string;
  downloadApkSubtitle: string;
  
  // Location Zones
  zoneDhanmondi: string;
  zoneGulshan: string;
  zoneBanani: string;
  zoneUttara: string;
  zoneMirpur: string;
  zoneMohammadpur: string;
  zoneMotijheel: string;
  zoneChattogram: string;
  zoneSylhet: string;
  
  // Common Actions & Statuses
  themeAuto: string;
  themeLight: string;
  themeDark: string;
  loading: string;
  retry: string;
  verifiedSpecialist: string;
  handshakeOtp: string;
  escrowProtected: string;
  
  // Worker Console
  workerConsoleTitle: string;
  workerConsoleSubtitle: string;
  statusAvailable: string;
  statusOffline: string;
  toggleAvailability: string;
  assignedDispatches: string;
  noDispatchesTitle: string;
  noDispatchesDesc: string;
  verifyOtpAction: string;
  enterOtpPlaceholder: string;
  earningsSummary: string;
  totalEarned: string;
  inEscrow: string;
  availablePayout: string;

  // Customer Portal
  customerPortalTitle: string;
  customerPortalSubtitle: string;
  activeRequests: string;
  noRequestsTitle: string;
  noRequestsDesc: string;
  yourArrivalOtp: string;
  shareOtpWithWorker: string;
  completedBookings: string;
  downloadReceipt: string;

  // Business Portal
  businessPortalTitle: string;
  businessPortalSubtitle: string;
  corporateProjects: string;
  noProjectsTitle: string;
  noProjectsDesc: string;
  teamRosterTitle: string;
  activeMilestones: string;
  corporateBilling: string;

  // Footer
  footerDesc: string;
  footerBranchesTitle: string;
  footerSolutionsTitle: string;
  footerTrustTitle: string;
  footerLegalTitle: string;
  footerPrivacy: string;
  footerTerms: string;
  footerRights: string;
}

export const translations: Record<LanguageCode, TranslationDictionary> = {
  en: {
    brandName: 'SKAVIA',
    brandTagline: 'Explain Your Requirement. SKAVIA Delivers the Solution.',
    ecosystemSubtitle: 'One accountable delivery engine across 8 specialization branches in Bangladesh.',
    oneAccountableOrg: 'One Accountable Organization',
    eightBranches: '8 Specialization Branches',
    
    navAbout: 'About',
    navHowItWorks: 'How It Works',
    navBranches: 'Branches',
    navSolutions: 'Solutions',
    navBecomeWorker: 'Become a Worker',
    navFaq: 'FAQ',
    navContact: 'Contact & Support',
    navPortalSignIn: 'Sign In / Portal',
    navGetApp: 'Get Mobile App',
    navDashboard: 'Overview & Metrics',
    navWorkerConsole: 'Worker Console',
    navCustomerPortal: 'Customer Portal',
    navBusinessPortal: 'Business & Projects',
    navBookings: 'Bookings & Orders',
    navVerifications: 'Verification Queue',
    navTeams: 'Turnkey Teams',
    navDisputes: 'Dispute Mediation',
    navCustomers: 'Customer Directory',
    navWorkers: 'Worker Directory',
    navServices: 'Services & Skills',
    navFinance: 'Finance & Escrow',
    navReports: 'Reports & Export',
    navAdmins: 'Admins & Invitations',
    navSecurity: 'Security Center',
    navReleases: 'App Releases',
    navSettings: 'Passkeys & Profile',
    
    sectionOperations: 'Operations',
    sectionPlatform: 'Platform',
    sectionGovernance: 'Governance',
    sectionPortals: 'Ecosystem Portals',
    
    menuTitle: 'Menu & Navigation',
    menuClose: 'Close menu',
    activeLocation: 'Active Area',
    changeLocation: 'Change Area',
    selectLocation: 'Select Your Service Area',
    guestUser: 'Guest Visitor',
    roleSwitcherTitle: 'Ecosystem Portals',
    roleIndividualCustomer: 'Individual Customer',
    roleBusinessClient: 'Business & Organization',
    roleWorker: 'Skilled Specialist (Worker)',
    roleAdminPortal: 'Enterprise Admin Portal',
    downloadApkTitle: 'Download SKAVIA App',
    downloadApkSubtitle: 'Android Official APK Direct Download',
    
    zoneDhanmondi: 'Dhanmondi, Dhaka',
    zoneGulshan: 'Gulshan, Dhaka',
    zoneBanani: 'Banani, Dhaka',
    zoneUttara: 'Uttara, Dhaka',
    zoneMirpur: 'Mirpur, Dhaka',
    zoneMohammadpur: 'Mohammadpur, Dhaka',
    zoneMotijheel: 'Motijheel, Dhaka',
    zoneChattogram: 'Agrabad, Chattogram',
    zoneSylhet: 'Zindabazar, Sylhet',
    
    themeAuto: 'Auto',
    themeLight: 'Light',
    themeDark: 'Dark',
    loading: 'Loading live SKAVIA data...',
    retry: 'Retry Request',
    verifiedSpecialist: 'Verified Specialist',
    handshakeOtp: '4-Digit Arrival Handshake OTP',
    escrowProtected: 'Escrow Protected Payment',
    
    workerConsoleTitle: 'Worker Specialist Console',
    workerConsoleSubtitle: 'Live dispatch management, arrival verification & earnings wallet.',
    statusAvailable: 'Online & Ready for Dispatch',
    statusOffline: 'Offline / Resting',
    toggleAvailability: 'Toggle Live Availability',
    assignedDispatches: 'Assigned Dispatches',
    noDispatchesTitle: 'No Active Dispatches',
    noDispatchesDesc: 'You have no pending assignments right now. Ensure your availability status is toggled ON to receive incoming job requests.',
    verifyOtpAction: 'Confirm 4-Digit Arrival OTP',
    enterOtpPlaceholder: 'Enter customer OTP (e.g. 8421)',
    earningsSummary: 'Earnings & Escrow Wallet',
    totalEarned: 'Total Earned',
    inEscrow: 'Protected in Escrow',
    availablePayout: 'Available for Payout',

    customerPortalTitle: 'Customer Service Portal',
    customerPortalSubtitle: 'Track your ongoing service requests, arrivals and certified receipts.',
    activeRequests: 'Active Service Requests',
    noRequestsTitle: 'No Active Service Requests',
    noRequestsDesc: 'You do not have any open bookings. Need a verified specialist? Submit a requirement from the homepage or mobile app.',
    yourArrivalOtp: 'Your 4-Digit Arrival OTP',
    shareOtpWithWorker: 'Share this confidential OTP only when the verified technician physically arrives at your premises.',
    completedBookings: 'Completed Orders & Receipts',
    downloadReceipt: 'Download Official Receipt',

    businessPortalTitle: 'Enterprise & Turnkey Projects',
    businessPortalSubtitle: 'Manage commercial multi-trade projects, assembled contractor teams, and corporate billing.',
    corporateProjects: 'Turnkey Commercial Projects',
    noProjectsTitle: 'No Corporate Projects Underway',
    noProjectsDesc: 'No enterprise projects are currently active. Contact SKAVIA Enterprise to commission a multi-disciplinary team for your organization.',
    teamRosterTitle: 'Assembled Project Teams',
    activeMilestones: 'Project Milestones',
    corporateBilling: 'Corporate Invoices & Statements',

    footerDesc: 'SKAVIA is Bangladesh’s premier solution-oriented workforce and services enterprise. Delivering accountable quality across residential, agricultural, technical, and commercial projects.',
    footerBranchesTitle: 'Specialization Branches',
    footerSolutionsTitle: 'Platform Solutions',
    footerTrustTitle: 'Trust & Safety',
    footerLegalTitle: 'Governance & Legal',
    footerPrivacy: 'Privacy Policy',
    footerTerms: 'Terms of Service',
    footerRights: 'All rights reserved. SKAVIA Technologies Ltd.',
  },
  bn: {
    brandName: 'স্ক্যাভিয়া',
    brandTagline: 'আপনার প্রয়োজন জানান, স্ক্যাভিয়া সমাধান পৌঁছে দেবে।',
    ecosystemSubtitle: 'বাংলাদেশে ৮টি বিশেষায়িত শাখার সমন্বয়ে গঠিত একক দায়িত্বশীল সেবা প্রদানকারী প্রতিষ্ঠান।',
    oneAccountableOrg: 'একক দায়িত্বশীল প্রতিষ্ঠান',
    eightBranches: '৮টি বিশেষায়িত শাখা',
    
    navAbout: 'পরিচিতি',
    navHowItWorks: 'কীভাবে কাজ করে',
    navBranches: 'শাখা সমূহ',
    navSolutions: 'সমাধান',
    navBecomeWorker: 'কর্মী হিসেবে যোগ দিন',
    navFaq: 'প্রশ্নোত্তর',
    navContact: 'যোগাযোগ ও সহায়তা',
    navPortalSignIn: 'সাইন ইন / পোর্টাল',
    navGetApp: 'অ্যাপ ডাউনলোড',
    navDashboard: 'সারসংক্ষেপ ও মেট্রিক্স',
    navWorkerConsole: 'ওয়ার্কার কনসোল',
    navCustomerPortal: 'কাস্টমার পোর্টাল',
    navBusinessPortal: 'বিজনেস ও প্রজেক্ট',
    navBookings: 'বুকিং ও অর্ডার',
    navVerifications: 'ভেরিফিকেশন কিউ',
    navTeams: 'টার্নকি টিম',
    navDisputes: 'বিরোধ মীমাংসা',
    navCustomers: 'গ্রাহক তালিকা',
    navWorkers: 'কর্মী তালিকা',
    navServices: 'সার্ভিস ও স্কিল',
    navFinance: 'ফাইন্যান্স ও এসক্রো',
    navReports: 'রিপোর্ট ও এক্সপোর্ট',
    navAdmins: 'এডমিন ও আমন্ত্রণ',
    navSecurity: 'সিকিউরিটি সেন্টার',
    navReleases: 'অ্যাপ রিলিজ',
    navSettings: 'পাসকি ও প্রোফাইল',
    
    sectionOperations: 'অপারেশনস',
    sectionPlatform: 'প্ল্যাটফর্ম',
    sectionGovernance: 'গভর্ন্যান্স',
    sectionPortals: 'ইকোসিস্টেম পোর্টাল',
    
    menuTitle: 'মেন্যু ও নেভিগেশন',
    menuClose: 'মেন্যু বন্ধ করুন',
    activeLocation: 'বর্তমান এলাকা',
    changeLocation: 'এলাকা পরিবর্তন',
    selectLocation: 'আপনার সেবার এলাকা নির্বাচন করুন',
    guestUser: 'অতিথি ব্যবহারকারী',
    roleSwitcherTitle: 'প্ল্যাটফর্ম পোর্টাল',
    roleIndividualCustomer: 'ব্যক্তিগত গ্রাহক',
    roleBusinessClient: 'ব্যবসায়িক ও প্রাতিষ্ঠানিক ক্লায়েন্ট',
    roleWorker: 'দক্ষ কর্মী (স্পেশালিস্ট)',
    roleAdminPortal: 'এডমিন গভর্ন্যান্স পোর্টাল',
    downloadApkTitle: 'স্ক্যাভিয়া অ্যাপ ডাউনলোড',
    downloadApkSubtitle: 'অ্যান্ড্রয়েড অফিসিয়াল এপিকে ডাউনলোড',
    
    zoneDhanmondi: 'ধানমন্ডি, ঢাকা',
    zoneGulshan: 'গুলশান, ঢাকা',
    zoneBanani: 'বনানী, ঢাকা',
    zoneUttara: 'উত্তরা, ঢাকা',
    zoneMirpur: 'মিরপুর, ঢাকা',
    zoneMohammadpur: 'মোহাম্মদপুর, ঢাকা',
    zoneMotijheel: 'মতিঝিল, ঢাকা',
    zoneChattogram: 'আগ্রাবাদ, চট্টগ্রাম',
    zoneSylhet: 'জিন্দাবাজার, সিলেট',
    
    themeAuto: 'অটো',
    themeLight: 'লাইট',
    themeDark: 'ডার্ক',
    loading: 'স্ক্যাভিয়ার তথ্য লোড হচ্ছে...',
    retry: 'পুনরায় চেষ্টা করুন',
    verifiedSpecialist: 'যাচাইকৃত দক্ষ কর্মী',
    handshakeOtp: '৪-ডিজিটের আগমন যাচাইকরণ ওটিপি',
    escrowProtected: 'নিরাপদ এসক্রো পেমেন্ট',
    
    workerConsoleTitle: 'ওয়ার্কার স্পেশালিস্ট কনসোল',
    workerConsoleSubtitle: 'লাইভ ডিসপ্যাচ ব্যবস্থাপনা, আগমন যাচাইকরণ ও উপার্জিত ওয়ালেট।',
    statusAvailable: 'অনলাইন ও সেবার জন্য প্রস্তুত',
    statusOffline: 'অফলাইন / বিশ্রামে',
    toggleAvailability: 'উপস্থিতির স্ট্যাটাস পরিবর্তন',
    assignedDispatches: 'অর্পিত সেবাসমূহ',
    noDispatchesTitle: 'কোনো সক্রিয় সেবা নেই',
    noDispatchesDesc: 'আপনার জন্য এই মুহূর্তে কোনো অর্পিত সেবা নেই। নতুন কাজের অনুরোধ পেতে আপনার উপস্থিতি স্ট্যাটাস চালু (Online) রাখুন।',
    verifyOtpAction: '৪-ডিজিটের আগমন ওটিপি নিশ্চিত করুন',
    enterOtpPlaceholder: 'গ্রাহকের ওটিপি দিন (যেমন: ৮৪২১)',
    earningsSummary: 'উপার্জন ও এসক্রো ওয়ালেট',
    totalEarned: 'মোট উপার্জিত',
    inEscrow: 'এসক্রোতে সুরক্ষিত',
    availablePayout: 'উত্তোলনের জন্য প্রস্তুত',

    customerPortalTitle: 'কাস্টমার সার্ভিস পোর্টাল',
    customerPortalSubtitle: 'আপনার চলমান সেবার অবস্থা, টেকনিশিয়ান আগমন ও রসিদ ট্র্যাক করুন।',
    activeRequests: 'সক্রিয় সেবাসমূহ',
    noRequestsTitle: 'কোনো সক্রিয় সেবা অনুরোধ নেই',
    noRequestsDesc: 'আপনার কোনো চলমান অর্ডার নেই। দক্ষ কর্মী পেতে হোমপেজ বা অ্যাপ থেকে আপনার প্রয়োজন পোস্ট করুন।',
    yourArrivalOtp: 'আপনার ৪-ডিজিটের আগমন ওটিপি',
    shareOtpWithWorker: 'যাচাইকৃত টেকনিশিয়ান আপনার ঠিকানায় পৌঁছানোর পর শুধুমাত্র তখনই এই গোপন ওটিপিটি প্রদান করুন।',
    completedBookings: 'সম্পন্ন সেবা ও রসিদ',
    downloadReceipt: 'অফিসিয়াল রসিদ ডাউনলোড',

    businessPortalTitle: 'এন্টারপ্রাইজ ও টার্নকি প্রজেক্ট',
    businessPortalSubtitle: 'বাণিজ্যিক সমন্বিত প্রজেক্ট, দক্ষ টিম ব্যবস্থাপনা ও কর্পোরেট ইনভয়েসিং।',
    corporateProjects: 'টার্নকি বাণিজ্যিক প্রকল্প',
    noProjectsTitle: 'কোনো সক্রিয় বাণিজ্যিক প্রজেক্ট নেই',
    noProjectsDesc: 'বর্তমানে কোনো কর্পোরেট প্রজেক্ট চলমান নেই। আপনার প্রতিষ্ঠানের জন্য মাল্টি-ডিসিপ্লিনারি টিম নিয়োগ করতে স্ক্যাভিয়ার সাথে যোগাযোগ করুন।',
    teamRosterTitle: 'নিয়োজিত প্রজেক্ট টিম',
    activeMilestones: 'প্রজেক্ট মাইলস্টোন',
    corporateBilling: 'কর্পোরেট ইনভয়েস ও বিলিং বিবরণী',

    footerDesc: 'স্ক্যাভিয়া বাংলাদেশের শীর্ষস্থানীয় নির্ভরযোগ্য সেবা ও দক্ষ কর্মী ব্যবস্থাপনা প্রতিষ্ঠান। আবাসিক, কৃষি, প্রযুক্তিগত ও ব্যবসায়িক প্রকল্পে বিশ্বস্ত সমাধান নিশ্চিত করে।',
    footerBranchesTitle: 'বিশেষায়িত শাখা',
    footerSolutionsTitle: 'সেবা সমাধান',
    footerTrustTitle: 'নিরাপত্তা ও বিশ্বাস',
    footerLegalTitle: 'নীতিমালা ও আইনি তথ্য',
    footerPrivacy: 'গোপনীয়তা নীতি',
    footerTerms: 'ব্যবহারের শর্তাবলী',
    footerRights: 'সর্বস্বত্ব সংরক্ষিত। স্ক্যাভিয়া টেকনোলজিস লিমিটেড।',
  },
};
