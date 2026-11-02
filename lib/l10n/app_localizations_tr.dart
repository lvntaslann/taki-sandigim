// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Takı Sandığım';

  @override
  String get onboardingTagline =>
      'Düğün, nişan ve kına\nhediyelerini kolayca kaydedin';

  @override
  String get onboardingBullet1 =>
      'Kimin ne taktığını, ne verdiğinizi tek bir yerde takip edin';

  @override
  String get onboardingBullet2 =>
      'Takı defterinizi veya davetiyenizi kamera ile tarayarak bilgileri otomatik olarak sisteme aktarın';

  @override
  String get onboardingBullet3 => 'Takılanlar ve verilenler olarak ayırın';

  @override
  String get onboardingStart => 'Haydi Başlayalım';

  @override
  String get continueButton => 'Devam Et';

  @override
  String get skipButton => 'ATLA';

  @override
  String get nameEntryTitle => 'Size Nasıl Hitap Edelim?';

  @override
  String get nameLabel => 'İsim:';

  @override
  String get nameRequiredError => 'Lütfen isminizi giriniz';

  @override
  String get emailEntryTitle => 'Yedekleme için mail adresinizi\ngiriniz...';

  @override
  String get emailLabel => 'Mail:';

  @override
  String get emailRequiredError => 'Lütfen mail adresinizi giriniz';

  @override
  String get emailInvalidError => 'Lütfen geçerli bir mail adresi giriniz';

  @override
  String get giftTypeQuarterGold => 'Çeyrek Altın';

  @override
  String get giftTypeHalfGold => 'Yarım Altın';

  @override
  String get giftTypeFullGold => 'Tam Altın';

  @override
  String get giftTypeGremseGold => 'Gremse Altın';

  @override
  String get giftTypeGramGold => 'Gram Altın';

  @override
  String get giftTypeBracelet => 'Bilezik';

  @override
  String get giftTypeNecklace => 'Kolye';

  @override
  String get giftTypeCash => 'Para';

  @override
  String get giftTypeOther => 'Diğer';

  @override
  String get giftDirectionReceived => 'Bize Takılan';

  @override
  String get giftDirectionGiven => 'Bizim Taktığımız';

  @override
  String get relationFamily => 'Aile';

  @override
  String get relationRelative => 'Akraba';

  @override
  String get relationFriend => 'Arkadaş';

  @override
  String get eventWedding => 'Düğün';

  @override
  String get eventEngagement => 'Nişan';

  @override
  String get eventHenna => 'Kına';

  @override
  String get eventNikah => 'Nikah';

  @override
  String get eventWeddingLocation => 'Düğünde takıldı';

  @override
  String get eventEngagementLocation => 'Nişanda takıldı';

  @override
  String get eventHennaLocation => 'Kınada takıldı';

  @override
  String get eventNikahLocation => 'Nikahta takıldı';

  @override
  String get today => 'Bugün';

  @override
  String get tomorrow => 'Yarın';

  @override
  String daysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String daysLater(int count) {
    return '$count gün sonra';
  }

  @override
  String get upcomingWeddings => 'Yaklaşan Düğünler';

  @override
  String get calendar => 'Takvim';

  @override
  String get greeting => 'Merhaba';

  @override
  String greetingWithName(String name) {
    return 'Merhaba, $name';
  }

  @override
  String get giftDistribution => 'Hediye Dağılımı';

  @override
  String get recordCount => 'Kayıt Sayısı';

  @override
  String recordCountValue(int count) {
    return '$count adet kayıt';
  }

  @override
  String get totalQuantity => 'Toplam Adet';

  @override
  String quantityValue(String amount) {
    return '$amount adet';
  }

  @override
  String get totalGram => 'Toplam Gram';

  @override
  String totalOf(String currency) {
    return 'Toplam $currency';
  }

  @override
  String get totalValue => 'Toplam Değer';

  @override
  String get close => 'Kapat';

  @override
  String get grandTotal => 'Genel Toplam';

  @override
  String get totalGramGold => 'Toplam Gram Altın';

  @override
  String get grandTotalValue => 'Genel Toplam Değer';

  @override
  String get currencyUsd => 'Dolar';

  @override
  String get currencyEur => 'Euro';

  @override
  String get currencyGbp => 'Sterlin';

  @override
  String get receivedGiftsTitle => 'Bize Takılanlar';

  @override
  String get givenGiftsTitle => 'Bizim Taktığımız';

  @override
  String get noReceivedGifts => 'Henüz sana takılan bir şey yok.';

  @override
  String get noGivenGifts => 'Henüz kimseye takı vermedin.';

  @override
  String get addGift => 'Takı Ekle';

  @override
  String get noRecordsFound => 'Kayıt bulunamadı.';

  @override
  String get returnGiven => 'Karşılığı Verildi';

  @override
  String get returnToGive => 'Karşılığı Verilecek';

  @override
  String get returnReceived => 'Karşılığı Alındı';

  @override
  String get returnPending => 'Karşılığı Bekleniyor';

  @override
  String get total => 'Toplam';

  @override
  String percent(int value) {
    return '%$value';
  }

  @override
  String get noUpcomingWeddings => 'Yaklaşan bir düğün yok.';

  @override
  String get scanInvitationHint =>
      'Bir davetiye tarayarak otomatik ekleyebilirsin.';

  @override
  String get scanInvitation => 'Davetiye Tara';

  @override
  String get totalBalance => 'Toplam bakiye';

  @override
  String get noRecordsYet => 'Henüz kayıt yok';

  @override
  String get navHome => 'ana sayfa';

  @override
  String get navAnalytics => 'analiz';

  @override
  String get navProfile => 'profil';

  @override
  String get navSettings => 'ayarlar';

  @override
  String get eventNotSpecified => 'Etkinlik belirtilmemiş';

  @override
  String get allWeddings => 'Tüm Düğünler';

  @override
  String get noWeddingsYet => 'Henüz kayıtlı bir düğün yok.';

  @override
  String get noWeddingOnDate => 'Bu tarihte bir düğün yok.';

  @override
  String get weekdayMon => 'Pt';

  @override
  String get weekdayTue => 'Sa';

  @override
  String get weekdayWed => 'Ça';

  @override
  String get weekdayThu => 'Pe';

  @override
  String get weekdayFri => 'Cu';

  @override
  String get weekdaySat => 'Ct';

  @override
  String get weekdaySun => 'Pz';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get sendFeedback => 'Geri Bildirim Gönder';

  @override
  String get sendFeedbackSubtitle => 'Görüş ve önerilerinizi bizimle paylaşın';

  @override
  String get feedbackHint => 'Görüş ve önerilerinizi yazın...';

  @override
  String get feedbackThanks => 'Geri bildiriminiz için teşekkürler!';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get send => 'Gönder';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get privacyPolicySubtitle =>
      'Verilerinizin nasıl kullanıldığını görüntüleyin';

  @override
  String get privacyPolicyBody =>
      'Takı Sandığım, girdiğiniz isim, mail ve hediye kayıtları gibi verileri yalnızca uygulama içindeki hesaplamalar ve yedekleme amacıyla kullanır. Verileriniz üçüncü taraflarla paylaşılmaz ve cihazınızda güvenli şekilde saklanır. Uygulama ayarlarından dilediğiniz zaman verilerinizi güncelleyebilir veya silebilirsiniz.';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get darkModeSubtitle => 'Uygulama genelinde koyu temayı etkinleştirir';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get notificationsSubtitle => 'Yaklaşan düğün hatırlatmaları';

  @override
  String get goldRate => 'Altın Kuru';

  @override
  String get goldRateSubtitle => 'Güncel gram altın kuruna göre hesaplanır';

  @override
  String get help => 'Yardım';

  @override
  String get appVersion => 'Uygulama Versiyonu';

  @override
  String versionValue(String version) {
    return 'Sürüm $version';
  }

  @override
  String get developers => 'Geliştiriciler';

  @override
  String get developer => 'Geliştirici';

  @override
  String get addRecordTitle => 'Yeni Kayıt Ekle';

  @override
  String get addManuallyTab => 'Yeni Ekle';

  @override
  String get scanTab => 'Defter/Davetiye Tara';

  @override
  String get personName => 'Kişi Adı';

  @override
  String get personNameRequired => 'Kişi adı gerekli';

  @override
  String get whereGiven => 'Nerede Takıldı';

  @override
  String get giftTypeLabel => 'Takı Türü';

  @override
  String get amountPiecesOrGrams => 'Miktar (adet/gram)';

  @override
  String get enterValidAmount => 'Geçerli bir miktar girin';

  @override
  String get enterValidSum => 'Geçerli bir tutar girin';

  @override
  String get fetchingRate => 'Güncel kur alınıyor...';

  @override
  String todayGramGoldRate(String rate) {
    return 'Bugünkü gram altın kuru: $rate';
  }

  @override
  String calculatedValue(String value) {
    return 'Hesaplanan değer: $value';
  }

  @override
  String get foreignCurrency => 'Döviz';

  @override
  String amountInCurrency(String currency) {
    return 'Tutar ($currency)';
  }

  @override
  String get currency => 'Para Birimi';

  @override
  String currentRate(String code, String rate) {
    return 'Güncel kur: 1 $code = $rate';
  }

  @override
  String tlEquivalent(String value) {
    return 'TL karşılığı: $value';
  }

  @override
  String get date => 'Tarih';

  @override
  String get noteOptional => 'Not (opsiyonel)';

  @override
  String get save => 'Kaydet';

  @override
  String get ledgerTitle => 'Defterim';

  @override
  String get ledgerSearchHint => 'Defterim içinde ara...';

  @override
  String get noRecordsYetDot => 'Henüz bir kayıt yok.';

  @override
  String get noResults => 'Sonuç bulunamadı.';

  @override
  String get youGave => 'SENİN TAKTIĞIN';

  @override
  String get youReceived => 'SANA TAKILAN';

  @override
  String get totalBalanceTitle => 'Toplam Bakiye';

  @override
  String allRecordsCount(int count) {
    return 'Tüm Kayıtlar ($count)';
  }

  @override
  String get deleteRecordTitle => 'Kaydı sil';

  @override
  String deleteRecordConfirm(String name, String giftType) {
    return '$name - $giftType kaydını silmek istediğine emin misin?';
  }

  @override
  String get delete => 'Sil';

  @override
  String get categoryCurrency => 'Döviz';

  @override
  String get rangeDay => 'Gün';

  @override
  String get rangeWeek => 'Hafta';

  @override
  String get rangeMonth => 'Ay';

  @override
  String get rangeYear => 'Yıl';

  @override
  String get rangeAll => 'Tümü';

  @override
  String get analyticsTitle => 'Analiz';

  @override
  String get notEnoughDataForAnalytics =>
      'Analiz için henüz yeterli kayıt yok.';

  @override
  String get totalRecords => 'Toplam Kayıt';

  @override
  String get personCount => 'Kişi Sayısı';

  @override
  String get netBalanceByPerson => 'Kişi Bazında Net Bakiye';

  @override
  String get weOwe => 'Biz borçluyuz';

  @override
  String get theyOwe => 'Bize borçlu';

  @override
  String get allBalanced => 'Herkesle hesap dengede.';

  @override
  String get valueAnalysis => 'Değer Analizi';

  @override
  String get valueAnalysisHint =>
      'Bir kategoriye dokun, içindeki kişileri ve değer değişimlerini incele.';

  @override
  String get currentGramGoldRate => 'Güncel Gram Altın Kuru';

  @override
  String get updating => 'Güncelleniyor...';

  @override
  String recordCountShort(int count) {
    return '$count kayıt';
  }

  @override
  String get noData => 'Veri yok';

  @override
  String get receivedUpper => 'BİZE GELEN';

  @override
  String get givenUpper => 'BİZİM VERDİĞİMİZ';

  @override
  String get balanced => 'Hesap dengede';

  @override
  String personGave(String name) {
    return '$name taktı';
  }

  @override
  String get weGave => 'Biz taktık';

  @override
  String valueInfoCurrencyBasis(String code) {
    return 'O günkü değer, kaydı eklediğin andaki $code kuruna göredir. Bugünkü değer ise güncel döviz kuruyla yeniden hesaplanır.';
  }

  @override
  String get valueInfoGoldBasis =>
      'O günkü değer, kaydı eklediğin andaki altın kuruna göredir. Bugünkü değer ise güncel gram altın kuruyla yeniden hesaplanır.';

  @override
  String get valueInfoNoBasis =>
      'Bu kayıt bir kur bilgisiyle eklenmediği için değeri zamanla değişmez; o günkü ve bugünkü değer aynıdır.';

  @override
  String get valueInfoTitle => 'Bu grafik nasıl hesaplanıyor?';

  @override
  String valueInfoBody(String basis) {
    return '$basis Aradaki noktalar gerçek piyasa verisi değildir; sadece iki değer arasındaki değişimi görselleştirmek için doğrusal olarak tahmin edilmiştir. Üstteki dönem seçici sadece aynı doğrunun hangi zaman penceresini gösterdiğini değiştirir.';
  }

  @override
  String get gotIt => 'Anladım';

  @override
  String dateGiven(String date) {
    return 'Takıldığı Tarih: $date';
  }

  @override
  String currentGramGoldRateValue(String rate) {
    return 'Güncel gram altın kuru: $rate';
  }

  @override
  String get basisGold => 'Altın';

  @override
  String get basisFixed => 'Sabit';

  @override
  String get valueThen => 'O günkü değeri';

  @override
  String get valueNow => 'Bugünkü değeri';

  @override
  String get valueIncrease => 'Değer Artışı';

  @override
  String get valueChangeChart => 'Değer Değişimi Grafiği';

  @override
  String get valueChartHint => 'Uç noktalar gerçek, aradaki çizgi tahminidir.';

  @override
  String get lowest => 'En Düşük';

  @override
  String get highest => 'En Yüksek';

  @override
  String get average => 'Ortalama';

  @override
  String get searchByName => 'Kişi adına göre ara...';

  @override
  String get noRecordsInCategory => 'Bu kategoride bir kayıt yok.';

  @override
  String get nameSaved => 'İsim kaydedildi.';

  @override
  String get emailSaved => 'Mail adresi kaydedildi.';

  @override
  String get logOut => 'Çıkış Yap';

  @override
  String get logOutShort => 'Çıkış';

  @override
  String get logOutConfirm =>
      'Hesabınızdan çıkış yapmak istediğinize emin misiniz?';

  @override
  String get logOutHint => 'Hesabınızdan çıkış yapın.';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountConfirm =>
      'Hesabınızı silmek, profil bilgilerinizi ve tüm takı kayıtlarınızı kalıcı olarak silecektir. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?';

  @override
  String get deleteAccountHint => 'Tüm verileriniz kalıcı olarak silinir.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get yourName => 'Adınız';

  @override
  String get yourNameHint => 'Ana Sayfa\'daki selamlamada kullanılır.';

  @override
  String get nameField => 'İsim';

  @override
  String get emailAddress => 'Mail Adresi';

  @override
  String get emailAddressHint => 'Yedekleme ve bildirimler için kullanılır.';

  @override
  String get emailField => 'Mail';

  @override
  String get specialDates => 'Özel Günlerinizin Tarihi';

  @override
  String eventDate(String event) {
    return '$event Tarihi';
  }

  @override
  String get pickDate => 'Tarih seçin';

  @override
  String get giftListReports => 'Takı Listesi Raporları';

  @override
  String get giftListReportsHint => 'PDF, Excel olarak indir veya paylaş.';

  @override
  String get goPremium => 'Premium\'a Geç';

  @override
  String get goPremiumHint =>
      'Reklamsız deneyim, daha fazla tarama hakkı ve esnek dışa aktarım';

  @override
  String get premiumActive => 'Premium Aktif';

  @override
  String get premiumActiveHint =>
      'Reklamsız ve sınırsız kullanım keyfini çıkarıyorsun.';

  @override
  String get exportDocumentTitle => 'Takı Sandığım - Takı Listem';

  @override
  String get exportSheetGifts => 'Takı Listem';

  @override
  String get exportSheetWeddings => 'Davetiye Bilgileri';

  @override
  String get exportColDate => 'Tarih';

  @override
  String get exportColPerson => 'Kişi';

  @override
  String get exportColGift => 'Hediye';

  @override
  String get exportColAmount => 'Miktar';

  @override
  String get exportColUnit => 'Birim';

  @override
  String get exportColValueTl => 'Değer (TL)';

  @override
  String get exportColDirection => 'Yön';

  @override
  String get exportColTitle => 'Başlık';

  @override
  String get exportColLocation => 'Konum';

  @override
  String get exportColNote => 'Not';

  @override
  String get importNoSheet => 'Dosyada okunabilir bir sayfa bulunamadı.';

  @override
  String get importEmptyFile => 'Dosya boş.';

  @override
  String get importWrongFormat =>
      'Bu dosya Takı Sandığım formatında değil. Lütfen uygulamadan dışa aktarılmış bir Excel dosyası seçin.';

  @override
  String get importSourceExcel => 'Excel Dosyası';

  @override
  String get importSourcePdf => 'PDF Dosyası';

  @override
  String get importSourceTitle => 'Hangi dosyadan yükleyelim?';

  @override
  String get importSourceHint => 'Daha önce dışa aktardığın dosyayı seç.';

  @override
  String get importSourceExcelHint =>
      'Uygulamadan dışa aktarılmış .xlsx dosyası';

  @override
  String get comingSoon => 'Yakında eklenecek';

  @override
  String get noGiftRecordsYet => 'Henüz bir takı kaydı yok.';

  @override
  String reportFailed(String error) {
    return 'Rapor oluşturulamadı: $error';
  }

  @override
  String get pdfImportComingSoon => 'PDF\'den içe aktarma yakında eklenecek.';

  @override
  String importResult(int gifts, int weddings) {
    return '$gifts kayıt, $weddings davetiye eklendi.';
  }

  @override
  String importFailed(String error) {
    return 'Veriler içe aktarılamadı: $error';
  }

  @override
  String shareFailed(String error) {
    return 'Paylaşılamadı: $error';
  }

  @override
  String get reportsTitle => 'Raporlar';

  @override
  String get giftListReport => 'Takı Listesi Raporu';

  @override
  String get giftListReportHint =>
      'Verilerinizi PDF veya Excel formatında dışa aktarın.';

  @override
  String get pdfReport => 'PDF Raporu (A4)';

  @override
  String get pdfReportHint => 'Detaylı takı listesi';

  @override
  String get excelReportHint => 'Düzenlenebilir tablo';

  @override
  String get share => 'Paylaş';

  @override
  String get shareHint => 'Aile bireyleriyle bilgi paylaşın';

  @override
  String get importData => 'Verileri Yükle';

  @override
  String get importDataHint =>
      'Daha önce dışa aktarılan Excel dosyasını içe aktarın';

  @override
  String get premiumRequired => 'Premium gerekli';

  @override
  String get plansLoadFailed =>
      'Planlar yüklenemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get purchaseFailed => 'Satın alma başarısız oldu, tekrar dene.';

  @override
  String get purchaseRestored => 'Satın alman geri yüklendi.';

  @override
  String get nothingToRestore =>
      'Geri yüklenecek aktif bir satın alma bulunamadı.';

  @override
  String get restoreFailed => 'Geri yükleme başarısız oldu.';

  @override
  String get planMonthly => 'Aylık';

  @override
  String get planThreeMonths => '3 Aylık';

  @override
  String get planSixMonths => '6 Aylık';

  @override
  String get planAnnual => 'Yıllık';

  @override
  String get planGeneric => 'Plan';

  @override
  String get restore => 'Geri Yükle';

  @override
  String get comingSoonTitle => 'Çok Yakında';

  @override
  String get premiumComingSoon => 'Premium abonelik yakında burada olacak.';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get premiumHeadlineStart => 'Tüm özelliklerin';

  @override
  String get premiumHeadlineEnd => 'keyfini çıkar';

  @override
  String get featureNoAds => 'Reklamsız deneyim';

  @override
  String get featureNoAdsHint => 'Uygulamayı hiç reklam görmeden kullan.';

  @override
  String get featureMoreScans => 'Daha fazla tarama hakkı';

  @override
  String get featureMoreScansHint => 'Günlük fotoğraf tarama limitin artar.';

  @override
  String get featureExport => 'Esnek dışa aktarım';

  @override
  String get featureExportHint => 'Kayıtlarını dilediğin formatta indir.';

  @override
  String get noPlansAvailable => 'Şu anda uygun bir plan bulunamadı.';

  @override
  String get terms => 'Koşullar';

  @override
  String get privacy => 'Gizlilik';

  @override
  String bestValueDiscount(int percent) {
    return 'En Avantajlı · %$percent indirim';
  }

  @override
  String get noCommitment => 'Taahhütsüz';

  @override
  String perMonth(String price) {
    return '$price/ay';
  }

  @override
  String get welcomePremium => 'Premium\'a Hoş Geldin!';

  @override
  String get welcomePremiumHint =>
      'Reklamsız deneyim, daha fazla tarama hakkı ve esnek dışa aktarım artık senin.';

  @override
  String get resetSoon => 'birazdan';

  @override
  String durationMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours sa $minutes dk';
  }

  @override
  String textReadFailed(String reason) {
    return 'Metin okunamadı: $reason';
  }

  @override
  String get aiRateLimited =>
      'Şu an yoğunluktan dolayı AI yanıt veremedi. Birkaç saniye sonra tekrar dene.';

  @override
  String get aiUnexpectedResponse => 'AI yanıtında beklenen alan bulunamadı.';

  @override
  String get aiNoUserId => 'Kullanıcı kimliği bulunamadı, lütfen tekrar dene.';

  @override
  String get aiAppCheckFailed =>
      'Güvenlik doğrulaması alınamadı, lütfen tekrar dene.';

  @override
  String aiRequestFailed(String detail) {
    return 'AI değerlendirme isteği başarısız: $detail';
  }

  @override
  String scansRemaining(int remaining, int limit) {
    return '$remaining/$limit tarama hakkın var';
  }

  @override
  String scansExhausted(String resetIn) {
    return 'Tarama hakkın bitti · $resetIn sonra yenilenir';
  }

  @override
  String invitationTimeNote(String time) {
    return 'Saat: $time';
  }

  @override
  String get scanWithCamera => 'Kamerayla Tara';

  @override
  String get pickFromGallery => 'Galeriden Seç';

  @override
  String get scanIdleTitle => 'Bir takı defteri sayfası ya da davetiye tarat';

  @override
  String get scanIdleHint =>
      'Kamerayla çek ya da galeriden seç, AI otomatik okusun.';

  @override
  String get sourceNotebookShort => 'Defter';

  @override
  String get sourceInvitation => 'Davetiye';

  @override
  String get invitationReadFailed => 'Davetiyeden bilgi okunamadı.';

  @override
  String itemSaved(String title) {
    return '$title kaydedildi.';
  }

  @override
  String get noReadableLines => 'Görüntüde okunabilir bir satır bulunamadı.';

  @override
  String recordPosition(int current, int total) {
    return 'Kayıt $current / $total';
  }

  @override
  String addedCount(int count) {
    return '$count eklendi';
  }

  @override
  String lineAdded(String name) {
    return '$name eklendi. Diğer kayıtları görmek için kaydırın.';
  }

  @override
  String get scanSourceTitle => 'Ne taranıyor?';

  @override
  String get scanSourceHint => 'Görselin türünü seç, ona göre okuyalım.';

  @override
  String get sourceNotebook => 'Takı Defteri';

  @override
  String get sourceNotebookHint =>
      'Kişi adı, hediye türü ve miktar bilgisi içeren sayfa';

  @override
  String get sourceInvitationHint => 'Çift adı, tarih, saat ve konum bilgisi';

  @override
  String get scanLimitTitle => 'Tarama hakkın doldu';

  @override
  String scanLimitBody(String resetIn) {
    return 'Ücretsiz tarama hakkın $resetIn sonra yenilenecek. Premium ile sınırsız tara.';
  }

  @override
  String get cameraNotFound => 'Kamera bulunamadı.';

  @override
  String cameraOpenFailed(String error) {
    return 'Kamera açılamadı: $error';
  }

  @override
  String photoCaptureFailed(String error) {
    return 'Fotoğraf çekilemedi: $error';
  }

  @override
  String get useThisImage => 'Bu görseli kullanmak istiyor musun?';

  @override
  String get use => 'Kullan';

  @override
  String get personNameEmpty => 'Kişi adı boş olamaz.';

  @override
  String scannedText(String text) {
    return 'Taranan: \"$text\"';
  }

  @override
  String get relation => 'İlişki';

  @override
  String get fetchingRateShort => 'Kur alınıyor...';

  @override
  String get skip => 'Atla';

  @override
  String get add => 'Ekle';

  @override
  String get coupleNameEmpty => 'Çift/kutlanan adı boş olamaz.';

  @override
  String get pleasePickDate => 'Lütfen bir tarih seçin.';

  @override
  String get invitationReadDetails => 'Davetiyeden okunan bilgiler';

  @override
  String get coupleName => 'Çift / Kutlanan';

  @override
  String get timeOptional => 'Saat (opsiyonel)';

  @override
  String get locationOptional => 'Mekan / Konum (opsiyonel)';

  @override
  String get addToUpcomingWeddings => 'Yaklaşan Düğünlere Ekle';
}
