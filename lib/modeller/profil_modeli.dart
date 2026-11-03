/// Uygulama Genelinde 4 Ana Erişilebilirlik Modu
enum ProfilTuru {
  standart,
  kolayMod,
  renkKoruModu,
  gormeEngelliModu,
}

/// Renk Körlüğü Tıbbi Alt Türleri
enum RenkKorluguTuru {
  deuteranopi, // Yeşil (En yaygın)
  protanopi,   // Kırmızı
  tritanopi,   // Mavi-Sarı
}

/// Kullanıcının Seçtiği Profil ve İnce Ayarları
class ProfilModeli {
  final ProfilTuru profilTuru;
  final RenkKorluguTuru renkKorluguTuru;
  final double yaziBoyutu;
  final String kontrastTuru; // 'normal', 'siyah_sari', 'beyaz_siyah'
  final bool sesliAsistanAcik;
  final bool titresimAcik;
  final double aylikButce;
  final DateTime? butceBaslangicTarihi;
  final DateTime? butceBitisTarihi;

  const ProfilModeli({
    this.profilTuru = ProfilTuru.standart,
    this.renkKorluguTuru = RenkKorluguTuru.deuteranopi,
    this.yaziBoyutu = 16.0,
    this.kontrastTuru = 'siyah_sari',
    this.sesliAsistanAcik = true,
    this.titresimAcik = true,
    this.aylikButce = 5000.0,
    this.butceBaslangicTarihi,
    this.butceBitisTarihi,
  });

  DateTime get etkinButceBaslangic {
    if (butceBaslangicTarihi != null) return butceBaslangicTarihi!;
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  DateTime get etkinButceBitis {
    if (butceBitisTarihi != null) return butceBitisTarihi!;
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  int get kalanGunSayisi {
    final now = DateTime.now();
    final diff = etkinButceBitis.difference(now).inDays;
    return diff < 0 ? 0 : diff + 1;
  }

  String get butceDonemiFormatli {
    final baslangic = etkinButceBaslangic;
    final bitis = etkinButceBitis;
    const aylar = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${baslangic.day} ${aylar[baslangic.month]} - ${bitis.day} ${aylar[bitis.month]}';
  }

  ProfilModeli kopyala({
    ProfilTuru? profilTuru,
    RenkKorluguTuru? renkKorluguTuru,
    double? yaziBoyutu,
    String? kontrastTuru,
    bool? sesliAsistanAcik,
    bool? titresimAcik,
    double? aylikButce,
    DateTime? butceBaslangicTarihi,
    DateTime? butceBitisTarihi,
  }) {
    return ProfilModeli(
      profilTuru: profilTuru ?? this.profilTuru,
      renkKorluguTuru: renkKorluguTuru ?? this.renkKorluguTuru,
      yaziBoyutu: yaziBoyutu ?? this.yaziBoyutu,
      kontrastTuru: kontrastTuru ?? this.kontrastTuru,
      sesliAsistanAcik: sesliAsistanAcik ?? this.sesliAsistanAcik,
      titresimAcik: titresimAcik ?? this.titresimAcik,
      aylikButce: aylikButce ?? this.aylikButce,
      butceBaslangicTarihi: butceBaslangicTarihi ?? this.butceBaslangicTarihi,
      butceBitisTarihi: butceBitisTarihi ?? this.butceBitisTarihi,
    );
  }
}
