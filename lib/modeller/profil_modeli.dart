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

  const ProfilModeli({
    this.profilTuru = ProfilTuru.standart,
    this.renkKorluguTuru = RenkKorluguTuru.deuteranopi,
    this.yaziBoyutu = 16.0,
    this.kontrastTuru = 'siyah_sari',
    this.sesliAsistanAcik = true,
    this.titresimAcik = true,
    this.aylikButce = 5000.0,
  });

  ProfilModeli kopyala({
    ProfilTuru? profilTuru,
    RenkKorluguTuru? renkKorluguTuru,
    double? yaziBoyutu,
    String? kontrastTuru,
    bool? sesliAsistanAcik,
    bool? titresimAcik,
    double? aylikButce,
  }) {
    return ProfilModeli(
      profilTuru: profilTuru ?? this.profilTuru,
      renkKorluguTuru: renkKorluguTuru ?? this.renkKorluguTuru,
      yaziBoyutu: yaziBoyutu ?? this.yaziBoyutu,
      kontrastTuru: kontrastTuru ?? this.kontrastTuru,
      sesliAsistanAcik: sesliAsistanAcik ?? this.sesliAsistanAcik,
      titresimAcik: titresimAcik ?? this.titresimAcik,
      aylikButce: aylikButce ?? this.aylikButce,
    );
  }
}
