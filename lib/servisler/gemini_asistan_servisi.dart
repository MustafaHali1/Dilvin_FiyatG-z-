import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'veritabani_servisi.dart';

/// Gemini tarafından çözülen niyet ve konuşma sonucu modeli
class GeminiNiyetSonucu {
  final String komut; // 'BUTCE_SORGULA', 'SEPETE_EKLE', 'SEPET_DOKUMU', 'URUN_ARA', 'IPTAL', 'TAVSIYE', 'DIGER'
  final String? hedefUrun;
  final int? adet;
  final String cevap;

  const GeminiNiyetSonucu({
    required this.komut,
    this.hedefUrun,
    this.adet,
    required this.cevap,
  });

  factory GeminiNiyetSonucu.fromJson(Map<String, dynamic> json) {
    return GeminiNiyetSonucu(
      komut: json['komut'] as String? ?? 'DIGER',
      hedefUrun: json['hedefUrun'] as String?,
      adet: json['adet'] as int?,
      cevap: json['cevap'] as String? ?? '',
    );
  }
}

/// Google Gemini 1.5 Flash ile çalışan, şiveleri, argoyu ve serbest konuşmaları anlayan,
/// kendi kendini yerel SQLite tablosuna (`ogrenilen_kaliplar`) kaydederek eğiten Akıllı Asistan Servisi
class GeminiAsistanServisi {
  static final GeminiAsistanServisi _ornek = GeminiAsistanServisi._dahili();
  factory GeminiAsistanServisi() => _ornek;
  GeminiAsistanServisi._dahili();

  final VeritabaniServisi _db = VeritabaniServisi();

  // Hocanın izniyle serbestçe kullanılan yapılandırılabilir Gemini API Anahtarı
  static String _apiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  static Future<void> anahtarYukle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString('ayar_gemini_api_key');
      if (key != null && key.trim().isNotEmpty) {
        _apiKey = key.trim();
      }
    } catch (_) {}
  }

  static Future<void> apiKeyKaydet(String yeniKey) async {
    _apiKey = yeniKey.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ayar_gemini_api_key', _apiKey);
    } catch (_) {}
  }

  static void apiKeyGuncelle(String yeniKey) {
    _apiKey = yeniKey.trim();
  }

  static bool get apiKeyVarMi => _apiKey.isNotEmpty;
  static String get apiKey => _apiKey;

  // Rate Limiting (Kötüye Kullanım / Bot / Fatura Patlatma Zırhı)
  DateTime? _sonIstekZamani;
  int _dakikalikIstekSayisi = 0;
  DateTime _dakikaBaslangici = DateTime.now();

  bool _rateLimitKontrol() {
    final simdi = DateTime.now();
    if (simdi.difference(_dakikaBaslangici).inMinutes >= 1) {
      _dakikaBaslangici = simdi;
      _dakikalikIstekSayisi = 0;
    }

    // 1 dakikada en fazla 15 istek sınırı
    if (_dakikalikIstekSayisi >= 15) {
      return false;
    }

    // İstekler arası en az 600 ms aralık
    if (_sonIstekZamani != null && simdi.difference(_sonIstekZamani!).inMilliseconds < 600) {
      return false;
    }

    _sonIstekZamani = simdi;
    _dakikalikIstekSayisi++;
    return true;
  }

  /// Kullanıcının söylediği cümleyi çözümler.
  /// 1. Önce SQLite `ogrenilen_kaliplar` hafızasına bakar (İnternetsiz de çalışır).
  /// 2. Hafızada yoksa ve internet varsa Gemini 1.5 Flash'a sorar.
  /// 3. Gemini'nin cevabını SQLite'a işleyerek sistemi gelecekteki internetsiz anlar için eğitir.
  Future<GeminiNiyetSonucu?> niyetCoz({
    required String metin,
    double? kalanButce,
    double? sepetTutar,
    int? sepetAdet,
  }) async {
    final temiz = metin.trim();
    if (temiz.isEmpty) return null;

    // 1. ADIM: Yerel SQLite Hafızasında Var mı? (Self-Learning Edge Distillation)
    try {
      final kayitli = await _db.ogrenilenKalipGetir(temiz);
      if (kayitli != null) {
        debugPrint('🧠 Yerel hafızadan (internetsiz) öğrenilmiş niyet eşleşti: ${kayitli['niyet']}');
        return GeminiNiyetSonucu(
          komut: kayitli['niyet'] as String,
          hedefUrun: kayitli['hedef_urun'] as String?,
          cevap: '',
        );
      }
    } catch (_) {}

    // 2. ADIM: İnternet / Gemini Çağrısı
    if (!_rateLimitKontrol()) {
      debugPrint('⚠️ Hız sınırı (Rate limit) aşıldı, yerel moda dönülüyor.');
      return null;
    }

    final prompt = '''
Kullanıcı market alışverişinde sesli asistanla konuşuyor.
Kullanıcının sözü: "$temiz"
Mevcut durum: Kalan Bütçe: ${kalanButce?.toStringAsFixed(0) ?? "Bilinmiyor"} TL, Sepet Tutarı: ${sepetTutar?.toStringAsFixed(0) ?? "0"} TL, Sepetteki Ürün Adedi: ${sepetAdet ?? 0}.

GÖREV: Kullanıcının cümlesindeki şiveyi, argoyu veya devrik kalıpları çözüp AŞAĞIDAKİ JSON formatında dön:
{
  "komut": "BUTCE_SORGULA" | "SEPETE_EKLE" | "SEPET_DOKUMU" | "URUN_ARA" | "IPTAL" | "TAVSIYE" | "DIGER",
  "hedefUrun": "Varsa aranan veya eklenen ürünün adı (örn: süt, ekmek), yoksa null",
  "adet": 1,
  "cevap": "Kullanıcıya seslendirilecek en fazla 1-2 cümlelik samimi ve net Türkçe yanıt"
}
SADECE GEÇERLİ JSON DÖN. Kod blokları veya açıklama yazma.
''';

    try {
      final jsonYanit = await _geminiMetinGonder(prompt);
      if (jsonYanit == null) return null;

      final sonuc = GeminiNiyetSonucu.fromJson(jsonYanit);

      // 3. ADIM: Sistemi Kendi Kendine Eğit (SQLite'a Kalıcı Olarak Kaydet)
      if (sonuc.komut != 'DIGER') {
        _db.kalipOgren(
          metin: temiz,
          niyet: sonuc.komut,
          hedefUrun: sonuc.hedefUrun,
        );
      }

      return sonuc;
    } catch (e) {
      debugPrint('Gemini niyet çözümleme hatası: $e');
      return null;
    }
  }

  /// Görme Engelli Modu için Görsel Sahne Analizi (Vision AI)
  /// Kamera görüntüsündeki ürünü, markayı ve fiyatı insan gibi anlayıp Türkçe seslendirir.
  Future<String?> goruntudenUrunVeFiyatCoz({
    required Uint8List resimBytes,
    String? arananUrun,
  }) async {
    if (!_rateLimitKontrol()) return null;

    final prompt = arananUrun != null && arananUrun.isNotEmpty
        ? 'Bu market rafında "$arananUrun" var mı? Varsa markasını, çeşidini ve fiyatını 1 kısa cümlede söyle. Yoksa bulunamadı de.'
        : 'Fotoğraftaki en belirgin market ürününü, markasını ve etiketindeki fiyatını görme engelli birine seslendirmek üzere en fazla 2 kısa cümlede Türkçe açıkla.';

    try {
      return await _geminiGorselGonder(resimBytes, prompt);
    } catch (e) {
      debugPrint('Gemini görsel analiz hatası: $e');
      return null;
    }
  }

  // ==================== DÜŞÜK SEVİYELİ HTTP API ÇAĞRILARI ====================

  Future<Map<String, dynamic>?> _geminiMetinGonder(String prompt) async {
    // API anahtarı boşsa dahili yapılandırma veya fallback kullanılır
    final key = _apiKey.isNotEmpty ? _apiKey : _dahiliKey;
    if (key.isEmpty) return null;

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key',
    );

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 4);

    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.1,
          'maxOutputTokens': 120,
          'responseMimeType': 'application/json',
        },
        'systemInstruction': {
          'parts': [
            {
              'text':
                  'Sen Dilvin SepetGöz alışveriş asistanısın. Kod yazma, şiir yazma veya genel felsefi sorulara girme. Daima JSON formatında yanıt ver.'
            }
          ]
        }
      });

      request.write(body);
      final response = await request.close();

      if (response.statusCode == 200) {
        final resBody = await response.transform(utf8.decoder).join();
        final map = jsonDecode(resBody) as Map<String, dynamic>;
        final candidates = map['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content']?['parts']?[0]?['text'] as String?;
          if (content != null) {
            final temizJson = content.trim().replaceAll('```json', '').replaceAll('```', '').trim();
            return jsonDecode(temizJson) as Map<String, dynamic>;
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  Future<String?> _geminiGorselGonder(Uint8List resimBytes, String prompt) async {
    final key = _apiKey.isNotEmpty ? _apiKey : _dahiliKey;
    if (key.isEmpty) return null;

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key',
    );

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;

      final base64Image = base64Encode(resimBytes);

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'inlineData': {
                  'mimeType': 'image/jpeg',
                  'data': base64Image,
                }
              },
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'maxOutputTokens': 90,
        },
        'systemInstruction': {
          'parts': [
            {
              'text':
                  'Sen görme engelliler için market asistanısın. Ürünü ve fiyatını kibar, net, en fazla 2 kısa cümlede Türkçe söyle.'
            }
          ]
        }
      });

      request.write(body);
      final response = await request.close();

      if (response.statusCode == 200) {
        final resBody = await response.transform(utf8.decoder).join();
        final map = jsonDecode(resBody) as Map<String, dynamic>;
        final candidates = map['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final text = candidates.first['content']?['parts']?[0]?['text'] as String?;
          return text?.trim();
        }
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  // Varsayılan / Fallback anahtar (Kullanıcı dilediğinde Ayarlar'dan güncelleyebilir)
  static const String _dahiliKey = '';
}
