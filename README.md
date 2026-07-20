# Taki Sandığım

Düğün, nişan ve kına takı/hediyelerini takip etmeye yarayan bir Flutter uygulaması.

## Özellikler

- **Onboarding** — uygulamayı tanıtan giriş ekranı ("Haydi Başlayalım" butonu).
- **İsim alma ekranı** — onboarding sonrası kullanıcıdan ismini alan, `Size Nasıl Hitap Edelim?` başlıklı ekran. Onboarding ile aynı 1080x1920 sabit tuval üzerinde `FittedBox` ile ölçekleniyor, böylece iki ekran her cihazda aynı oranda görüntüleniyor.
- **Dashboard** — düğün bütçesi özeti, altın kuru, hediye dağılım grafiği.
- **Ledger / Analytics / Profile** — takı defteri, analiz ve profil ekranları.

## Rotalar

| Route | Ekran |
|---|---|
| `/onboarding` | OnboardingScreen |
| `/onboarding/name` | NameEntryScreen |
| `/` | DashboardScreen |
| `/ledger` | LedgerScreen |
| `/analytics` | AnalyticsScreen |
| `/profile` | ProfileScreen |
| `/add-gift` | AddGiftScreen |

## Geliştirme

```bash
flutter pub get
flutter run
```
