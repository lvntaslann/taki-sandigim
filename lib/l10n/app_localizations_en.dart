// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Takı Sandığım';

  @override
  String get onboardingTagline =>
      'Easily record your wedding,\nengagement and henna gifts';

  @override
  String get onboardingBullet1 =>
      'Track who gave what, and what you gave, all in one place';

  @override
  String get onboardingBullet2 =>
      'Scan your gift notebook or invitation with the camera to import details automatically';

  @override
  String get onboardingBullet3 => 'Keep gifts received and given separate';

  @override
  String get onboardingStart => 'Let\'s Get Started';

  @override
  String get continueButton => 'Continue';

  @override
  String get skipButton => 'SKIP';

  @override
  String get nameEntryTitle => 'What Should We Call You?';

  @override
  String get nameLabel => 'Name:';

  @override
  String get nameRequiredError => 'Please enter your name';

  @override
  String get emailEntryTitle => 'Enter your email address\nfor backup...';

  @override
  String get emailLabel => 'Email:';

  @override
  String get emailRequiredError => 'Please enter your email address';

  @override
  String get emailInvalidError => 'Please enter a valid email address';

  @override
  String get giftTypeQuarterGold => 'Quarter Gold';

  @override
  String get giftTypeHalfGold => 'Half Gold';

  @override
  String get giftTypeFullGold => 'Full Gold';

  @override
  String get giftTypeGremseGold => 'Gremse Gold';

  @override
  String get giftTypeGramGold => 'Gram Gold';

  @override
  String get giftTypeBracelet => 'Bracelet';

  @override
  String get giftTypeNecklace => 'Necklace';

  @override
  String get giftTypeCash => 'Cash';

  @override
  String get giftTypeOther => 'Other';

  @override
  String get giftDirectionReceived => 'Received';

  @override
  String get giftDirectionGiven => 'Given';

  @override
  String get relationFamily => 'Family';

  @override
  String get relationRelative => 'Relative';

  @override
  String get relationFriend => 'Friend';

  @override
  String get eventWedding => 'Wedding';

  @override
  String get eventEngagement => 'Engagement';

  @override
  String get eventHenna => 'Henna Night';

  @override
  String get eventNikah => 'Civil Ceremony';

  @override
  String get eventWeddingLocation => 'Given at the wedding';

  @override
  String get eventEngagementLocation => 'Given at the engagement';

  @override
  String get eventHennaLocation => 'Given at the henna night';

  @override
  String get eventNikahLocation => 'Given at the civil ceremony';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String daysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get upcomingWeddings => 'Upcoming Weddings';

  @override
  String get calendar => 'Calendar';

  @override
  String get greeting => 'Hello';

  @override
  String greetingWithName(String name) {
    return 'Hello, $name';
  }

  @override
  String get giftDistribution => 'Gift Breakdown';

  @override
  String get recordCount => 'Records';

  @override
  String recordCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return '$_temp0';
  }

  @override
  String get totalQuantity => 'Total Quantity';

  @override
  String quantityValue(String amount) {
    return '$amount pcs';
  }

  @override
  String get totalGram => 'Total Grams';

  @override
  String totalOf(String currency) {
    return 'Total $currency';
  }

  @override
  String get totalValue => 'Total Value';

  @override
  String get close => 'Close';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get totalGramGold => 'Total Gold (grams)';

  @override
  String get grandTotalValue => 'Grand Total Value';

  @override
  String get currencyUsd => 'Dollar';

  @override
  String get currencyEur => 'Euro';

  @override
  String get currencyGbp => 'Pound';

  @override
  String get receivedGiftsTitle => 'Gifts Received';

  @override
  String get givenGiftsTitle => 'Gifts Given';

  @override
  String get noReceivedGifts => 'You haven\'t received any gifts yet.';

  @override
  String get noGivenGifts => 'You haven\'t given any gifts yet.';

  @override
  String get addGift => 'Add Gift';

  @override
  String get noRecordsFound => 'No records found.';

  @override
  String get returnGiven => 'Returned';

  @override
  String get returnToGive => 'To return';

  @override
  String get returnReceived => 'Reciprocated';

  @override
  String get returnPending => 'Awaiting return';

  @override
  String get total => 'Total';

  @override
  String percent(int value) {
    return '$value%';
  }

  @override
  String get noUpcomingWeddings => 'No upcoming weddings.';

  @override
  String get scanInvitationHint =>
      'Scan an invitation to add one automatically.';

  @override
  String get scanInvitation => 'Scan Invitation';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get noRecordsYet => 'No records yet';

  @override
  String get navHome => 'home';

  @override
  String get navAnalytics => 'analytics';

  @override
  String get navProfile => 'profile';

  @override
  String get navSettings => 'settings';

  @override
  String get eventNotSpecified => 'Event not specified';

  @override
  String get allWeddings => 'All Weddings';

  @override
  String get noWeddingsYet => 'No weddings saved yet.';

  @override
  String get noWeddingOnDate => 'No weddings on this date.';

  @override
  String get weekdayMon => 'Mo';

  @override
  String get weekdayTue => 'Tu';

  @override
  String get weekdayWed => 'We';

  @override
  String get weekdayThu => 'Th';

  @override
  String get weekdayFri => 'Fr';

  @override
  String get weekdaySat => 'Sa';

  @override
  String get weekdaySun => 'Su';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get sendFeedbackSubtitle =>
      'Share your thoughts and suggestions with us';

  @override
  String get feedbackHint => 'Write your thoughts and suggestions...';

  @override
  String get feedbackThanks => 'Thanks for your feedback!';

  @override
  String get cancel => 'Cancel';

  @override
  String get send => 'Send';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'See how your data is used';

  @override
  String get privacyPolicyBody =>
      'Takı Sandığım uses the data you enter, such as your name, email and gift records, only for in-app calculations and backup. Your data is not shared with third parties and is stored securely on your device. You can update or delete your data at any time from the app settings.';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Turns on the dark theme across the app';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Reminders for upcoming weddings';

  @override
  String get goldRate => 'Gold Rate';

  @override
  String get goldRateSubtitle => 'Calculated from the current gram gold rate';

  @override
  String get help => 'Help';

  @override
  String get appVersion => 'App Version';

  @override
  String versionValue(String version) {
    return 'Version $version';
  }

  @override
  String get developers => 'Developers';

  @override
  String get developer => 'Developer';

  @override
  String get addRecordTitle => 'Add New Record';

  @override
  String get addManuallyTab => 'Add Manually';

  @override
  String get scanTab => 'Scan Notebook/Invitation';

  @override
  String get personName => 'Person\'s Name';

  @override
  String get personNameRequired => 'Name is required';

  @override
  String get whereGiven => 'Occasion';

  @override
  String get giftTypeLabel => 'Gift Type';

  @override
  String get amountPiecesOrGrams => 'Amount (pcs/grams)';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get enterValidSum => 'Enter a valid sum';

  @override
  String get fetchingRate => 'Fetching current rate...';

  @override
  String todayGramGoldRate(String rate) {
    return 'Today\'s gram gold rate: $rate';
  }

  @override
  String calculatedValue(String value) {
    return 'Calculated value: $value';
  }

  @override
  String get foreignCurrency => 'Foreign';

  @override
  String amountInCurrency(String currency) {
    return 'Amount ($currency)';
  }

  @override
  String get currency => 'Currency';

  @override
  String currentRate(String code, String rate) {
    return 'Current rate: 1 $code = $rate';
  }

  @override
  String tlEquivalent(String value) {
    return 'TL equivalent: $value';
  }

  @override
  String get date => 'Date';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get save => 'Save';

  @override
  String get ledgerTitle => 'My Ledger';

  @override
  String get ledgerSearchHint => 'Search your ledger...';

  @override
  String get noRecordsYetDot => 'No records yet.';

  @override
  String get noResults => 'No results found.';

  @override
  String get youGave => 'YOU GAVE';

  @override
  String get youReceived => 'YOU RECEIVED';

  @override
  String get totalBalanceTitle => 'Total Balance';

  @override
  String allRecordsCount(int count) {
    return 'All Records ($count)';
  }

  @override
  String get deleteRecordTitle => 'Delete record';

  @override
  String deleteRecordConfirm(String name, String giftType) {
    return 'Are you sure you want to delete the $giftType record for $name?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get categoryCurrency => 'Foreign Currency';

  @override
  String get rangeDay => 'Day';

  @override
  String get rangeWeek => 'Week';

  @override
  String get rangeMonth => 'Month';

  @override
  String get rangeYear => 'Year';

  @override
  String get rangeAll => 'All';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get notEnoughDataForAnalytics =>
      'Not enough records for analytics yet.';

  @override
  String get totalRecords => 'Total Records';

  @override
  String get personCount => 'People';

  @override
  String get netBalanceByPerson => 'Net Balance by Person';

  @override
  String get weOwe => 'We owe';

  @override
  String get theyOwe => 'They owe us';

  @override
  String get allBalanced => 'You\'re even with everyone.';

  @override
  String get valueAnalysis => 'Value Analysis';

  @override
  String get valueAnalysisHint =>
      'Tap a category to see its people and how values have changed.';

  @override
  String get currentGramGoldRate => 'Current Gram Gold Rate';

  @override
  String get updating => 'Updating...';

  @override
  String recordCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return '$_temp0';
  }

  @override
  String get noData => 'No data';

  @override
  String get receivedUpper => 'RECEIVED';

  @override
  String get givenUpper => 'GIVEN';

  @override
  String get balanced => 'All even';

  @override
  String personGave(String name) {
    return '$name gave';
  }

  @override
  String get weGave => 'We gave';

  @override
  String valueInfoCurrencyBasis(String code) {
    return 'The original value uses the $code rate from when you added the record. Today\'s value is recalculated with the current exchange rate.';
  }

  @override
  String get valueInfoGoldBasis =>
      'The original value uses the gold rate from when you added the record. Today\'s value is recalculated with the current gram gold rate.';

  @override
  String get valueInfoNoBasis =>
      'This record was added without a rate, so its value doesn\'t change over time; the original and today\'s value are the same.';

  @override
  String get valueInfoTitle => 'How is this chart calculated?';

  @override
  String valueInfoBody(String basis) {
    return '$basis The points in between aren\'t real market data; they\'re a linear estimate to visualize the change between the two values. The period selector above only changes which time window of the same line is shown.';
  }

  @override
  String get gotIt => 'Got it';

  @override
  String dateGiven(String date) {
    return 'Date given: $date';
  }

  @override
  String currentGramGoldRateValue(String rate) {
    return 'Current gram gold rate: $rate';
  }

  @override
  String get basisGold => 'Gold';

  @override
  String get basisFixed => 'Fixed';

  @override
  String get valueThen => 'Original value';

  @override
  String get valueNow => 'Today\'s value';

  @override
  String get valueIncrease => 'Value Change';

  @override
  String get valueChangeChart => 'Value Change Chart';

  @override
  String get valueChartHint =>
      'End points are real; the line between is an estimate.';

  @override
  String get lowest => 'Lowest';

  @override
  String get highest => 'Highest';

  @override
  String get average => 'Average';

  @override
  String get searchByName => 'Search by name...';

  @override
  String get noRecordsInCategory => 'No records in this category.';

  @override
  String get nameSaved => 'Name saved.';

  @override
  String get emailSaved => 'Email address saved.';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutShort => 'Log Out';

  @override
  String get logOutConfirm => 'Are you sure you want to log out?';

  @override
  String get logOutHint => 'Log out of your account.';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Deleting your account will permanently remove your profile and all your gift records. This can\'t be undone. Do you want to continue?';

  @override
  String get deleteAccountHint => 'All your data will be permanently deleted.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get yourName => 'Your Name';

  @override
  String get yourNameHint => 'Used in the greeting on the Home screen.';

  @override
  String get nameField => 'Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailAddressHint => 'Used for backup and notifications.';

  @override
  String get emailField => 'Email';

  @override
  String get specialDates => 'Your Special Dates';

  @override
  String eventDate(String event) {
    return '$event Date';
  }

  @override
  String get pickDate => 'Pick a date';

  @override
  String get giftListReports => 'Gift List Reports';

  @override
  String get giftListReportsHint => 'Download or share as PDF or Excel.';

  @override
  String get goPremium => 'Go Premium';

  @override
  String get goPremiumHint =>
      'Ad-free experience, more scans and flexible exports';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get premiumActiveHint => 'You\'re enjoying ad-free, unlimited use.';

  @override
  String get exportDocumentTitle => 'Takı Sandığım - My Gift List';

  @override
  String get exportSheetGifts => 'My Gift List';

  @override
  String get exportSheetWeddings => 'Invitations';

  @override
  String get exportColDate => 'Date';

  @override
  String get exportColPerson => 'Person';

  @override
  String get exportColGift => 'Gift';

  @override
  String get exportColAmount => 'Amount';

  @override
  String get exportColUnit => 'Unit';

  @override
  String get exportColValueTl => 'Value (TL)';

  @override
  String get exportColDirection => 'Direction';

  @override
  String get exportColTitle => 'Title';

  @override
  String get exportColLocation => 'Location';

  @override
  String get exportColNote => 'Note';

  @override
  String get importNoSheet => 'No readable sheet found in the file.';

  @override
  String get importEmptyFile => 'The file is empty.';

  @override
  String get importWrongFormat =>
      'This file isn\'t in Takı Sandığım format. Please choose an Excel file exported from the app.';

  @override
  String get importSourceExcel => 'Excel File';

  @override
  String get importSourcePdf => 'PDF File';

  @override
  String get importSourceTitle => 'Which file should we import?';

  @override
  String get importSourceHint => 'Choose a file you exported earlier.';

  @override
  String get importSourceExcelHint => '.xlsx file exported from the app';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get noGiftRecordsYet => 'No gift records yet.';

  @override
  String reportFailed(String error) {
    return 'Couldn\'t create the report: $error';
  }

  @override
  String get pdfImportComingSoon => 'Importing from PDF is coming soon.';

  @override
  String importResult(int gifts, int weddings) {
    String _temp0 = intl.Intl.pluralLogic(
      gifts,
      locale: localeName,
      other: '$gifts records',
      one: '1 record',
    );
    String _temp1 = intl.Intl.pluralLogic(
      weddings,
      locale: localeName,
      other: '$weddings invitations',
      one: '1 invitation',
    );
    return 'Added $_temp0 and $_temp1.';
  }

  @override
  String importFailed(String error) {
    return 'Couldn\'t import data: $error';
  }

  @override
  String shareFailed(String error) {
    return 'Couldn\'t share: $error';
  }

  @override
  String get reportsTitle => 'Reports';

  @override
  String get giftListReport => 'Gift List Report';

  @override
  String get giftListReportHint => 'Export your data as PDF or Excel.';

  @override
  String get pdfReport => 'PDF Report (A4)';

  @override
  String get pdfReportHint => 'Detailed gift list';

  @override
  String get excelReportHint => 'Editable spreadsheet';

  @override
  String get share => 'Share';

  @override
  String get shareHint => 'Share details with family members';

  @override
  String get importData => 'Import Data';

  @override
  String get importDataHint => 'Import an Excel file you exported earlier';

  @override
  String get premiumRequired => 'Premium required';

  @override
  String get plansLoadFailed =>
      'Couldn\'t load plans. Check your connection and try again.';

  @override
  String get purchaseFailed => 'Purchase failed, please try again.';

  @override
  String get purchaseRestored => 'Your purchase has been restored.';

  @override
  String get nothingToRestore => 'No active purchase found to restore.';

  @override
  String get restoreFailed => 'Restore failed.';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planThreeMonths => '3 Months';

  @override
  String get planSixMonths => '6 Months';

  @override
  String get planAnnual => 'Annual';

  @override
  String get planGeneric => 'Plan';

  @override
  String get restore => 'Restore';

  @override
  String get comingSoonTitle => 'Coming Soon';

  @override
  String get premiumComingSoon =>
      'Premium subscriptions will be available here soon.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get premiumHeadlineStart => 'Enjoy every';

  @override
  String get premiumHeadlineEnd => 'feature';

  @override
  String get featureNoAds => 'Ad-free experience';

  @override
  String get featureNoAdsHint => 'Use the app without any ads.';

  @override
  String get featureMoreScans => 'More scans';

  @override
  String get featureMoreScansHint => 'Your daily photo scan limit goes up.';

  @override
  String get featureExport => 'Flexible exports';

  @override
  String get featureExportHint =>
      'Download your records in the format you like.';

  @override
  String get noPlansAvailable => 'No plans are available right now.';

  @override
  String get terms => 'Terms';

  @override
  String get privacy => 'Privacy';

  @override
  String bestValueDiscount(int percent) {
    return 'Best Value · $percent% off';
  }

  @override
  String get noCommitment => 'No commitment';

  @override
  String perMonth(String price) {
    return '$price/mo';
  }

  @override
  String get welcomePremium => 'Welcome to Premium!';

  @override
  String get welcomePremiumHint =>
      'Ad-free use, more scans and flexible exports are now yours.';

  @override
  String get resetSoon => 'shortly';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String textReadFailed(String reason) {
    return 'Couldn\'t read the text: $reason';
  }

  @override
  String get aiRateLimited =>
      'The AI is busy right now. Please try again in a few seconds.';

  @override
  String get aiUnexpectedResponse =>
      'The AI response was missing an expected field.';

  @override
  String get aiNoUserId => 'User ID not found, please try again.';

  @override
  String get aiAppCheckFailed =>
      'Security verification failed, please try again.';

  @override
  String aiRequestFailed(String detail) {
    return 'AI evaluation request failed: $detail';
  }

  @override
  String scansRemaining(int remaining, int limit) {
    return '$remaining/$limit scans left';
  }

  @override
  String scansExhausted(String resetIn) {
    return 'No scans left · resets in $resetIn';
  }

  @override
  String invitationTimeNote(String time) {
    return 'Time: $time';
  }

  @override
  String get scanWithCamera => 'Scan with Camera';

  @override
  String get pickFromGallery => 'Choose from Gallery';

  @override
  String get scanIdleTitle => 'Scan a gift notebook page or an invitation';

  @override
  String get scanIdleHint =>
      'Take a photo or pick one from your gallery, and the AI reads it for you.';

  @override
  String get sourceNotebookShort => 'Notebook';

  @override
  String get sourceInvitation => 'Invitation';

  @override
  String get invitationReadFailed =>
      'Couldn\'t read details from the invitation.';

  @override
  String itemSaved(String title) {
    return '$title saved.';
  }

  @override
  String get noReadableLines => 'No readable lines found in the image.';

  @override
  String recordPosition(int current, int total) {
    return 'Record $current / $total';
  }

  @override
  String addedCount(int count) {
    return '$count added';
  }

  @override
  String lineAdded(String name) {
    return '$name added. Swipe to see the other records.';
  }

  @override
  String get scanSourceTitle => 'What are you scanning?';

  @override
  String get scanSourceHint =>
      'Choose the image type so we read it the right way.';

  @override
  String get sourceNotebook => 'Gift Notebook';

  @override
  String get sourceNotebookHint => 'A page with names, gift types and amounts';

  @override
  String get sourceInvitationHint => 'Couple\'s names, date, time and location';

  @override
  String get scanLimitTitle => 'You\'re out of scans';

  @override
  String scanLimitBody(String resetIn) {
    return 'Your free scans reset in $resetIn. Go Premium for unlimited scans.';
  }

  @override
  String get cameraNotFound => 'No camera found.';

  @override
  String cameraOpenFailed(String error) {
    return 'Couldn\'t open the camera: $error';
  }

  @override
  String photoCaptureFailed(String error) {
    return 'Couldn\'t take the photo: $error';
  }

  @override
  String get useThisImage => 'Do you want to use this image?';

  @override
  String get use => 'Use';

  @override
  String get personNameEmpty => 'Name can\'t be empty.';

  @override
  String scannedText(String text) {
    return 'Scanned: \"$text\"';
  }

  @override
  String get relation => 'Relation';

  @override
  String get fetchingRateShort => 'Fetching rate...';

  @override
  String get skip => 'Skip';

  @override
  String get add => 'Add';

  @override
  String get coupleNameEmpty => 'Couple/honoree name can\'t be empty.';

  @override
  String get pleasePickDate => 'Please pick a date.';

  @override
  String get invitationReadDetails => 'Details read from the invitation';

  @override
  String get coupleName => 'Couple / Honoree';

  @override
  String get timeOptional => 'Time (optional)';

  @override
  String get locationOptional => 'Venue / Location (optional)';

  @override
  String get addToUpcomingWeddings => 'Add to Upcoming Weddings';
}
