import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takı Sandığım'**
  String get appTitle;

  /// No description provided for @onboardingTagline.
  ///
  /// In tr, this message translates to:
  /// **'Düğün, nişan ve kına\nhediyelerini kolayca kaydedin'**
  String get onboardingTagline;

  /// No description provided for @onboardingBullet1.
  ///
  /// In tr, this message translates to:
  /// **'Kimin ne taktığını, ne verdiğinizi tek bir yerde takip edin'**
  String get onboardingBullet1;

  /// No description provided for @onboardingBullet2.
  ///
  /// In tr, this message translates to:
  /// **'Takı defterinizi veya davetiyenizi kamera ile tarayarak bilgileri otomatik olarak sisteme aktarın'**
  String get onboardingBullet2;

  /// No description provided for @onboardingBullet3.
  ///
  /// In tr, this message translates to:
  /// **'Takılanlar ve verilenler olarak ayırın'**
  String get onboardingBullet3;

  /// No description provided for @onboardingStart.
  ///
  /// In tr, this message translates to:
  /// **'Haydi Başlayalım'**
  String get onboardingStart;

  /// No description provided for @continueButton.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get continueButton;

  /// Mail girme ekranındaki atla bağlantısı, büyük harfle gösterilir.
  ///
  /// In tr, this message translates to:
  /// **'ATLA'**
  String get skipButton;

  /// No description provided for @nameEntryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Size Nasıl Hitap Edelim?'**
  String get nameEntryTitle;

  /// No description provided for @nameLabel.
  ///
  /// In tr, this message translates to:
  /// **'İsim:'**
  String get nameLabel;

  /// No description provided for @nameRequiredError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen isminizi giriniz'**
  String get nameRequiredError;

  /// No description provided for @emailEntryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme için mail adresinizi\ngiriniz...'**
  String get emailEntryTitle;

  /// No description provided for @emailLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mail:'**
  String get emailLabel;

  /// No description provided for @emailRequiredError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen mail adresinizi giriniz'**
  String get emailRequiredError;

  /// No description provided for @emailInvalidError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir mail adresi giriniz'**
  String get emailInvalidError;

  /// No description provided for @giftTypeQuarterGold.
  ///
  /// In tr, this message translates to:
  /// **'Çeyrek Altın'**
  String get giftTypeQuarterGold;

  /// No description provided for @giftTypeHalfGold.
  ///
  /// In tr, this message translates to:
  /// **'Yarım Altın'**
  String get giftTypeHalfGold;

  /// No description provided for @giftTypeFullGold.
  ///
  /// In tr, this message translates to:
  /// **'Tam Altın'**
  String get giftTypeFullGold;

  /// No description provided for @giftTypeGremseGold.
  ///
  /// In tr, this message translates to:
  /// **'Gremse Altın'**
  String get giftTypeGremseGold;

  /// No description provided for @giftTypeGramGold.
  ///
  /// In tr, this message translates to:
  /// **'Gram Altın'**
  String get giftTypeGramGold;

  /// No description provided for @giftTypeBracelet.
  ///
  /// In tr, this message translates to:
  /// **'Bilezik'**
  String get giftTypeBracelet;

  /// No description provided for @giftTypeNecklace.
  ///
  /// In tr, this message translates to:
  /// **'Kolye'**
  String get giftTypeNecklace;

  /// No description provided for @giftTypeCash.
  ///
  /// In tr, this message translates to:
  /// **'Para'**
  String get giftTypeCash;

  /// No description provided for @giftTypeOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get giftTypeOther;

  /// No description provided for @giftDirectionReceived.
  ///
  /// In tr, this message translates to:
  /// **'Bize Takılan'**
  String get giftDirectionReceived;

  /// No description provided for @giftDirectionGiven.
  ///
  /// In tr, this message translates to:
  /// **'Bizim Taktığımız'**
  String get giftDirectionGiven;

  /// No description provided for @relationFamily.
  ///
  /// In tr, this message translates to:
  /// **'Aile'**
  String get relationFamily;

  /// No description provided for @relationRelative.
  ///
  /// In tr, this message translates to:
  /// **'Akraba'**
  String get relationRelative;

  /// No description provided for @relationFriend.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş'**
  String get relationFriend;

  /// No description provided for @eventWedding.
  ///
  /// In tr, this message translates to:
  /// **'Düğün'**
  String get eventWedding;

  /// No description provided for @eventEngagement.
  ///
  /// In tr, this message translates to:
  /// **'Nişan'**
  String get eventEngagement;

  /// No description provided for @eventHenna.
  ///
  /// In tr, this message translates to:
  /// **'Kına'**
  String get eventHenna;

  /// No description provided for @eventNikah.
  ///
  /// In tr, this message translates to:
  /// **'Nikah'**
  String get eventNikah;

  /// No description provided for @eventWeddingLocation.
  ///
  /// In tr, this message translates to:
  /// **'Düğünde takıldı'**
  String get eventWeddingLocation;

  /// No description provided for @eventEngagementLocation.
  ///
  /// In tr, this message translates to:
  /// **'Nişanda takıldı'**
  String get eventEngagementLocation;

  /// No description provided for @eventHennaLocation.
  ///
  /// In tr, this message translates to:
  /// **'Kınada takıldı'**
  String get eventHennaLocation;

  /// No description provided for @eventNikahLocation.
  ///
  /// In tr, this message translates to:
  /// **'Nikahta takıldı'**
  String get eventNikahLocation;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get tomorrow;

  /// No description provided for @daysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün önce'**
  String daysAgo(int count);

  /// No description provided for @daysLater.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün sonra'**
  String daysLater(int count);

  /// No description provided for @upcomingWeddings.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan Düğünler'**
  String get upcomingWeddings;

  /// No description provided for @calendar.
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get calendar;

  /// No description provided for @greeting.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba'**
  String get greeting;

  /// No description provided for @greetingWithName.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba, {name}'**
  String greetingWithName(String name);

  /// No description provided for @giftDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Hediye Dağılımı'**
  String get giftDistribution;

  /// No description provided for @recordCount.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Sayısı'**
  String get recordCount;

  /// No description provided for @recordCountValue.
  ///
  /// In tr, this message translates to:
  /// **'{count} adet kayıt'**
  String recordCountValue(int count);

  /// No description provided for @totalQuantity.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Adet'**
  String get totalQuantity;

  /// No description provided for @quantityValue.
  ///
  /// In tr, this message translates to:
  /// **'{amount} adet'**
  String quantityValue(String amount);

  /// No description provided for @totalGram.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Gram'**
  String get totalGram;

  /// No description provided for @totalOf.
  ///
  /// In tr, this message translates to:
  /// **'Toplam {currency}'**
  String totalOf(String currency);

  /// No description provided for @totalValue.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Değer'**
  String get totalValue;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @grandTotal.
  ///
  /// In tr, this message translates to:
  /// **'Genel Toplam'**
  String get grandTotal;

  /// No description provided for @totalGramGold.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Gram Altın'**
  String get totalGramGold;

  /// No description provided for @grandTotalValue.
  ///
  /// In tr, this message translates to:
  /// **'Genel Toplam Değer'**
  String get grandTotalValue;

  /// No description provided for @currencyUsd.
  ///
  /// In tr, this message translates to:
  /// **'Dolar'**
  String get currencyUsd;

  /// No description provided for @currencyEur.
  ///
  /// In tr, this message translates to:
  /// **'Euro'**
  String get currencyEur;

  /// No description provided for @currencyGbp.
  ///
  /// In tr, this message translates to:
  /// **'Sterlin'**
  String get currencyGbp;

  /// No description provided for @receivedGiftsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bize Takılanlar'**
  String get receivedGiftsTitle;

  /// No description provided for @givenGiftsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bizim Taktığımız'**
  String get givenGiftsTitle;

  /// No description provided for @noReceivedGifts.
  ///
  /// In tr, this message translates to:
  /// **'Henüz sana takılan bir şey yok.'**
  String get noReceivedGifts;

  /// No description provided for @noGivenGifts.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kimseye takı vermedin.'**
  String get noGivenGifts;

  /// No description provided for @addGift.
  ///
  /// In tr, this message translates to:
  /// **'Takı Ekle'**
  String get addGift;

  /// No description provided for @noRecordsFound.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt bulunamadı.'**
  String get noRecordsFound;

  /// No description provided for @returnGiven.
  ///
  /// In tr, this message translates to:
  /// **'Karşılığı Verildi'**
  String get returnGiven;

  /// No description provided for @returnToGive.
  ///
  /// In tr, this message translates to:
  /// **'Karşılığı Verilecek'**
  String get returnToGive;

  /// No description provided for @returnReceived.
  ///
  /// In tr, this message translates to:
  /// **'Karşılığı Alındı'**
  String get returnReceived;

  /// No description provided for @returnPending.
  ///
  /// In tr, this message translates to:
  /// **'Karşılığı Bekleniyor'**
  String get returnPending;

  /// No description provided for @total.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get total;

  /// No description provided for @percent.
  ///
  /// In tr, this message translates to:
  /// **'%{value}'**
  String percent(int value);

  /// No description provided for @noUpcomingWeddings.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan bir düğün yok.'**
  String get noUpcomingWeddings;

  /// No description provided for @scanInvitationHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir davetiye tarayarak otomatik ekleyebilirsin.'**
  String get scanInvitationHint;

  /// No description provided for @scanInvitation.
  ///
  /// In tr, this message translates to:
  /// **'Davetiye Tara'**
  String get scanInvitation;

  /// No description provided for @totalBalance.
  ///
  /// In tr, this message translates to:
  /// **'Toplam bakiye'**
  String get totalBalance;

  /// No description provided for @noRecordsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıt yok'**
  String get noRecordsYet;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'ana sayfa'**
  String get navHome;

  /// No description provided for @navAnalytics.
  ///
  /// In tr, this message translates to:
  /// **'analiz'**
  String get navAnalytics;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'profil'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In tr, this message translates to:
  /// **'ayarlar'**
  String get navSettings;

  /// No description provided for @eventNotSpecified.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik belirtilmemiş'**
  String get eventNotSpecified;

  /// No description provided for @allWeddings.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Düğünler'**
  String get allWeddings;

  /// No description provided for @noWeddingsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıtlı bir düğün yok.'**
  String get noWeddingsYet;

  /// No description provided for @noWeddingOnDate.
  ///
  /// In tr, this message translates to:
  /// **'Bu tarihte bir düğün yok.'**
  String get noWeddingOnDate;

  /// No description provided for @weekdayMon.
  ///
  /// In tr, this message translates to:
  /// **'Pt'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In tr, this message translates to:
  /// **'Sa'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In tr, this message translates to:
  /// **'Ça'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In tr, this message translates to:
  /// **'Pe'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In tr, this message translates to:
  /// **'Cu'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In tr, this message translates to:
  /// **'Ct'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In tr, this message translates to:
  /// **'Pz'**
  String get weekdaySun;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @sendFeedback.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim Gönder'**
  String get sendFeedback;

  /// No description provided for @sendFeedbackSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Görüş ve önerilerinizi bizimle paylaşın'**
  String get sendFeedbackSubtitle;

  /// No description provided for @feedbackHint.
  ///
  /// In tr, this message translates to:
  /// **'Görüş ve önerilerinizi yazın...'**
  String get feedbackHint;

  /// No description provided for @feedbackThanks.
  ///
  /// In tr, this message translates to:
  /// **'Geri bildiriminiz için teşekkürler!'**
  String get feedbackThanks;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @send.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Verilerinizin nasıl kullanıldığını görüntüleyin'**
  String get privacyPolicySubtitle;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In tr, this message translates to:
  /// **'Takı Sandığım, girdiğiniz isim, mail ve hediye kayıtları gibi verileri yalnızca uygulama içindeki hesaplamalar ve yedekleme amacıyla kullanır. Verileriniz üçüncü taraflarla paylaşılmaz ve cihazınızda güvenli şekilde saklanır. Uygulama ayarlarından dilediğiniz zaman verilerinizi güncelleyebilir veya silebilirsiniz.'**
  String get privacyPolicyBody;

  /// No description provided for @darkMode.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Mod'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama genelinde koyu temayı etkinleştirir'**
  String get darkModeSubtitle;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan düğün hatırlatmaları'**
  String get notificationsSubtitle;

  /// No description provided for @goldRate.
  ///
  /// In tr, this message translates to:
  /// **'Altın Kuru'**
  String get goldRate;

  /// No description provided for @goldRateSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Güncel gram altın kuruna göre hesaplanır'**
  String get goldRateSubtitle;

  /// No description provided for @help.
  ///
  /// In tr, this message translates to:
  /// **'Yardım'**
  String get help;

  /// No description provided for @appVersion.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Versiyonu'**
  String get appVersion;

  /// No description provided for @versionValue.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version}'**
  String versionValue(String version);

  /// No description provided for @developers.
  ///
  /// In tr, this message translates to:
  /// **'Geliştiriciler'**
  String get developers;

  /// No description provided for @developer.
  ///
  /// In tr, this message translates to:
  /// **'Geliştirici'**
  String get developer;

  /// No description provided for @addRecordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kayıt Ekle'**
  String get addRecordTitle;

  /// No description provided for @addManuallyTab.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Ekle'**
  String get addManuallyTab;

  /// No description provided for @scanTab.
  ///
  /// In tr, this message translates to:
  /// **'Defter/Davetiye Tara'**
  String get scanTab;

  /// No description provided for @personName.
  ///
  /// In tr, this message translates to:
  /// **'Kişi Adı'**
  String get personName;

  /// No description provided for @personNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Kişi adı gerekli'**
  String get personNameRequired;

  /// No description provided for @whereGiven.
  ///
  /// In tr, this message translates to:
  /// **'Nerede Takıldı'**
  String get whereGiven;

  /// No description provided for @giftTypeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Takı Türü'**
  String get giftTypeLabel;

  /// No description provided for @amountPiecesOrGrams.
  ///
  /// In tr, this message translates to:
  /// **'Miktar (adet/gram)'**
  String get amountPiecesOrGrams;

  /// No description provided for @enterValidAmount.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir miktar girin'**
  String get enterValidAmount;

  /// No description provided for @enterValidSum.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar girin'**
  String get enterValidSum;

  /// No description provided for @fetchingRate.
  ///
  /// In tr, this message translates to:
  /// **'Güncel kur alınıyor...'**
  String get fetchingRate;

  /// No description provided for @todayGramGoldRate.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü gram altın kuru: {rate}'**
  String todayGramGoldRate(String rate);

  /// No description provided for @calculatedValue.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplanan değer: {value}'**
  String calculatedValue(String value);

  /// No description provided for @foreignCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Döviz'**
  String get foreignCurrency;

  /// No description provided for @amountInCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Tutar ({currency})'**
  String amountInCurrency(String currency);

  /// No description provided for @currency.
  ///
  /// In tr, this message translates to:
  /// **'Para Birimi'**
  String get currency;

  /// No description provided for @currentRate.
  ///
  /// In tr, this message translates to:
  /// **'Güncel kur: 1 {code} = {rate}'**
  String currentRate(String code, String rate);

  /// No description provided for @tlEquivalent.
  ///
  /// In tr, this message translates to:
  /// **'TL karşılığı: {value}'**
  String tlEquivalent(String value);

  /// No description provided for @date.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get date;

  /// No description provided for @noteOptional.
  ///
  /// In tr, this message translates to:
  /// **'Not (opsiyonel)'**
  String get noteOptional;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @ledgerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Defterim'**
  String get ledgerTitle;

  /// No description provided for @ledgerSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Defterim içinde ara...'**
  String get ledgerSearchHint;

  /// No description provided for @noRecordsYetDot.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir kayıt yok.'**
  String get noRecordsYetDot;

  /// No description provided for @noResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı.'**
  String get noResults;

  /// No description provided for @youGave.
  ///
  /// In tr, this message translates to:
  /// **'SENİN TAKTIĞIN'**
  String get youGave;

  /// No description provided for @youReceived.
  ///
  /// In tr, this message translates to:
  /// **'SANA TAKILAN'**
  String get youReceived;

  /// No description provided for @totalBalanceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Bakiye'**
  String get totalBalanceTitle;

  /// No description provided for @allRecordsCount.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Kayıtlar ({count})'**
  String allRecordsCount(int count);

  /// No description provided for @deleteRecordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydı sil'**
  String get deleteRecordTitle;

  /// No description provided for @deleteRecordConfirm.
  ///
  /// In tr, this message translates to:
  /// **'{name} - {giftType} kaydını silmek istediğine emin misin?'**
  String deleteRecordConfirm(String name, String giftType);

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @categoryCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Döviz'**
  String get categoryCurrency;

  /// No description provided for @rangeDay.
  ///
  /// In tr, this message translates to:
  /// **'Gün'**
  String get rangeDay;

  /// No description provided for @rangeWeek.
  ///
  /// In tr, this message translates to:
  /// **'Hafta'**
  String get rangeWeek;

  /// No description provided for @rangeMonth.
  ///
  /// In tr, this message translates to:
  /// **'Ay'**
  String get rangeMonth;

  /// No description provided for @rangeYear.
  ///
  /// In tr, this message translates to:
  /// **'Yıl'**
  String get rangeYear;

  /// No description provided for @rangeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get rangeAll;

  /// No description provided for @analyticsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Analiz'**
  String get analyticsTitle;

  /// No description provided for @notEnoughDataForAnalytics.
  ///
  /// In tr, this message translates to:
  /// **'Analiz için henüz yeterli kayıt yok.'**
  String get notEnoughDataForAnalytics;

  /// No description provided for @totalRecords.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Kayıt'**
  String get totalRecords;

  /// No description provided for @personCount.
  ///
  /// In tr, this message translates to:
  /// **'Kişi Sayısı'**
  String get personCount;

  /// No description provided for @netBalanceByPerson.
  ///
  /// In tr, this message translates to:
  /// **'Kişi Bazında Net Bakiye'**
  String get netBalanceByPerson;

  /// No description provided for @weOwe.
  ///
  /// In tr, this message translates to:
  /// **'Biz borçluyuz'**
  String get weOwe;

  /// No description provided for @theyOwe.
  ///
  /// In tr, this message translates to:
  /// **'Bize borçlu'**
  String get theyOwe;

  /// No description provided for @allBalanced.
  ///
  /// In tr, this message translates to:
  /// **'Herkesle hesap dengede.'**
  String get allBalanced;

  /// No description provided for @valueAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'Değer Analizi'**
  String get valueAnalysis;

  /// No description provided for @valueAnalysisHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir kategoriye dokun, içindeki kişileri ve değer değişimlerini incele.'**
  String get valueAnalysisHint;

  /// No description provided for @currentGramGoldRate.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Gram Altın Kuru'**
  String get currentGramGoldRate;

  /// No description provided for @updating.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleniyor...'**
  String get updating;

  /// No description provided for @recordCountShort.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıt'**
  String recordCountShort(int count);

  /// No description provided for @noData.
  ///
  /// In tr, this message translates to:
  /// **'Veri yok'**
  String get noData;

  /// No description provided for @receivedUpper.
  ///
  /// In tr, this message translates to:
  /// **'BİZE GELEN'**
  String get receivedUpper;

  /// No description provided for @givenUpper.
  ///
  /// In tr, this message translates to:
  /// **'BİZİM VERDİĞİMİZ'**
  String get givenUpper;

  /// No description provided for @balanced.
  ///
  /// In tr, this message translates to:
  /// **'Hesap dengede'**
  String get balanced;

  /// No description provided for @personGave.
  ///
  /// In tr, this message translates to:
  /// **'{name} taktı'**
  String personGave(String name);

  /// No description provided for @weGave.
  ///
  /// In tr, this message translates to:
  /// **'Biz taktık'**
  String get weGave;

  /// No description provided for @valueInfoCurrencyBasis.
  ///
  /// In tr, this message translates to:
  /// **'O günkü değer, kaydı eklediğin andaki {code} kuruna göredir. Bugünkü değer ise güncel döviz kuruyla yeniden hesaplanır.'**
  String valueInfoCurrencyBasis(String code);

  /// No description provided for @valueInfoGoldBasis.
  ///
  /// In tr, this message translates to:
  /// **'O günkü değer, kaydı eklediğin andaki altın kuruna göredir. Bugünkü değer ise güncel gram altın kuruyla yeniden hesaplanır.'**
  String get valueInfoGoldBasis;

  /// No description provided for @valueInfoNoBasis.
  ///
  /// In tr, this message translates to:
  /// **'Bu kayıt bir kur bilgisiyle eklenmediği için değeri zamanla değişmez; o günkü ve bugünkü değer aynıdır.'**
  String get valueInfoNoBasis;

  /// No description provided for @valueInfoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu grafik nasıl hesaplanıyor?'**
  String get valueInfoTitle;

  /// No description provided for @valueInfoBody.
  ///
  /// In tr, this message translates to:
  /// **'{basis} Aradaki noktalar gerçek piyasa verisi değildir; sadece iki değer arasındaki değişimi görselleştirmek için doğrusal olarak tahmin edilmiştir. Üstteki dönem seçici sadece aynı doğrunun hangi zaman penceresini gösterdiğini değiştirir.'**
  String valueInfoBody(String basis);

  /// No description provided for @gotIt.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get gotIt;

  /// No description provided for @dateGiven.
  ///
  /// In tr, this message translates to:
  /// **'Takıldığı Tarih: {date}'**
  String dateGiven(String date);

  /// No description provided for @currentGramGoldRateValue.
  ///
  /// In tr, this message translates to:
  /// **'Güncel gram altın kuru: {rate}'**
  String currentGramGoldRateValue(String rate);

  /// No description provided for @basisGold.
  ///
  /// In tr, this message translates to:
  /// **'Altın'**
  String get basisGold;

  /// No description provided for @basisFixed.
  ///
  /// In tr, this message translates to:
  /// **'Sabit'**
  String get basisFixed;

  /// No description provided for @valueThen.
  ///
  /// In tr, this message translates to:
  /// **'O günkü değeri'**
  String get valueThen;

  /// No description provided for @valueNow.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü değeri'**
  String get valueNow;

  /// No description provided for @valueIncrease.
  ///
  /// In tr, this message translates to:
  /// **'Değer Artışı'**
  String get valueIncrease;

  /// No description provided for @valueChangeChart.
  ///
  /// In tr, this message translates to:
  /// **'Değer Değişimi Grafiği'**
  String get valueChangeChart;

  /// No description provided for @valueChartHint.
  ///
  /// In tr, this message translates to:
  /// **'Uç noktalar gerçek, aradaki çizgi tahminidir.'**
  String get valueChartHint;

  /// No description provided for @lowest.
  ///
  /// In tr, this message translates to:
  /// **'En Düşük'**
  String get lowest;

  /// No description provided for @highest.
  ///
  /// In tr, this message translates to:
  /// **'En Yüksek'**
  String get highest;

  /// No description provided for @average.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama'**
  String get average;

  /// No description provided for @searchByName.
  ///
  /// In tr, this message translates to:
  /// **'Kişi adına göre ara...'**
  String get searchByName;

  /// No description provided for @noRecordsInCategory.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoride bir kayıt yok.'**
  String get noRecordsInCategory;

  /// No description provided for @nameSaved.
  ///
  /// In tr, this message translates to:
  /// **'İsim kaydedildi.'**
  String get nameSaved;

  /// No description provided for @emailSaved.
  ///
  /// In tr, this message translates to:
  /// **'Mail adresi kaydedildi.'**
  String get emailSaved;

  /// No description provided for @logOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logOut;

  /// No description provided for @logOutShort.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış'**
  String get logOutShort;

  /// No description provided for @logOutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızdan çıkış yapmak istediğinize emin misiniz?'**
  String get logOutConfirm;

  /// No description provided for @logOutHint.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızdan çıkış yapın.'**
  String get logOutHint;

  /// No description provided for @deleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı silmek, profil bilgilerinizi ve tüm takı kayıtlarınızı kalıcı olarak silecektir. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountHint.
  ///
  /// In tr, this message translates to:
  /// **'Tüm verileriniz kalıcı olarak silinir.'**
  String get deleteAccountHint;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @yourName.
  ///
  /// In tr, this message translates to:
  /// **'Adınız'**
  String get yourName;

  /// No description provided for @yourNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa\'daki selamlamada kullanılır.'**
  String get yourNameHint;

  /// No description provided for @nameField.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get nameField;

  /// No description provided for @emailAddress.
  ///
  /// In tr, this message translates to:
  /// **'Mail Adresi'**
  String get emailAddress;

  /// No description provided for @emailAddressHint.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme ve bildirimler için kullanılır.'**
  String get emailAddressHint;

  /// No description provided for @emailField.
  ///
  /// In tr, this message translates to:
  /// **'Mail'**
  String get emailField;

  /// No description provided for @specialDates.
  ///
  /// In tr, this message translates to:
  /// **'Özel Günlerinizin Tarihi'**
  String get specialDates;

  /// No description provided for @eventDate.
  ///
  /// In tr, this message translates to:
  /// **'{event} Tarihi'**
  String eventDate(String event);

  /// No description provided for @pickDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih seçin'**
  String get pickDate;

  /// No description provided for @giftListReports.
  ///
  /// In tr, this message translates to:
  /// **'Takı Listesi Raporları'**
  String get giftListReports;

  /// No description provided for @giftListReportsHint.
  ///
  /// In tr, this message translates to:
  /// **'PDF, Excel olarak indir veya paylaş.'**
  String get giftListReportsHint;

  /// No description provided for @goPremium.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a Geç'**
  String get goPremium;

  /// No description provided for @goPremiumHint.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız deneyim, daha fazla tarama hakkı ve esnek dışa aktarım'**
  String get goPremiumHint;

  /// No description provided for @premiumActive.
  ///
  /// In tr, this message translates to:
  /// **'Premium Aktif'**
  String get premiumActive;

  /// No description provided for @premiumActiveHint.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız ve sınırsız kullanım keyfini çıkarıyorsun.'**
  String get premiumActiveHint;

  /// No description provided for @exportDocumentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takı Sandığım - Takı Listem'**
  String get exportDocumentTitle;

  /// Excel sayfa adı. Değiştirilirse eski dosyalar bu dilde içe aktarılamaz.
  ///
  /// In tr, this message translates to:
  /// **'Takı Listem'**
  String get exportSheetGifts;

  /// No description provided for @exportSheetWeddings.
  ///
  /// In tr, this message translates to:
  /// **'Davetiye Bilgileri'**
  String get exportSheetWeddings;

  /// Excel sütun başlığı. İçe aktarma bu başlıkla eşleştirir; değiştirmek eski dosyaları bozar.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get exportColDate;

  /// No description provided for @exportColPerson.
  ///
  /// In tr, this message translates to:
  /// **'Kişi'**
  String get exportColPerson;

  /// No description provided for @exportColGift.
  ///
  /// In tr, this message translates to:
  /// **'Hediye'**
  String get exportColGift;

  /// No description provided for @exportColAmount.
  ///
  /// In tr, this message translates to:
  /// **'Miktar'**
  String get exportColAmount;

  /// No description provided for @exportColUnit.
  ///
  /// In tr, this message translates to:
  /// **'Birim'**
  String get exportColUnit;

  /// No description provided for @exportColValueTl.
  ///
  /// In tr, this message translates to:
  /// **'Değer (TL)'**
  String get exportColValueTl;

  /// No description provided for @exportColDirection.
  ///
  /// In tr, this message translates to:
  /// **'Yön'**
  String get exportColDirection;

  /// No description provided for @exportColTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get exportColTitle;

  /// No description provided for @exportColLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get exportColLocation;

  /// No description provided for @exportColNote.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get exportColNote;

  /// No description provided for @importNoSheet.
  ///
  /// In tr, this message translates to:
  /// **'Dosyada okunabilir bir sayfa bulunamadı.'**
  String get importNoSheet;

  /// No description provided for @importEmptyFile.
  ///
  /// In tr, this message translates to:
  /// **'Dosya boş.'**
  String get importEmptyFile;

  /// No description provided for @importWrongFormat.
  ///
  /// In tr, this message translates to:
  /// **'Bu dosya Takı Sandığım formatında değil. Lütfen uygulamadan dışa aktarılmış bir Excel dosyası seçin.'**
  String get importWrongFormat;

  /// No description provided for @importSourceExcel.
  ///
  /// In tr, this message translates to:
  /// **'Excel Dosyası'**
  String get importSourceExcel;

  /// No description provided for @importSourcePdf.
  ///
  /// In tr, this message translates to:
  /// **'PDF Dosyası'**
  String get importSourcePdf;

  /// No description provided for @importSourceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hangi dosyadan yükleyelim?'**
  String get importSourceTitle;

  /// No description provided for @importSourceHint.
  ///
  /// In tr, this message translates to:
  /// **'Daha önce dışa aktardığın dosyayı seç.'**
  String get importSourceHint;

  /// No description provided for @importSourceExcelHint.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamadan dışa aktarılmış .xlsx dosyası'**
  String get importSourceExcelHint;

  /// No description provided for @comingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Yakında eklenecek'**
  String get comingSoon;

  /// No description provided for @noGiftRecordsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir takı kaydı yok.'**
  String get noGiftRecordsYet;

  /// No description provided for @reportFailed.
  ///
  /// In tr, this message translates to:
  /// **'Rapor oluşturulamadı: {error}'**
  String reportFailed(String error);

  /// No description provided for @pdfImportComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'PDF\'den içe aktarma yakında eklenecek.'**
  String get pdfImportComingSoon;

  /// No description provided for @importResult.
  ///
  /// In tr, this message translates to:
  /// **'{gifts} kayıt, {weddings} davetiye eklendi.'**
  String importResult(int gifts, int weddings);

  /// No description provided for @importFailed.
  ///
  /// In tr, this message translates to:
  /// **'Veriler içe aktarılamadı: {error}'**
  String importFailed(String error);

  /// No description provided for @shareFailed.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılamadı: {error}'**
  String shareFailed(String error);

  /// No description provided for @reportsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Raporlar'**
  String get reportsTitle;

  /// No description provided for @giftListReport.
  ///
  /// In tr, this message translates to:
  /// **'Takı Listesi Raporu'**
  String get giftListReport;

  /// No description provided for @giftListReportHint.
  ///
  /// In tr, this message translates to:
  /// **'Verilerinizi PDF veya Excel formatında dışa aktarın.'**
  String get giftListReportHint;

  /// No description provided for @pdfReport.
  ///
  /// In tr, this message translates to:
  /// **'PDF Raporu (A4)'**
  String get pdfReport;

  /// No description provided for @pdfReportHint.
  ///
  /// In tr, this message translates to:
  /// **'Detaylı takı listesi'**
  String get pdfReportHint;

  /// No description provided for @excelReportHint.
  ///
  /// In tr, this message translates to:
  /// **'Düzenlenebilir tablo'**
  String get excelReportHint;

  /// No description provided for @share.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// No description provided for @shareHint.
  ///
  /// In tr, this message translates to:
  /// **'Aile bireyleriyle bilgi paylaşın'**
  String get shareHint;

  /// No description provided for @importData.
  ///
  /// In tr, this message translates to:
  /// **'Verileri Yükle'**
  String get importData;

  /// No description provided for @importDataHint.
  ///
  /// In tr, this message translates to:
  /// **'Daha önce dışa aktarılan Excel dosyasını içe aktarın'**
  String get importDataHint;

  /// No description provided for @premiumRequired.
  ///
  /// In tr, this message translates to:
  /// **'Premium gerekli'**
  String get premiumRequired;

  /// No description provided for @plansLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Planlar yüklenemedi. Bağlantını kontrol edip tekrar dene.'**
  String get plansLoadFailed;

  /// No description provided for @purchaseFailed.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma başarısız oldu, tekrar dene.'**
  String get purchaseFailed;

  /// No description provided for @purchaseRestored.
  ///
  /// In tr, this message translates to:
  /// **'Satın alman geri yüklendi.'**
  String get purchaseRestored;

  /// No description provided for @nothingToRestore.
  ///
  /// In tr, this message translates to:
  /// **'Geri yüklenecek aktif bir satın alma bulunamadı.'**
  String get nothingToRestore;

  /// No description provided for @restoreFailed.
  ///
  /// In tr, this message translates to:
  /// **'Geri yükleme başarısız oldu.'**
  String get restoreFailed;

  /// No description provided for @planMonthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get planMonthly;

  /// No description provided for @planThreeMonths.
  ///
  /// In tr, this message translates to:
  /// **'3 Aylık'**
  String get planThreeMonths;

  /// No description provided for @planSixMonths.
  ///
  /// In tr, this message translates to:
  /// **'6 Aylık'**
  String get planSixMonths;

  /// No description provided for @planAnnual.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık'**
  String get planAnnual;

  /// No description provided for @planGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Plan'**
  String get planGeneric;

  /// No description provided for @restore.
  ///
  /// In tr, this message translates to:
  /// **'Geri Yükle'**
  String get restore;

  /// No description provided for @comingSoonTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çok Yakında'**
  String get comingSoonTitle;

  /// No description provided for @premiumComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Premium abonelik yakında burada olacak.'**
  String get premiumComingSoon;

  /// No description provided for @tryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get tryAgain;

  /// No description provided for @premiumHeadlineStart.
  ///
  /// In tr, this message translates to:
  /// **'Tüm özelliklerin'**
  String get premiumHeadlineStart;

  /// No description provided for @premiumHeadlineEnd.
  ///
  /// In tr, this message translates to:
  /// **'keyfini çıkar'**
  String get premiumHeadlineEnd;

  /// No description provided for @featureNoAds.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız deneyim'**
  String get featureNoAds;

  /// No description provided for @featureNoAdsHint.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı hiç reklam görmeden kullan.'**
  String get featureNoAdsHint;

  /// No description provided for @featureMoreScans.
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla tarama hakkı'**
  String get featureMoreScans;

  /// No description provided for @featureMoreScansHint.
  ///
  /// In tr, this message translates to:
  /// **'Günlük fotoğraf tarama limitin artar.'**
  String get featureMoreScansHint;

  /// No description provided for @featureExport.
  ///
  /// In tr, this message translates to:
  /// **'Esnek dışa aktarım'**
  String get featureExport;

  /// No description provided for @featureExportHint.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlarını dilediğin formatta indir.'**
  String get featureExportHint;

  /// No description provided for @noPlansAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Şu anda uygun bir plan bulunamadı.'**
  String get noPlansAvailable;

  /// No description provided for @terms.
  ///
  /// In tr, this message translates to:
  /// **'Koşullar'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik'**
  String get privacy;

  /// No description provided for @bestValueDiscount.
  ///
  /// In tr, this message translates to:
  /// **'En Avantajlı · %{percent} indirim'**
  String bestValueDiscount(int percent);

  /// No description provided for @noCommitment.
  ///
  /// In tr, this message translates to:
  /// **'Taahhütsüz'**
  String get noCommitment;

  /// No description provided for @perMonth.
  ///
  /// In tr, this message translates to:
  /// **'{price}/ay'**
  String perMonth(String price);

  /// No description provided for @welcomePremium.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a Hoş Geldin!'**
  String get welcomePremium;

  /// No description provided for @welcomePremiumHint.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız deneyim, daha fazla tarama hakkı ve esnek dışa aktarım artık senin.'**
  String get welcomePremiumHint;

  /// No description provided for @resetSoon.
  ///
  /// In tr, this message translates to:
  /// **'birazdan'**
  String get resetSoon;

  /// No description provided for @durationMinutes.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dk'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In tr, this message translates to:
  /// **'{hours} sa {minutes} dk'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @textReadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Metin okunamadı: {reason}'**
  String textReadFailed(String reason);

  /// No description provided for @aiRateLimited.
  ///
  /// In tr, this message translates to:
  /// **'Şu an yoğunluktan dolayı AI yanıt veremedi. Birkaç saniye sonra tekrar dene.'**
  String get aiRateLimited;

  /// No description provided for @aiUnexpectedResponse.
  ///
  /// In tr, this message translates to:
  /// **'AI yanıtında beklenen alan bulunamadı.'**
  String get aiUnexpectedResponse;

  /// No description provided for @aiNoUserId.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı kimliği bulunamadı, lütfen tekrar dene.'**
  String get aiNoUserId;

  /// No description provided for @aiAppCheckFailed.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik doğrulaması alınamadı, lütfen tekrar dene.'**
  String get aiAppCheckFailed;

  /// No description provided for @aiRequestFailed.
  ///
  /// In tr, this message translates to:
  /// **'AI değerlendirme isteği başarısız: {detail}'**
  String aiRequestFailed(String detail);

  /// No description provided for @scansRemaining.
  ///
  /// In tr, this message translates to:
  /// **'{remaining}/{limit} tarama hakkın var'**
  String scansRemaining(int remaining, int limit);

  /// No description provided for @scansExhausted.
  ///
  /// In tr, this message translates to:
  /// **'Tarama hakkın bitti · {resetIn} sonra yenilenir'**
  String scansExhausted(String resetIn);

  /// No description provided for @invitationTimeNote.
  ///
  /// In tr, this message translates to:
  /// **'Saat: {time}'**
  String invitationTimeNote(String time);

  /// No description provided for @scanWithCamera.
  ///
  /// In tr, this message translates to:
  /// **'Kamerayla Tara'**
  String get scanWithCamera;

  /// No description provided for @pickFromGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden Seç'**
  String get pickFromGallery;

  /// No description provided for @scanIdleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir takı defteri sayfası ya da davetiye tarat'**
  String get scanIdleTitle;

  /// No description provided for @scanIdleHint.
  ///
  /// In tr, this message translates to:
  /// **'Kamerayla çek ya da galeriden seç, AI otomatik okusun.'**
  String get scanIdleHint;

  /// No description provided for @sourceNotebookShort.
  ///
  /// In tr, this message translates to:
  /// **'Defter'**
  String get sourceNotebookShort;

  /// No description provided for @sourceInvitation.
  ///
  /// In tr, this message translates to:
  /// **'Davetiye'**
  String get sourceInvitation;

  /// No description provided for @invitationReadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Davetiyeden bilgi okunamadı.'**
  String get invitationReadFailed;

  /// No description provided for @itemSaved.
  ///
  /// In tr, this message translates to:
  /// **'{title} kaydedildi.'**
  String itemSaved(String title);

  /// No description provided for @noReadableLines.
  ///
  /// In tr, this message translates to:
  /// **'Görüntüde okunabilir bir satır bulunamadı.'**
  String get noReadableLines;

  /// No description provided for @recordPosition.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt {current} / {total}'**
  String recordPosition(int current, int total);

  /// No description provided for @addedCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} eklendi'**
  String addedCount(int count);

  /// No description provided for @lineAdded.
  ///
  /// In tr, this message translates to:
  /// **'{name} eklendi. Diğer kayıtları görmek için kaydırın.'**
  String lineAdded(String name);

  /// No description provided for @scanSourceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ne taranıyor?'**
  String get scanSourceTitle;

  /// No description provided for @scanSourceHint.
  ///
  /// In tr, this message translates to:
  /// **'Görselin türünü seç, ona göre okuyalım.'**
  String get scanSourceHint;

  /// No description provided for @sourceNotebook.
  ///
  /// In tr, this message translates to:
  /// **'Takı Defteri'**
  String get sourceNotebook;

  /// No description provided for @sourceNotebookHint.
  ///
  /// In tr, this message translates to:
  /// **'Kişi adı, hediye türü ve miktar bilgisi içeren sayfa'**
  String get sourceNotebookHint;

  /// No description provided for @sourceInvitationHint.
  ///
  /// In tr, this message translates to:
  /// **'Çift adı, tarih, saat ve konum bilgisi'**
  String get sourceInvitationHint;

  /// No description provided for @scanLimitTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarama hakkın doldu'**
  String get scanLimitTitle;

  /// No description provided for @scanLimitBody.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz tarama hakkın {resetIn} sonra yenilenecek. Premium ile sınırsız tara.'**
  String scanLimitBody(String resetIn);

  /// No description provided for @cameraNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kamera bulunamadı.'**
  String get cameraNotFound;

  /// No description provided for @cameraOpenFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kamera açılamadı: {error}'**
  String cameraOpenFailed(String error);

  /// No description provided for @photoCaptureFailed.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf çekilemedi: {error}'**
  String photoCaptureFailed(String error);

  /// No description provided for @useThisImage.
  ///
  /// In tr, this message translates to:
  /// **'Bu görseli kullanmak istiyor musun?'**
  String get useThisImage;

  /// No description provided for @use.
  ///
  /// In tr, this message translates to:
  /// **'Kullan'**
  String get use;

  /// No description provided for @personNameEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Kişi adı boş olamaz.'**
  String get personNameEmpty;

  /// No description provided for @scannedText.
  ///
  /// In tr, this message translates to:
  /// **'Taranan: \"{text}\"'**
  String scannedText(String text);

  /// No description provided for @relation.
  ///
  /// In tr, this message translates to:
  /// **'İlişki'**
  String get relation;

  /// No description provided for @fetchingRateShort.
  ///
  /// In tr, this message translates to:
  /// **'Kur alınıyor...'**
  String get fetchingRateShort;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get skip;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @coupleNameEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Çift/kutlanan adı boş olamaz.'**
  String get coupleNameEmpty;

  /// No description provided for @pleasePickDate.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir tarih seçin.'**
  String get pleasePickDate;

  /// No description provided for @invitationReadDetails.
  ///
  /// In tr, this message translates to:
  /// **'Davetiyeden okunan bilgiler'**
  String get invitationReadDetails;

  /// No description provided for @coupleName.
  ///
  /// In tr, this message translates to:
  /// **'Çift / Kutlanan'**
  String get coupleName;

  /// No description provided for @timeOptional.
  ///
  /// In tr, this message translates to:
  /// **'Saat (opsiyonel)'**
  String get timeOptional;

  /// No description provided for @locationOptional.
  ///
  /// In tr, this message translates to:
  /// **'Mekan / Konum (opsiyonel)'**
  String get locationOptional;

  /// No description provided for @addToUpcomingWeddings.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan Düğünlere Ekle'**
  String get addToUpcomingWeddings;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
