/// Kullanıcı hesap ve indirim bildirim modeli
class KullaniciModeli {
  final int id;
  final String adSoyad;
  final String eposta;
  final bool epostaBulteniAktif;
  final DateTime kayitTarihi;

  const KullaniciModeli({
    this.id = 1,
    required this.adSoyad,
    required this.eposta,
    this.epostaBulteniAktif = true,
    required this.kayitTarihi,
  });

  /// Varsayılan başlangıç kullanıcısı
  factory KullaniciModeli.varsayilan() {
    return KullaniciModeli(
      id: 1,
      adSoyad: 'Kullanıcı',
      eposta: 'kullanici@sepetgoz.com',
      epostaBulteniAktif: true,
      kayitTarihi: DateTime.now(),
    );
  }

  KullaniciModeli kopyala({
    int? id,
    String? adSoyad,
    String? eposta,
    bool? epostaBulteniAktif,
    DateTime? kayitTarihi,
  }) {
    return KullaniciModeli(
      id: id ?? this.id,
      adSoyad: adSoyad ?? this.adSoyad,
      eposta: eposta ?? this.eposta,
      epostaBulteniAktif: epostaBulteniAktif ?? this.epostaBulteniAktif,
      kayitTarihi: kayitTarihi ?? this.kayitTarihi,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ad_soyad': adSoyad,
      'eposta': eposta,
      'eposta_bulteni_aktif': epostaBulteniAktif ? 1 : 0,
      'kayit_tarihi': kayitTarihi.toIso8601String(),
    };
  }

  factory KullaniciModeli.fromMap(Map<String, dynamic> map) {
    return KullaniciModeli(
      id: map['id'] as int? ?? 1,
      adSoyad: map['ad_soyad'] as String? ?? 'Kullanıcı',
      eposta: map['eposta'] as String? ?? '',
      epostaBulteniAktif: (map['eposta_bulteni_aktif'] as int? ?? 1) == 1,
      kayitTarihi: map['kayit_tarihi'] != null
          ? DateTime.tryParse(map['kayit_tarihi'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
