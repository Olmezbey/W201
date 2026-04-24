# E190 Smart — APK Kurulum Rehberi
## 34 AU 966 · Mercedes W201 · 1992

---

## ADIM 1 — GitHub Hesabı Aç
1. **github.com** adresine git
2. Sağ üstten **Sign up** tıkla
3. Hesap oluştur (ücretsiz)

---

## ADIM 2 — Yeni Repo Oluştur
1. Giriş yaptıktan sonra **+** → **New repository** tıkla
2. Repository name: `e190-smart`
3. **Private** seç (sadece sen göreceksin)
4. **Create repository** tıkla

---

## ADIM 3 — Dosyaları Yükle
1. Repo sayfasında **uploading an existing file** linkine tıkla
2. Bu ZIP dosyasının içindeki **TÜM dosyaları** sürükle-bırak
3. Klasör yapısını koru (lib/, android/, .github/ vb.)
4. En altta **Commit changes** yaz ve tıkla

---

## ADIM 4 — APK Otomatik Build Olur
1. **Actions** sekmesine tıkla
2. Soldaki listede **E190 Smart APK Build** görürsün
3. Sarı daire = build devam ediyor (~5-8 dakika)
4. Yeşil tik = APK hazır ✅
5. Build'e tıkla → **Artifacts** bölümünden **E190-Smart-APK** indir

---

## ADIM 5 — Telefona Yükle
1. İndirilen ZIP içinden `.apk` dosyasını çıkar
2. Dosyayı telefona gönder (WhatsApp, mail, USB)
3. Telefonda **Ayarlar → Güvenlik → Bilinmeyen kaynaklar** → Aç
4. APK dosyasına tıkla → Yükle
5. Uygulama açılır, **PIN: 1992** (değiştirmek için `constants.dart` dosyasında `kPinCode`)

---

## PIN KODUNU DEĞİŞTİRMEK
`lib/utils/constants.dart` dosyasını aç:
```
const kPinCode = '1992';   // bunu istediğin 4 hane ile değiştir
```
Kaydet ve tekrar commit et → yeni APK otomatik gelir.

---

## ESP32 IP ADRES AYARI
Eğer ESP32'nin IP adresi farklıysa `constants.dart`:
```
const kEspIp    = '192.168.4.1';   // ESP32 AP IP
const kCamFront = 'http://192.168.4.2/stream';
const kCamRear  = 'http://192.168.4.3/stream';
```

---

## SORUN GİDERME
- **Build kırmızı**: Actions sekmesinde hataya tıkla, log'u gör
- **APK kurulmuyor**: Bilinmeyen kaynakları açmayı unutma
- **MQTT bağlanamıyor**: Telefonun ESP32'nin WiFi'sine bağlı olduğunu kontrol et
- **Kamera görünmüyor**: ESP32-CAM IP adresini kontrol et

---

*Proje tamamen senindir. Kimseyle paylaşılmaz, Play Store'a çıkmaz.*
