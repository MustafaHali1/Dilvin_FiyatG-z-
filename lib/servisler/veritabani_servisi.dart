import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../modeller/fis_modeli.dart';
import '../modeller/urun_modeli.dart';
import '../modeller/kullanici_modeli.dart';

/// SQLite veritabanı işlemlerini yöneten profesyonel servis sınıfı (Singleton)
class VeritabaniServisi {
  static final VeritabaniServisi _ornek = VeritabaniServisi._dahili();
  factory VeritabaniServisi() => _ornek;
  VeritabaniServisi._dahili();

  Database? _veritabani;

  Future<Database> get veritabani async {
    if (_veritabani != null) return _veritabani!;
    _veritabani = await _veritabaniBaslat();
    return _veritabani!;
  }

  Future<Database> _veritabaniBaslat() async {
    final veriTabaniYolu = await getDatabasesPath();
    final yol = p.join(veriTabaniYolu, 'fiyatgoz.db');

    return await openDatabase(
      yol,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // 1. Kullanıcı Tablosu
        await db.execute('''
          CREATE TABLE kullanici (
            id INTEGER PRIMARY KEY,
            ad_soyad TEXT NOT NULL,
            eposta TEXT NOT NULL,
            eposta_bulteni_aktif INTEGER NOT NULL DEFAULT 1,
            kayit_tarihi TEXT NOT NULL
          )
        ''');

        // 2. Fişler Tablosu
        await db.execute('''
          CREATE TABLE fisler (
            id TEXT PRIMARY KEY,
            market_adi TEXT NOT NULL,
            aciklama TEXT NOT NULL,
            tarih TEXT NOT NULL,
            toplam_tutar REAL NOT NULL,
            toplam_indirim REAL NOT NULL DEFAULT 0.0
          )
        ''');

        // 3. Fiş Ürünleri Tablosu
        await db.execute('''
          CREATE TABLE fis_urunleri (
            id TEXT PRIMARY KEY,
            fis_id TEXT NOT NULL,
            ad TEXT NOT NULL,
            birim_fiyat REAL NOT NULL,
            eski_fiyat REAL,
            adet INTEGER NOT NULL DEFAULT 1,
            gorsel_yolu TEXT,
            ai_tanidi INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (fis_id) REFERENCES fisler (id) ON DELETE CASCADE
          )
        ''');

        // Başlangıç varsayılan kullanıcısı
        final simdi = DateTime.now();
        await db.insert('kullanici', {
          'id': 1,
          'ad_soyad': 'Ahmet Yılmaz',
          'eposta': 'ahmet.yilmaz@fiyatgoz.com',
          'eposta_bulteni_aktif': 1,
          'kayit_tarihi': simdi.toIso8601String(),
        });

        // Başlangıç örnek fişleri ve ürünleri
        await _ornekVerileriEkle(db, simdi);
      },
    );
  }

  Future<void> _ornekVerileriEkle(Database db, DateTime simdi) async {
    // Fiş 1: Migros
    final fis1Tarih = simdi.subtract(const Duration(days: 1));
    await db.insert('fisler', {
      'id': 'FG-84920',
      'market_adi': 'Migros',
      'aciklama': 'Migros Haftalık Alışveriş',
      'tarih': fis1Tarih.toIso8601String(),
      'toplam_tutar': 222.50,
      'toplam_indirim': 10.00,
    });
    await db.insert('fis_urunleri', {
      'id': 'U-101',
      'fis_id': 'FG-84920',
      'ad': 'Sütaş Tam Yağlı Süt 1L',
      'birim_fiyat': 24.90,
      'eski_fiyat': 29.90,
      'adet': 2,
      'ai_tanidi': 1,
    });
    await db.insert('fis_urunleri', {
      'id': 'U-102',
      'fis_id': 'FG-84920',
      'ad': 'Halk Ekmek 250g',
      'birim_fiyat': 8.00,
      'adet': 3,
      'ai_tanidi': 0,
    });
    await db.insert('fis_urunleri', {
      'id': 'U-103',
      'fis_id': 'FG-84920',
      'ad': 'Ezine Beyaz Peynir 500g',
      'birim_fiyat': 148.70,
      'adet': 1,
      'ai_tanidi': 0,
    });

    // Fiş 2: BİM
    final fis2Tarih = simdi.subtract(const Duration(days: 3));
    await db.insert('fisler', {
      'id': 'FG-84110',
      'market_adi': 'BİM',
      'aciklama': 'BİM Temizlik ve Kahvaltı',
      'tarih': fis2Tarih.toIso8601String(),
      'toplam_tutar': 154.80,
      'toplam_indirim': 15.00,
    });
    await db.insert('fis_urunleri', {
      'id': 'U-201',
      'fis_id': 'FG-84110',
      'ad': 'Gezen Tavuk Yumurtası 10\'lu',
      'birim_fiyat': 64.90,
      'eski_fiyat': 79.90,
      'adet': 1,
      'ai_tanidi': 1,
    });
    await db.insert('fis_urunleri', {
      'id': 'U-202',
      'fis_id': 'FG-84110',
      'ad': 'Yüzey Temizleyici 1.5L',
      'birim_fiyat': 89.90,
      'adet': 1,
      'ai_tanidi': 0,
    });

    // Fiş 3: A101
    final fis3Tarih = simdi.subtract(const Duration(days: 7));
    await db.insert('fisler', {
      'id': 'FG-83540',
      'market_adi': 'A101',
      'aciklama': 'A101 Manav & Süt',
      'tarih': fis3Tarih.toIso8601String(),
      'toplam_tutar': 101.00,
      'toplam_indirim': 8.00,
    });
    await db.insert('fis_urunleri', {
      'id': 'U-301',
      'fis_id': 'FG-83540',
      'ad': 'Amasya Elma 1kg',
      'birim_fiyat': 29.50,
      'eski_fiyat': 33.50,
      'adet': 2,
      'ai_tanidi': 0,
    });
    await db.insert('fis_urunleri', {
      'id': 'U-302',
      'fis_id': 'FG-83540',
      'ad': 'Doğal Yoğurt 1kg',
      'birim_fiyat': 42.00,
      'adet': 1,
      'ai_tanidi': 1,
    });
  }

  // ==================== KULLANICI İŞLEMLERİ ====================

  Future<KullaniciModeli> kullaniciGetir() async {
    final db = await veritabani;
    final sonuclar = await db.query('kullanici', where: 'id = ?', whereArgs: [1]);
    if (sonuclar.isNotEmpty) {
      return KullaniciModeli.fromMap(sonuclar.first);
    }
    final varsayilan = KullaniciModeli.varsayilan();
    await db.insert('kullanici', varsayilan.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return varsayilan;
  }

  Future<void> kullaniciKaydet(KullaniciModeli kullanici) async {
    final db = await veritabani;
    await db.insert(
      'kullanici',
      kullanici.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== FİŞ VE ÜRÜN İŞLEMLERİ ====================

  Future<void> fisEkle(FisModeli fis) async {
    final db = await veritabani;
    await db.transaction((txn) async {
      // 1. Fiş tablosuna ekle
      await txn.insert(
        'fisler',
        fis.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Ürünler tablosuna tek tek ekle
      final batch = txn.batch();
      for (final urun in fis.urunler) {
        batch.insert(
          'fis_urunleri',
          urun.toMap(fisId: fis.id),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<FisModeli>> tumFisleriGetir() async {
    final db = await veritabani;
    final fisListesi = await db.query('fisler', orderBy: 'tarih DESC');
    if (fisListesi.isEmpty) return [];

    // Tüm ürünleri çekip fiş id'sine göre grupla
    final urunListesi = await db.query('fis_urunleri');
    final Map<String, List<UrunModeli>> urunHaritasi = {};

    for (final u in urunListesi) {
      final fisId = u['fis_id'] as String;
      urunHaritasi.putIfAbsent(fisId, () => []).add(UrunModeli.fromMap(u));
    }

    return fisListesi.map((f) {
      final id = f['id'] as String;
      final urunler = urunHaritasi[id] ?? [];
      return FisModeli.fromMap(f, urunler: urunler);
    }).toList();
  }

  Future<FisModeli?> fisGetir(String id) async {
    final db = await veritabani;
    final fisSonuc = await db.query('fisler', where: 'id = ?', whereArgs: [id]);
    if (fisSonuc.isEmpty) return null;

    final urunSonuc = await db.query('fis_urunleri', where: 'fis_id = ?', whereArgs: [id]);
    final urunler = urunSonuc.map((u) => UrunModeli.fromMap(u)).toList();

    return FisModeli.fromMap(fisSonuc.first, urunler: urunler);
  }

  Future<int> fisSil(String id) async {
    final db = await veritabani;
    // ON DELETE CASCADE sayesinde fis_urunleri de silinir
    return await db.delete('fisler', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> tumFisleriSil() async {
    final db = await veritabani;
    await db.transaction((txn) async {
      await txn.delete('fis_urunleri');
      await txn.delete('fisler');
    });
  }

  // ==================== İSTATİSTİKSEL HESAPLAMALAR ====================

  /// Belirtilen ay içindeki toplam harcamayı getirir (Varsayılan: İçinde bulunulan ay)
  Future<double> buAykiToplamHarcama([DateTime? ay]) async {
    final db = await veritabani;
    final hedefAy = ay ?? DateTime.now();
    final ayBasi = DateTime(hedefAy.year, hedefAy.month, 1).toIso8601String();
    final aySonu = DateTime(hedefAy.year, hedefAy.month + 1, 0, 23, 59, 59).toIso8601String();

    final sonuc = await db.rawQuery('''
      SELECT SUM(toplam_tutar) as toplam
      FROM fisler
      WHERE tarih >= ? AND tarih <= ?
    ''', [ayBasi, aySonu]);

    if (sonuc.isNotEmpty && sonuc.first['toplam'] != null) {
      return (sonuc.first['toplam'] as num).toDouble();
    }
    return 0.0;
  }

  /// Tüm zamanların toplam tasarruf (indirim) kazancını hesaplar
  Future<double> toplamTasarruf() async {
    final db = await veritabani;
    final sonuc = await db.rawQuery('''
      SELECT SUM(toplam_indirim) as tasarruf
      FROM fisler
    ''');

    if (sonuc.isNotEmpty && sonuc.first['tasarruf'] != null) {
      return (sonuc.first['tasarruf'] as num).toDouble();
    }
    return 0.0;
  }

  /// Toplam kayıtlı fiş sayısını döner
  Future<int> fisSayisi() async {
    final db = await veritabani;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM fisler'),
    );
    return count ?? 0;
  }
}
