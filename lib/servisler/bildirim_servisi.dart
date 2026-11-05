import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'sesli_asistan_servisi.dart';

/// Sistem düzeyinde Android bildirimlerini (Bütçe eşiği, aşımı, dönem hatırlatıcısı) yöneten servis sınıfı (Singleton)
class BildirimServisi {
  static final BildirimServisi _ornek = BildirimServisi._dahili();
  factory BildirimServisi() => _ornek;
  BildirimServisi._dahili();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _baslatildi = false;

  static const String _kanalId = 'sepetgoz_alerts';
  static const String _kanalAdi = 'Bütçe ve Alışveriş Bildirimleri';
  static const String _kanalAciklama =
      'Bütçe limitleri, tasarruf özetleri ve dönem sonu hatırlatıcıları.';

  /// Bildirim servisini ve Android bildirim kanalını başlatır
  Future<void> baslat() async {
    if (_baslatildi) return;

    try {
      const androidAyarlari = AndroidInitializationSettings('@mipmap/ic_launcher');
      const baslatmaAyarlari = InitializationSettings(android: androidAyarlari);

      await _notificationsPlugin.initialize(
        settings: baslatmaAyarlari,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Bildirime tıklandı: ${details.payload}');
        },
      );

      // Android 13+ (API 33+) bildirim izni talep et
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.requestNotificationsPermission();
      }

      _baslatildi = true;
    } catch (e) {
      debugPrint('Bildirim servisi başlatma hatası: $e');
    }
  }

  NotificationDetails _bildirimDetaylari({bool kritik = false, bool titresim = true}) {
    final androidDetails = AndroidNotificationDetails(
      _kanalId,
      _kanalAdi,
      channelDescription: _kanalAciklama,
      importance: kritik ? Importance.max : Importance.high,
      priority: kritik ? Priority.max : Priority.high,
      showWhen: true,
      enableVibration: titresim,
      styleInformation: const BigTextStyleInformation(''),
    );
    return NotificationDetails(android: androidDetails);
  }

  /// Bütçenin %80 ve üzeri kritik eşiğine ulaşıldığında gönderilen uyarı
  Future<void> butceEsikUyarisi({
    required double harcanan,
    required double butce,
    required double kalan,
    required int yuzde,
    bool titresim = true,
  }) async {
    await baslat();
    try {
      await _notificationsPlugin.show(
        id: 101,
        title: '⚠️ Bütçe Uyarısı (%$yuzde)',
        body: 'Dönem bütçenizin %$yuzde kadarı harcandı (${harcanan.toStringAsFixed(0)} ₺). Kalan bütçeniz: ${kalan.toStringAsFixed(0)} ₺.',
        notificationDetails: _bildirimDetaylari(kritik: false, titresim: titresim),
      );
      if (titresim) SesliAsistanServisi.fizikselTitret(sureMs: 250);
    } catch (e) {
      debugPrint('Bütçe eşik bildirimi hatası: $e');
    }
  }

  /// Bütçe %100 aşıldığında gönderilen acil uyarı
  Future<void> butceAsimUyarisi({
    required double harcanan,
    required double butce,
    required double asim,
    bool titresim = true,
  }) async {
    await baslat();
    try {
      await _notificationsPlugin.show(
        id: 102,
        title: '🚨 Bütçe Limiti Aşıldı!',
        body: 'Belirlediğiniz ${butce.toStringAsFixed(0)} ₺ bütçe limitini ${asim.toStringAsFixed(0)} ₺ aştınız! Toplam harcama: ${harcanan.toStringAsFixed(0)} ₺.',
        notificationDetails: _bildirimDetaylari(kritik: true, titresim: titresim),
      );
      if (titresim) SesliAsistanServisi.fizikselTitret(sureMs: 400);
    } catch (e) {
      debugPrint('Bütçe aşım bildirimi hatası: $e');
    }
  }

  /// Bütçe döneminin bitmesine 3 gün veya daha az kaldığında gönderilen hatırlatıcı
  Future<void> donemSonuHatirlatici({
    required int kalanGun,
    required double kalanButce,
    bool titresim = true,
  }) async {
    await baslat();
    try {
      await _notificationsPlugin.show(
        id: 103,
        title: '📅 Bütçe Dönem Sonu Yaklaşıyor',
        body: 'Bütçe döneminizin bitmesine $kalanGun gün kaldı. Kalan bütçeniz: ${kalanButce.toStringAsFixed(0)} ₺.',
        notificationDetails: _bildirimDetaylari(kritik: false, titresim: titresim),
      );
    } catch (e) {
      debugPrint('Dönem sonu bildirimi hatası: $e');
    }
  }

  /// Haftalık tasarruf ve indirim özeti bildirimi
  Future<void> haftalikTasarrufOzeti({required double tasarruf, bool titresim = true}) async {
    if (tasarruf <= 0) return;
    await baslat();
    try {
      await _notificationsPlugin.show(
        id: 104,
        title: '🎉 Haftalık İndirim Kazancınız',
        body: 'Tebrikler! SepetGöz ile bu hafta toplam ${tasarruf.toStringAsFixed(2)} ₺ tasarruf elde ettiniz.',
        notificationDetails: _bildirimDetaylari(kritik: false, titresim: titresim),
      );
    } catch (e) {
      debugPrint('Haftalık tasarruf bildirimi hatası: $e');
    }
  }
}
