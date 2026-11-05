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
      onOpen: (db) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ogrenilen_kaliplar (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ham_metin TEXT NOT NULL UNIQUE,
            niyet TEXT NOT NULL,
            hedef_urun TEXT,
            eklenme_tarihi TEXT NOT NULL
          )
        ''');
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
          'ad_soyad': 'Kullanıcı',
          'eposta': 'kullanici@sepetgoz.com',
          'eposta_bulteni_aktif': 1,
          'kayit_tarihi': simdi.toIso8601String(),
        });
      },
    );
  }

  /// Veritabanındaki sahte ve örnek test fişlerini tamamen temizler
  Future<void> sahteVerileriTemizle() async {
    final db = await veritabani;
    await db.delete('fis_urunleri');
    await db.delete('fisler');
  }

  // ==================== KENDİ KENDİNİ EĞİTEN ŞABLONLAR (EDGE DISTILLATION) ====================

  /// Öğrenilmiş kalıbı yerel veritabanında arar (İnternetsiz ortamda sıfır gecikmeyle çalışır)
  Future<Map<String, dynamic>?> ogrenilenKalipGetir(String metin) async {
    final db = await veritabani;
    final temiz = metin.trim().toLowerCase();
    final sonuclar = await db.query(
      'ogrenilen_kaliplar',
      where: 'ham_metin = ?',
      whereArgs: [temiz],
      limit: 1,
    );
    if (sonuclar.isNotEmpty) {
      return sonuclar.first;
    }
    return null;
  }

  /// Gemini'nin çözdüğü yeni şive/cümle niyetini yerel SQLite hafızasına kalıcı olarak işler
  Future<void> kalipOgren({
    required String metin,
    required String niyet,
    String? hedefUrun,
  }) async {
    final db = await veritabani;
    final temiz = metin.trim().toLowerCase();
    await db.insert(
      'ogrenilen_kaliplar',
      {
        'ham_metin': temiz,
        'niyet': niyet,
        'hedef_urun': hedefUrun,
        'eklenme_tarihi': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
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
