# SERLyric

SERLyric, iOS için SwiftUI tabanlı bir uygulamadır. Cihazda çalan şarkıyı algılar, LRCLib üzerinden senkron şarkı sözlerini çeker ve sözleri oynatma zamanına göre vurgular.

## Özellikler

- `MediaPlayer` ile Now Playing bilgisini okur
- LRCLib API ile şarkı sözü arar ve getirir
- LRC formatını ayrıştırır
- Aktif satırı oynatma zamanına göre otomatik kaydırır
- SwiftUI arayüzü ile canlı söz deneyimi sunar

## Proje Yapısı

- `SERLyricApp.swift`: Uygulama giriş noktası
- `LyricsView.swift`: Ana ekran ve söz arayüzü
- `LyricsViewModel.swift`: İş mantığı, polling ve senkronizasyon
- `NowPlayingService.swift`: Cihazdaki çalan parçayı alma
- `LRCLibService.swift`: LRCLib API istemcisi
- `LRCParser.swift`: LRC ayrıştırma işlemleri
- `Models.swift`: Model ve hata tipleri
- `AppConfig/Info.plist`: Uygulama yapılandırması

## Gereksinimler

- Xcode 16+
- iOS Deployment Target: 16.0+
- Apple Music/Now Playing verisine erişim izni

## CI/CD

GitHub Actions workflow dosyası: `.github/workflows/build.yml`

Bu workflow:

1. Projeyi (`.xcodeproj` veya `.xcworkspace`) ve scheme'i otomatik çözer.
2. `Release` modunda unsigned iOS archive oluşturur.
3. Archive içinden `.ipa` paketler (`SERLyric-unsigned.ipa`).
4. IPA'yı hem artifact olarak hem de GitHub Releases bölümüne otomatik yükler.

Not: Üretilen IPA unsigned olduğu için doğrudan cihazlara dağıtım için imzalama/provisioning gerekir.
