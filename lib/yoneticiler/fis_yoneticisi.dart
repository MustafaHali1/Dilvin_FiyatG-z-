import 'package:flutter/material.dart';
import '../modeller/fis_modeli.dart';
import '../modeller/urun_modeli.dart';
import '../modeller/profil_modeli.dart';
import '../servisler/veritabani_servisi.dart';
import '../servisler/bildirim_servisi.dart';

/// Alışveriş fişlerini ve bütçe/tasarruf istatistiklerini SQLite üzerinden yöneten ViewModel
class FisYoneticisi extends ChangeNotifier {
  final VeritabaniServisi _db = VeritabaniServisi();

  List<FisModeli> _fisler = [];
  bool _yukleniyor = true;
  double _buAyHarcama = 0.0;
  double _toplamTasarruf = 0.0;

  FisYoneticisi() {
    verileriYukle();
  }

  List<FisModeli> get fisler => List.unmodifiable(_fisler);
  bool get yukleniyor => _yukleniyor;
  double get buAyHarcama => _buAyHarcama;
  double get toplamTasarruf => _toplamTasarruf;
  int get fisSayisi => _fisler.length;

  /// Son 7 günde yapılan toplam harcama tutarı
  double get buHaftaHarcama {
    final yediGunOnce = DateTime.now().subtract(const Duration(days: 7));
    return _fisler
        .where((f) => f.tarih.isAfter(yediGunOnce))
        .fold(0.0, (toplam, f) => toplam + f.toplamTutar);
  }

  /// Son 7 günün fişleri
  List<FisModeli> get buHaftaninFisleri {
    final yediGunOnce = DateTime.now().subtract(const Duration(days: 7));
    return _fisler.where((f) => f.tarih.isAfter(yediGunOnce)).toList();
  }

  /// Veritabanındaki tüm fişleri ve aylık/tasarruf istatistiklerini yükler
  Future<void> verileriYukle() async {
    _yukleniyor = true;
    notifyListeners();

    try {
      final fisler = await _db.tumFisleriGetir();

      // Eski sahte başlangıç verilerini temizliyoruz
      final sahteVarMi = fisler.any(
        (f) => f.id == 'FG-84920' || f.id == 'FG-84110' || f.id == 'FG-83540',
      );
      if (sahteVarMi) {
        await _db.sahteVerileriTemizle();
        final temizFisler = await _db.tumFisleriGetir();
        _fisler = temizFisler;
        _buAyHarcama = 0.0;
        _toplamTasarruf = 0.0;
        _yukleniyor = false;
        notifyListeners();
        return;
      }

      final buAy = await _db.buAykiToplamHarcama();
      final tasarruf = await _db.toplamTasarruf();

      _fisler = fisler;
      _buAyHarcama = buAy;
      _toplamTasarruf = tasarruf;
      _yukleniyor = false;
      notifyListeners();
    } catch (_) {
      _yukleniyor = false;
      notifyListeners();
    }
  }

  /// Belirli bir tarih aralığındaki toplam harcamayı hesaplar
  double donemHarcamasiGetir({required DateTime baslangic, required DateTime bitis}) {
    return _fisler
        .where((f) => !f.tarih.isBefore(baslangic) && !f.tarih.isAfter(bitis))
        .fold(0.0, (toplam, f) => toplam + f.toplamTutar);
  }

  /// Belirli bir tarih aralığındaki fişleri filtreler
  List<FisModeli> donemFisleriGetir({required DateTime baslangic, required DateTime bitis}) {
    return _fisler
        .where((f) => !f.tarih.isBefore(baslangic) && !f.tarih.isAfter(bitis))
        .toList();
  }

  /// Aktif profilin bütçe dönemine göre harcama tutarı
  double donemHarcamasi(ProfilModeli profil) {
    return donemHarcamasiGetir(
      baslangic: profil.etkinButceBaslangic,
      bitis: profil.etkinButceBitis,
    );
  }

  /// Aktif profilin bütçe dönemine göre kalan bütçesi
  double kalanButce(ProfilModeli profil) {
    return profil.aylikButce - donemHarcamasi(profil);
  }

  /// Aktif profilin bütçe kullanım oranı (0.0 - 1.0)
  double butceIlerleme(ProfilModeli profil) {
    if (profil.aylikButce <= 0) return 0.0;
    return (donemHarcamasi(profil) / profil.aylikButce).clamp(0.0, 1.0);
  }

  /// Bütçe kontrolü yapar ve eşik aşılmışsa Android bildirimini otomatik tetikler
  Future<void> butceKontrolVeBildir(ProfilModeli profil) async {
    final harcanan = donemHarcamasi(profil);
    final butce = profil.aylikButce;
    if (butce <= 0) return;

    final oran = harcanan / butce;
    final kalan = butce - harcanan;

    if (oran >= 1.0) {
      await BildirimServisi().butceAsimUyarisi(
        harcanan: harcanan,
        butce: butce,
        asim: harcanan - butce,
        titresim: profil.titresimAcik,
      );
    } else if (oran >= 0.80) {
      await BildirimServisi().butceEsikUyarisi(
        harcanan: harcanan,
        butce: butce,
        kalan: kalan,
        yuzde: (oran * 100).toInt(),
        titresim: profil.titresimAcik,
      );
    }

    // Dönem sonu 3 gün kontrolü
    if (profil.kalanGunSayisi <= 3 && profil.kalanGunSayisi > 0) {
      await BildirimServisi().donemSonuHatirlatici(
        kalanGun: profil.kalanGunSayisi,
        kalanButce: kalan,
        titresim: profil.titresimAcik,
      );
    }
  }

  /// Sepetteki ürünlerden yeni bir fiş oluşturup SQLite veritabanına kaydeder
  Future<FisModeli> sepettenFisOlusturVeKaydet({
    required List<UrunModeli> urunler,
    String? marketAdi,
    String? aciklama,
    ProfilModeli? profil,
  }) async {
    final rastgeleNo = (DateTime.now().millisecondsSinceEpoch % 90000) + 10000;
    final fisId = 'FG-$rastgeleNo';

    final yeniFis = FisModeli(
      id: fisId,
      marketAdi: marketAdi ?? 'Migros Jet',
      aciklama: aciklama ?? 'Alışveriş Fişi',
      tarih: DateTime.now(),
      urunler: List<UrunModeli>.from(urunler),
    );

    await _db.fisEkle(yeniFis);
    await verileriYukle();

    if (profil != null) {
      await butceKontrolVeBildir(profil);
    }

    return yeniFis;
  }

  /// Tek bir fişi siler
  Future<void> fisSil(String id) async {
    await _db.fisSil(id);
    await verileriYukle();
  }

  /// Tüm fiş geçmişini temizler
  Future<void> tumFisleriTemizle() async {
    await _db.tumFisleriSil();
    await verileriYukle();
  }
}
