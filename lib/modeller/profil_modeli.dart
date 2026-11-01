/// Kullanıcı profil türleri
enum ProfilTuru {
  standart,
  kolayMod,
  renkKoruModu,
}

/// Renk körlüğü türleri
enum RenkKorluguTuru {
  deuteranopi, // Yeşil (en yaygın)
  protanopi,   // Kırmızı
  tritanopi,   // Mavi-Sarı
}

/// Kullanıcının erişilebilirlik ve arayüz ayarları
class ProfilModeli {
  final ProfilTuru profilTuru;
  final RenkKorluguTuru renkKorluguTuru;
  final double yaziBoyutuCarpani;
  final bool sesliAsistanAcik;
  final bool titresimAcik;
  final double aylikButce;

  const ProfilModeli({
    this.profilTuru = ProfilTuru.standart,
    this.renkKorluguTuru = RenkKorluguTuru.deuteranopi,
    this.yaziBoyutuCarpani = 1.0,
    this.sesliAsistanAcik = true,
    this.titresimAcik = true,
    this.aylikButce = 5000.0,
  });

  ProfilModeli kopyala({
    ProfilTuru? profilTuru,
    RenkKorluguTuru? renkKorluguTuru,
    double? yaziBoyutuCarpani,
    bool? sesliAsistanAcik,
    bool? titresimAcik,
    double? aylikButce,
  }) {
    return ProfilModeli(
      profilTuru: profilTuru ?? this.profilTuru,
      renkKorluguTuru: renkKorluguTuru ?? this.renkKorluguTuru,
      yaziBoyutuCarpani: yaziBoyutuCarpani ?? this.yaziBoyutuCarpani,
      sesliAsistanAcik: sesliAsistanAcik ?? this.sesliAsistanAcik,
      titresimAcik: titresimAcik ?? this.titresimAcik,
      aylikButce: aylikButce ?? this.aylikButce,
    );
  }
}
