# Taki Sandığım

Düğün, nişan ve kına takı/hediyelerini takip etmeye yarayan bir Flutter uygulaması.

## Özellikler

- **Onboarding** — uygulamayı tanıtan giriş ekranı ("Haydi Başlayalım" butonu).
- **İsim alma ekranı** — onboarding sonrası kullanıcıdan ismini alan, `Size Nasıl Hitap Edelim?` başlıklı ekran. Onboarding ile aynı 1080x1920 sabit tuval üzerinde `FittedBox` ile ölçekleniyor, böylece iki ekran her cihazda aynı oranda görüntüleniyor.
- **Mail alma ekranı** — isim ekranından sonra yedekleme için mail adresi isteyen, atlanabilir bir ekran.
- **Dashboard** — düğün bütçesi özeti, altın kuru, hediye dağılım grafiği.
- **Ledger / Analytics / Profile / Ayarlar** — takı defteri, analiz, profil ve ayarlar ekranları. Alt navigasyon çubuğu (ana sayfa, analiz, profil, ayarlar) tüm sekmelerde sabit kalır.
- **Karanlık Mod** — Ayarlar ekranındaki anahtar ile açılıp kapatılır, tercih Hive'da saklanır ve tüm uygulama kabuğunu (AppBar, arka plan, kartlar, alt navigasyon) etkiler. Varsayılan olarak kapalıdır.
- **Bildirimler** — Ayarlar ekranında açma/kapama anahtarı; tercih kalıcı olarak saklanır. Varsayılan olarak kapalıdır.
- **Yardım bölümü (Ayarlar)** — Geri Bildirim Gönder, Uygulama Versiyonu ve Gizlilik Politikası bilgileri.
- **Geliştiriciler bölümü (Ayarlar)** — Levent ASLAN ve Halime ÖZOYMAK bilgileri, sayfanın en altında.
- **Profil** — profil fotoğrafı ekleme (galeriden seçim), isim/mail güncelleme, düğün/nişan/nikah/kına seçimiyle "Özel Günlerinizin Tarihi" belirleme.
- **Takı listesini paylaşma ve indirme** — Profil ekranından takı listesi metin özeti olarak paylaşılabilir; PDF veya düzenlenebilir Excel (xlsx) formatında dışa aktarılıp paylaşım/indirme menüsünden kaydedilebilir.
- **Çıkış Yap ve Hesabı Sil (Profil)** — Profil ekranının altına eklenen iki kart:
  - *Çıkış Yap*: onay dialogu sonrası kullanıcıyı onboarding akışına geri döndürür.
  - *Hesabı Sil*: onay dialogu sonrası profil ayarlarını, takı kayıtlarını ve düğün kayıtlarını (Hive kutuları) kalıcı olarak siler, ardından onboarding akışına döner. Uygulamada sunucu tabanlı bir hesap/oturum sistemi olmadığından bu işlemler tamamen cihaz üzerindeki yerel veriyi hedefler.

## Rotalar

| Route | Ekran |
|---|---|
| `/onboarding` | OnboardingScreen |
| `/onboarding/name` | NameEntryScreen |
| `/onboarding/email` | EmailEntryScreen |
| `/` | DashboardScreen |
| `/ledger` | LedgerScreen |
| `/analytics` | AnalyticsScreen |
| `/profile` | ProfileScreen |
| `/settings` | SettingsScreen |
| `/add-gift` | AddGiftScreen |

## Geliştirme

```bash
flutter pub get
flutter run
```
