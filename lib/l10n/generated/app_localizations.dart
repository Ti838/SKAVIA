import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SKAVIA'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Every Skill. Every Opportunity.'**
  String get appTagline;

  /// No description provided for @roleSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super Admin'**
  String get roleSuperAdmin;

  /// No description provided for @roleCompanyAdmin.
  ///
  /// In en, this message translates to:
  /// **'Company Admin'**
  String get roleCompanyAdmin;

  /// No description provided for @roleBranchManager.
  ///
  /// In en, this message translates to:
  /// **'Branch Manager'**
  String get roleBranchManager;

  /// No description provided for @roleWorker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get roleWorker;

  /// No description provided for @roleIndividualCustomer.
  ///
  /// In en, this message translates to:
  /// **'Individual Customer'**
  String get roleIndividualCustomer;

  /// No description provided for @roleBusinessClient.
  ///
  /// In en, this message translates to:
  /// **'Business Client'**
  String get roleBusinessClient;

  /// No description provided for @roleOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get roleOrganization;

  /// No description provided for @roleClientShort.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get roleClientShort;

  /// No description provided for @roleBusinessShort.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get roleBusinessShort;

  /// No description provided for @roleWorkerShort.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get roleWorkerShort;

  /// No description provided for @roleClientMode.
  ///
  /// In en, this message translates to:
  /// **'Client Mode'**
  String get roleClientMode;

  /// No description provided for @roleBusinessMode.
  ///
  /// In en, this message translates to:
  /// **'Business Mode'**
  String get roleBusinessMode;

  /// No description provided for @roleWorkerMode.
  ///
  /// In en, this message translates to:
  /// **'Worker Mode'**
  String get roleWorkerMode;

  /// No description provided for @roleSpecialistWorker.
  ///
  /// In en, this message translates to:
  /// **'Specialist / Worker'**
  String get roleSpecialistWorker;

  /// No description provided for @switchAccountMode.
  ///
  /// In en, this message translates to:
  /// **'Switch Account Mode'**
  String get switchAccountMode;

  /// No description provided for @chooseWorkspaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your active workspace role'**
  String get chooseWorkspaceSubtitle;

  /// No description provided for @roleStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get roleStatusActive;

  /// No description provided for @roleStatusSetup.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get roleStatusSetup;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get navProjects;

  /// No description provided for @navEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get navEarnings;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonRetry;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get commonSeeAll;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get commonClearFilters;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get commonVerified;

  /// No description provided for @commonPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get commonPending;

  /// No description provided for @commonRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get commonRejected;

  /// No description provided for @commonUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get commonUnverified;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get commonActive;

  /// No description provided for @commonCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get commonCompleted;

  /// No description provided for @commonOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get commonOnline;

  /// No description provided for @commonOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get commonOffline;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No Data Yet'**
  String get commonNoData;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get commonConnectionError;

  /// No description provided for @commonCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get commonCopiedToClipboard;

  /// No description provided for @commonDhaka.
  ///
  /// In en, this message translates to:
  /// **'Dhaka'**
  String get commonDhaka;

  /// No description provided for @commonDhakaBangladesh.
  ///
  /// In en, this message translates to:
  /// **'Dhaka, Bangladesh'**
  String get commonDhakaBangladesh;

  /// No description provided for @commonLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get commonLanguage;

  /// No description provided for @commonEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get commonEnglish;

  /// No description provided for @commonBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get commonBangla;

  /// No description provided for @commonTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get commonTheme;

  /// No description provided for @commonThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get commonThemeSystem;

  /// No description provided for @commonThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get commonThemeLight;

  /// No description provided for @commonThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get commonThemeDark;

  /// No description provided for @headerNotificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get headerNotificationsTooltip;

  /// No description provided for @headerThemeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch theme'**
  String get headerThemeTooltip;

  /// No description provided for @headerLanguageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get headerLanguageTooltip;

  /// No description provided for @headerProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get headerProfileTooltip;

  /// No description provided for @headerSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Service Location'**
  String get headerSelectLocation;

  /// No description provided for @headerDetectGps.
  ///
  /// In en, this message translates to:
  /// **'Detect Real GPS Location'**
  String get headerDetectGps;

  /// No description provided for @headerDhakaZones.
  ///
  /// In en, this message translates to:
  /// **'Dhaka Operating Zones'**
  String get headerDhakaZones;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your SKAVIA workspace'**
  String get authSignInSubtitle;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authSignUp;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get authSignOut;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmail;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get authEmailHint;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullName;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authFullNameHint;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhone;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'01XXXXXXXXX'**
  String get authPhoneHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get authOrContinueWith;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authSelectRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Account Type'**
  String get authSelectRoleTitle;

  /// No description provided for @authOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get authOtpTitle;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to your phone'**
  String get authOtpSubtitle;

  /// No description provided for @authVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get authVerifyCode;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get authResendCode;

  /// No description provided for @authRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Authentication required. Please sign in to continue.'**
  String get authRequiredMessage;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search services, skills, or specialists...'**
  String get homeSearchHint;

  /// No description provided for @homePostJob.
  ///
  /// In en, this message translates to:
  /// **'Post Job'**
  String get homePostJob;

  /// No description provided for @homeRequestService.
  ///
  /// In en, this message translates to:
  /// **'Request Service'**
  String get homeRequestService;

  /// No description provided for @homeShareUpdate.
  ///
  /// In en, this message translates to:
  /// **'Share Update'**
  String get homeShareUpdate;

  /// No description provided for @homeBookService.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get homeBookService;

  /// No description provided for @homePopularServices.
  ///
  /// In en, this message translates to:
  /// **'Popular Services'**
  String get homePopularServices;

  /// No description provided for @homeAvailableSpecialists.
  ///
  /// In en, this message translates to:
  /// **'Available Specialists'**
  String get homeAvailableSpecialists;

  /// No description provided for @homeNoSpecialistsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Specialists Available Yet'**
  String get homeNoSpecialistsTitle;

  /// No description provided for @homeNoSpecialistsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified specialists will appear here once they join SKAVIA.'**
  String get homeNoSpecialistsSubtitle;

  /// No description provided for @homeCouldNotLoadSpecialists.
  ///
  /// In en, this message translates to:
  /// **'Could not load specialists right now.'**
  String get homeCouldNotLoadSpecialists;

  /// No description provided for @homeRecentOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Recent Marketplace Posts'**
  String get homeRecentOpportunities;

  /// No description provided for @homeNoRecentPostsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Active Posts Yet'**
  String get homeNoRecentPostsTitle;

  /// No description provided for @homeNoRecentPostsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post a job or service requirement to connect with skilled specialists.'**
  String get homeNoRecentPostsSubtitle;

  /// No description provided for @homeActiveService.
  ///
  /// In en, this message translates to:
  /// **'Live Service in Progress'**
  String get homeActiveService;

  /// No description provided for @homeViewOtp.
  ///
  /// In en, this message translates to:
  /// **'View Job OTP'**
  String get homeViewOtp;

  /// No description provided for @homeVerifiedShield.
  ///
  /// In en, this message translates to:
  /// **'SKAVIA Verified Shield'**
  String get homeVerifiedShield;

  /// No description provided for @homeEscrowProtected.
  ///
  /// In en, this message translates to:
  /// **'Escrow Protected'**
  String get homeEscrowProtected;

  /// No description provided for @homeNidVerified.
  ///
  /// In en, this message translates to:
  /// **'NID Verified'**
  String get homeNidVerified;

  /// No description provided for @homeHelpline.
  ///
  /// In en, this message translates to:
  /// **'24/7 Helpline'**
  String get homeHelpline;

  /// No description provided for @homeSkaviaAiTitle.
  ///
  /// In en, this message translates to:
  /// **'SKAVIA AI'**
  String get homeSkaviaAiTitle;

  /// No description provided for @homeSkaviaAiDesc.
  ///
  /// In en, this message translates to:
  /// **'AI diagnostics & instant project estimation'**
  String get homeSkaviaAiDesc;

  /// No description provided for @homeRadarTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Specialist Radar'**
  String get homeRadarTitle;

  /// No description provided for @homeRadarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pin your location or discover nearby specialists'**
  String get homeRadarSubtitle;

  /// No description provided for @homeOpenRadar.
  ///
  /// In en, this message translates to:
  /// **'Open Map'**
  String get homeOpenRadar;

  /// No description provided for @businessWorkspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Workspace'**
  String get businessWorkspaceTitle;

  /// No description provided for @organizationWorkspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Organization Workspace'**
  String get organizationWorkspaceTitle;

  /// No description provided for @businessActiveProjects.
  ///
  /// In en, this message translates to:
  /// **'Active Projects'**
  String get businessActiveProjects;

  /// No description provided for @businessOpenRequirements.
  ///
  /// In en, this message translates to:
  /// **'Open Requirements'**
  String get businessOpenRequirements;

  /// No description provided for @businessCreateRequirement.
  ///
  /// In en, this message translates to:
  /// **'Post Requirement'**
  String get businessCreateRequirement;

  /// No description provided for @businessBrowseServices.
  ///
  /// In en, this message translates to:
  /// **'Browse Services'**
  String get businessBrowseServices;

  /// No description provided for @businessOpenProjects.
  ///
  /// In en, this message translates to:
  /// **'Manage Projects'**
  String get businessOpenProjects;

  /// No description provided for @businessNoProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Active Projects Yet'**
  String get businessNoProjectsTitle;

  /// No description provided for @businessNoProjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post a business requirement or turnkey project to assemble a verified team.'**
  String get businessNoProjectsSubtitle;

  /// No description provided for @workerAvailableIn.
  ///
  /// In en, this message translates to:
  /// **'Available in {location}'**
  String workerAvailableIn(String location);

  /// No description provided for @workerCurrentlyOffline.
  ///
  /// In en, this message translates to:
  /// **'Currently Offline'**
  String get workerCurrentlyOffline;

  /// No description provided for @workerManageSchedule.
  ///
  /// In en, this message translates to:
  /// **'Manage schedule'**
  String get workerManageSchedule;

  /// No description provided for @workerEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get workerEarnings;

  /// No description provided for @workerCompletedJobs.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get workerCompletedJobs;

  /// No description provided for @workerRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get workerRating;

  /// No description provided for @workerJobsCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} jobs completed'**
  String workerJobsCompletedCount(int count);

  /// No description provided for @workerNewlyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Newly registered'**
  String get workerNewlyRegistered;

  /// No description provided for @workerVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Worker Verification & Bio'**
  String get workerVerificationTitle;

  /// No description provided for @workerVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload NID, set hourly rate & working zones'**
  String get workerVerificationDesc;

  /// No description provided for @workerVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified Specialist'**
  String get workerVerifiedTitle;

  /// No description provided for @workerVerifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your identity is verified and visible to clients.'**
  String get workerVerifiedDesc;

  /// No description provided for @workerPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification In Review'**
  String get workerPendingTitle;

  /// No description provided for @workerPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your trade profile while verification is pending.'**
  String get workerPendingDesc;

  /// No description provided for @workerRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Needs Attention'**
  String get workerRejectedTitle;

  /// No description provided for @workerRejectedDesc.
  ///
  /// In en, this message translates to:
  /// **'Please update your verification details to accept jobs.'**
  String get workerRejectedDesc;

  /// No description provided for @workerActiveJobBadge.
  ///
  /// In en, this message translates to:
  /// **'Active · {status}'**
  String workerActiveJobBadge(String status);

  /// No description provided for @workerIncomingRequests.
  ///
  /// In en, this message translates to:
  /// **'Incoming Job Requests'**
  String get workerIncomingRequests;

  /// No description provided for @workerDirectRequests.
  ///
  /// In en, this message translates to:
  /// **'Direct ({count})'**
  String workerDirectRequests(int count);

  /// No description provided for @workerOpenJobsFeed.
  ///
  /// In en, this message translates to:
  /// **'Open Jobs Feed'**
  String get workerOpenJobsFeed;

  /// No description provided for @workerNoPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests right now'**
  String get workerNoPendingRequests;

  /// No description provided for @workerNoPendingRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your availability active to receive direct dispatches from clients.'**
  String get workerNoPendingRequestsSubtitle;

  /// No description provided for @workerRefreshQueue.
  ///
  /// In en, this message translates to:
  /// **'Refresh Queue'**
  String get workerRefreshQueue;

  /// No description provided for @workerCouldNotLoadRequests.
  ///
  /// In en, this message translates to:
  /// **'Could Not Load Requests'**
  String get workerCouldNotLoadRequests;

  /// No description provided for @workerAcceptJob.
  ///
  /// In en, this message translates to:
  /// **'Accept Job'**
  String get workerAcceptJob;

  /// No description provided for @workerDeclineJob.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get workerDeclineJob;

  /// No description provided for @workerWithdrawFunds.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Funds'**
  String get workerWithdrawFunds;

  /// No description provided for @workerAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get workerAvailableBalance;

  /// No description provided for @workerReputationTitle.
  ///
  /// In en, this message translates to:
  /// **'Worker Reputation & Badges'**
  String get workerReputationTitle;

  /// No description provided for @servicesAndCategories.
  ///
  /// In en, this message translates to:
  /// **'Services & Categories'**
  String get servicesAndCategories;

  /// No description provided for @servicesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search service or keyword...'**
  String get servicesSearchHint;

  /// No description provided for @servicesAll.
  ///
  /// In en, this message translates to:
  /// **'All Services'**
  String get servicesAll;

  /// No description provided for @servicesAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'Available Services ({count})'**
  String servicesAvailableCount(int count);

  /// No description provided for @servicesBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get servicesBookNow;

  /// No description provided for @servicesBrowseByTrade.
  ///
  /// In en, this message translates to:
  /// **'Browse by Trade'**
  String get servicesBrowseByTrade;

  /// No description provided for @servicesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Services Listed Yet'**
  String get servicesEmptyTitle;

  /// No description provided for @servicesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Services in this category will appear here once published.'**
  String get servicesEmptyMessage;

  /// No description provided for @servicesFilteredEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Matching Services'**
  String get servicesFilteredEmptyTitle;

  /// No description provided for @servicesFilteredEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword or reset the active category filter.'**
  String get servicesFilteredEmptyMessage;

  /// No description provided for @servicesErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could Not Load Services'**
  String get servicesErrorTitle;

  /// No description provided for @servicesStartingRate.
  ///
  /// In en, this message translates to:
  /// **'Starting Rate'**
  String get servicesStartingRate;

  /// No description provided for @servicesQuickBooking.
  ///
  /// In en, this message translates to:
  /// **'Quick Booking'**
  String get servicesQuickBooking;

  /// No description provided for @feedTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace Feed'**
  String get feedTitle;

  /// No description provided for @feedComposerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Share an opportunity, post a job, or request a service...'**
  String get feedComposerPlaceholder;

  /// No description provided for @feedCreatePost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get feedCreatePost;

  /// No description provided for @feedAllPosts.
  ///
  /// In en, this message translates to:
  /// **'All Posts'**
  String get feedAllPosts;

  /// No description provided for @feedJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get feedJobs;

  /// No description provided for @feedServiceRequests.
  ///
  /// In en, this message translates to:
  /// **'Service Requests'**
  String get feedServiceRequests;

  /// No description provided for @feedUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get feedUpdates;

  /// No description provided for @feedAllTrades.
  ///
  /// In en, this message translates to:
  /// **'All Trades'**
  String get feedAllTrades;

  /// No description provided for @feedSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search feed by keyword...'**
  String get feedSearchHint;

  /// No description provided for @feedUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get feedUrgent;

  /// No description provided for @feedActivePostsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Active Post} other{{count} Active Posts}}'**
  String feedActivePostsCount(int count);

  /// No description provided for @feedLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get feedLoadMore;

  /// No description provided for @feedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Feed Posts Yet'**
  String get feedEmptyTitle;

  /// No description provided for @feedEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Share the first job opportunity, service request, or professional update.'**
  String get feedEmptyMessage;

  /// No description provided for @feedFilteredEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Posts Match Your Filters'**
  String get feedFilteredEmptyTitle;

  /// No description provided for @feedFilteredEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or clear active filters.'**
  String get feedFilteredEmptyMessage;

  /// No description provided for @feedErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could Not Load Feed'**
  String get feedErrorTitle;

  /// No description provided for @feedSubmitProposal.
  ///
  /// In en, this message translates to:
  /// **'Submit Direct Proposal'**
  String get feedSubmitProposal;

  /// No description provided for @feedBidAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Bid Amount (৳)'**
  String get feedBidAmountLabel;

  /// No description provided for @feedEstimatedArrivalLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated Arrival Time'**
  String get feedEstimatedArrivalLabel;

  /// No description provided for @feedProposalNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Brief Proposal Message'**
  String get feedProposalNoteLabel;

  /// No description provided for @feedProposalNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your relevant experience, tools, and availability...'**
  String get feedProposalNoteHint;

  /// No description provided for @feedSendProposal.
  ///
  /// In en, this message translates to:
  /// **'Send Proposal'**
  String get feedSendProposal;

  /// No description provided for @feedCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Discussion'**
  String get feedCommentsTitle;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Direct Messages'**
  String get messagesTitle;

  /// No description provided for @messagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time coordination between clients and specialists'**
  String get messagesSubtitle;

  /// No description provided for @messagesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search chats or names...'**
  String get messagesSearchHint;

  /// No description provided for @messagesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Conversations Yet'**
  String get messagesEmptyTitle;

  /// No description provided for @messagesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When you book a specialist, post a requirement, or accept a job, your conversations will appear here.'**
  String get messagesEmptyMessage;

  /// No description provided for @messagesFilteredEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Matching Conversations'**
  String get messagesFilteredEmptyTitle;

  /// No description provided for @messagesFilteredEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different name or keyword.'**
  String get messagesFilteredEmptyMessage;

  /// No description provided for @messagesErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could Not Load Messages'**
  String get messagesErrorTitle;

  /// No description provided for @messagesTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get messagesTypeHint;

  /// No description provided for @messagesSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Message could not be sent. Please try again.'**
  String get messagesSendFailed;

  /// No description provided for @messagesBrowseServices.
  ///
  /// In en, this message translates to:
  /// **'Browse Services'**
  String get messagesBrowseServices;

  /// No description provided for @messagesPostRequirement.
  ///
  /// In en, this message translates to:
  /// **'Post Requirement'**
  String get messagesPostRequirement;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileServicesStat.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get profileServicesStat;

  /// No description provided for @profileProjectsStat.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get profileProjectsStat;

  /// No description provided for @profileRatingStat.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get profileRatingStat;

  /// No description provided for @profileStrengthTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Strength'**
  String get profileStrengthTitle;

  /// No description provided for @profileCompleteAction.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get profileCompleteAction;

  /// No description provided for @profileEditPersonalDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Personal Details'**
  String get profileEditPersonalDetails;

  /// No description provided for @profileSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get profileSavedAddresses;

  /// No description provided for @profileMyBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings & Invoices'**
  String get profileMyBookings;

  /// No description provided for @profileTurnkeyProjects.
  ///
  /// In en, this message translates to:
  /// **'Turnkey Projects'**
  String get profileTurnkeyProjects;

  /// No description provided for @profileTradeSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills & Trade Certificates'**
  String get profileTradeSkills;

  /// No description provided for @profilePayoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Payout Account (bKash / Nagad)'**
  String get profilePayoutAccount;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profilePrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get profilePrivacySecurity;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileAboutSkavia.
  ///
  /// In en, this message translates to:
  /// **'About SKAVIA'**
  String get profileAboutSkavia;

  /// No description provided for @profileAppUpdates.
  ///
  /// In en, this message translates to:
  /// **'App Updates'**
  String get profileAppUpdates;

  /// No description provided for @profileAddCover.
  ///
  /// In en, this message translates to:
  /// **'Add Cover'**
  String get profileAddCover;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get profileChangePhoto;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get settingsTheme;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get settingsNotifications;

  /// No description provided for @settingsSoundHaptics.
  ///
  /// In en, this message translates to:
  /// **'Sound & Haptics'**
  String get settingsSoundHaptics;

  /// No description provided for @settingsAccountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get settingsAccountSecurity;

  /// No description provided for @settingsActiveSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get settingsActiveSessions;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsFilterAll;

  /// No description provided for @notificationsFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notificationsFilterUnread;

  /// No description provided for @notificationsFilterBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get notificationsFilterBookings;

  /// No description provided for @notificationsFilterUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get notificationsFilterUpdates;

  /// No description provided for @notificationsFilterProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get notificationsFilterProfile;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up!'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsFilteredEmpty.
  ///
  /// In en, this message translates to:
  /// **'Try switching to All to see other updates.'**
  String get notificationsFilteredEmpty;

  /// No description provided for @bookingConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get bookingConfirmTitle;

  /// No description provided for @bookingPaymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get bookingPaymentSummary;

  /// No description provided for @bookingServiceCharge.
  ///
  /// In en, this message translates to:
  /// **'Service Charge'**
  String get bookingServiceCharge;

  /// No description provided for @bookingPlatformFee.
  ///
  /// In en, this message translates to:
  /// **'SKAVIA Management Fee (15%)'**
  String get bookingPlatformFee;

  /// No description provided for @bookingTotalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get bookingTotalPayable;

  /// No description provided for @bookingPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get bookingPaymentMethod;

  /// No description provided for @bookingCashOnCompletion.
  ///
  /// In en, this message translates to:
  /// **'Cash on Completion'**
  String get bookingCashOnCompletion;

  /// No description provided for @bookingTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Service Tracking'**
  String get bookingTimelineTitle;

  /// No description provided for @bookingSecurityOtp.
  ///
  /// In en, this message translates to:
  /// **'Job Security OTP'**
  String get bookingSecurityOtp;

  /// No description provided for @bookingRateSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Rate & Review Specialist'**
  String get bookingRateSpecialist;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax & Escrow Invoice'**
  String get invoiceTitle;

  /// No description provided for @invoiceCopySummary.
  ///
  /// In en, this message translates to:
  /// **'Copy invoice summary'**
  String get invoiceCopySummary;

  /// No description provided for @invoiceSummaryCopied.
  ///
  /// In en, this message translates to:
  /// **'Invoice summary copied to clipboard'**
  String get invoiceSummaryCopied;

  /// No description provided for @invoiceTo.
  ///
  /// In en, this message translates to:
  /// **'INVOICE TO'**
  String get invoiceTo;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'INVOICE NO'**
  String get invoiceNumber;

  /// No description provided for @invoiceTransactionRef.
  ///
  /// In en, this message translates to:
  /// **'Transaction Reference'**
  String get invoiceTransactionRef;

  /// No description provided for @invoiceStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get invoiceStatusPaid;

  /// No description provided for @invoiceStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING ESCROW'**
  String get invoiceStatusPending;

  /// No description provided for @invoiceStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'REFUNDED'**
  String get invoiceStatusRefunded;

  /// No description provided for @matchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Matched Specialists'**
  String get matchingTitle;

  /// No description provided for @matchingTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Proposed Project Team'**
  String get matchingTeamTitle;

  /// No description provided for @matchingEvaluating.
  ///
  /// In en, this message translates to:
  /// **'Evaluating algorithmic match score...'**
  String get matchingEvaluating;

  /// No description provided for @matchingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Matched Specialists Yet'**
  String get matchingEmptyTitle;

  /// No description provided for @matchingEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No available specialists match this zone right now. Check back soon or refresh.'**
  String get matchingEmptyMessage;

  /// No description provided for @matchingReevaluate.
  ///
  /// In en, this message translates to:
  /// **'Re-evaluate Matches'**
  String get matchingReevaluate;

  /// No description provided for @matchingErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could Not Load Matches'**
  String get matchingErrorTitle;

  /// No description provided for @aiTitle.
  ///
  /// In en, this message translates to:
  /// **'SKAVIA AI'**
  String get aiTitle;

  /// No description provided for @aiChatTab.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get aiChatTab;

  /// No description provided for @aiDiagnosticTab.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic'**
  String get aiDiagnosticTab;

  /// No description provided for @aiAnalyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your requirements...'**
  String get aiAnalyzingTitle;

  /// No description provided for @aiAnalysisCompleted.
  ///
  /// In en, this message translates to:
  /// **'Analysis completed!'**
  String get aiAnalysisCompleted;

  /// No description provided for @aiViewResults.
  ///
  /// In en, this message translates to:
  /// **'View recommendations'**
  String get aiViewResults;

  /// No description provided for @aiNoAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'No Analysis Yet'**
  String get aiNoAnalysisTitle;

  /// No description provided for @aiNoAnalysisMessage.
  ///
  /// In en, this message translates to:
  /// **'Describe your service or project scope in SKAVIA AI Chat or Post Requirement to generate a tailored breakdown.'**
  String get aiNoAnalysisMessage;

  /// No description provided for @aiOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Open AI Chat'**
  String get aiOpenChat;

  /// No description provided for @aiProjectSummary.
  ///
  /// In en, this message translates to:
  /// **'Project Summary'**
  String get aiProjectSummary;

  /// No description provided for @aiRequiredSkills.
  ///
  /// In en, this message translates to:
  /// **'Required Skills'**
  String get aiRequiredSkills;

  /// No description provided for @aiRecommendedTeam.
  ///
  /// In en, this message translates to:
  /// **'Recommended Team'**
  String get aiRecommendedTeam;

  /// No description provided for @aiEditRequest.
  ///
  /// In en, this message translates to:
  /// **'Edit Request'**
  String get aiEditRequest;

  /// No description provided for @aiOpenProject.
  ///
  /// In en, this message translates to:
  /// **'Open Project'**
  String get aiOpenProject;

  /// No description provided for @projectsShowcaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Project Showcase'**
  String get projectsShowcaseTitle;

  /// No description provided for @projectsMyProjects.
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get projectsMyProjects;

  /// No description provided for @projectsExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get projectsExplore;

  /// No description provided for @projectsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Projects Yet'**
  String get projectsEmptyTitle;

  /// No description provided for @projectsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your ongoing and completed turnkey projects will appear here.'**
  String get projectsEmptySubtitle;

  /// No description provided for @projectsStartNew.
  ///
  /// In en, this message translates to:
  /// **'Start New Project'**
  String get projectsStartNew;

  /// No description provided for @teamsFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Teams'**
  String get teamsFindTitle;

  /// No description provided for @teamsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Teams Registered Yet'**
  String get teamsEmptyTitle;

  /// No description provided for @teamsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-disciplinary project teams will appear here once formed.'**
  String get teamsEmptySubtitle;

  /// No description provided for @teamsFilteredEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Teams Match These Filters'**
  String get teamsFilteredEmptyTitle;

  /// No description provided for @teamsOpenWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Open Team Workspace'**
  String get teamsOpenWorkspace;

  /// No description provided for @teamsRosterTitle.
  ///
  /// In en, this message translates to:
  /// **'Team Roster'**
  String get teamsRosterTitle;

  /// No description provided for @reviewsSubmitTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get reviewsSubmitTitle;

  /// No description provided for @reviewsWriteCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this specialist...'**
  String get reviewsWriteCommentHint;

  /// No description provided for @reviewsReputationTitle.
  ///
  /// In en, this message translates to:
  /// **'Reputation Overview'**
  String get reviewsReputationTitle;

  /// No description provided for @reviewsNoReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No verified reviews yet'**
  String get reviewsNoReviewsYet;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboardTitle;

  /// No description provided for @adminVerifications.
  ///
  /// In en, this message translates to:
  /// **'KYC Verifications'**
  String get adminVerifications;

  /// No description provided for @adminDisputes.
  ///
  /// In en, this message translates to:
  /// **'Dispute Resolution'**
  String get adminDisputes;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get adminUsers;

  /// No description provided for @adminBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get adminBranches;

  /// No description provided for @adminReports.
  ///
  /// In en, this message translates to:
  /// **'Reports & Audit'**
  String get adminReports;

  /// No description provided for @adminAccessRestricted.
  ///
  /// In en, this message translates to:
  /// **'Admin access required'**
  String get adminAccessRestricted;

  /// No description provided for @updateScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'App Updates'**
  String get updateScreenTitle;

  /// No description provided for @updateReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'SKAVIA Update Ready'**
  String get updateReadyTitle;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Required App Update'**
  String get updateRequiredTitle;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Your app is up to date'**
  String get updateUpToDate;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading Official APK...'**
  String get updateDownloading;

  /// No description provided for @updateVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying SHA-256 checksum...'**
  String get updateVerifying;

  /// No description provided for @updateCancelDownload.
  ///
  /// In en, this message translates to:
  /// **'Cancel Download'**
  String get updateCancelDownload;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeHoursAgo(int count);

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeYesterday;

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String timeDaysAgo(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
