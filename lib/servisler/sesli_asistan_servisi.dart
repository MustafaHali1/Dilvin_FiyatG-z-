import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Haptik titreşim türleri (özellikle görme engelli radar ve buton geri bildirimi için)
enum TitresimTuru {
  hafif,
  orta,
  agir,
  secim,
  basari,
  hata,
  radarKilitlendi,
}

/// Uygulama genelinde ses sentezi (TTS), ses tanıma (STT) ve haptik titreşim motorunu yöneten merkezi servis
class SesliAsistanServisi {
  static final SesliAsistanServisi _ornek = SesliAsistanServisi._dahili();
  factory SesliAsistanServisi() => _ornek;
  SesliAsistanServisi._dahili();

  FlutterTts? _tts;
  stt.SpeechToText? _stt;

  bool _ttsHazir = false;
  bool _sttHazir = false;
  bool _konusuyor = false;
  bool _dinliyor = false;

  bool get konusuyorMu => _konusuyor;
  bool get dinliyorMu => _dinliyor;
  bool get ttsHazir => _ttsHazir;
  bool get sttHazir => _sttHazir;

  /// TTS Motorunu başlatır ve Türkçe ayarlamalarını yapar
  Future<void> ttsBaslat() async {
    if (_ttsHazir) return;
    try {
      _tts = FlutterTts();
      await _tts!.setLanguage('tr-TR');
      await _tts!.setSpeechRate(0.5); // Doğal ve anlaşılır konuşma hızı
      await _tts!.setPitch(1.0);
      await _tts!.setVolume(1.0);

      _tts!.setStartHandler(() {
        _konusuyor = true;
      });

      _tts!.setCompletionHandler(() {
        _konusuyor = false;
      });

      _tts!.setErrorHandler((msg) {
        _konusuyor = false;
        debugPrint('TTS Hatası: $msg');
      });

      _ttsHazir = true;
    } catch (e) {
      debugPrint('TTS başlatılamadı: $e');
    }
  }

  /// Verilen Türkçe metni seslendirir
  Future<void> konus(String metin, {bool sessizModdaIptal = false}) async {
    if (metin.trim().isEmpty) return;
    try {
      if (!_ttsHazir) {
        await ttsBaslat();
      }
      if (_konusuyor) {
        await durdur();
      }
      await _tts?.speak(metin);
    } catch (e) {
      debugPrint('Sesli okuma hatası: $e');
    }
  }

  /// Aktif sesli okumayı durdurur
  Future<void> durdur() async {
    try {
      if (_tts != null && _konusuyor) {
        await _tts!.stop();
        _konusuyor = false;
      }
    } catch (e) {
      debugPrint('TTS durdurma hatası: $e');
    }
  }

  /// STT Ses Tanıma Motorunu başlatır
  Future<bool> sttBaslat() async {
    if (_sttHazir) return true;
    try {
      _stt = stt.SpeechToText();
      _sttHazir = await _stt!.initialize(
        onError: (val) {
          _dinliyor = false;
          debugPrint('STT Hatası: ${val.errorMsg}');
        },
        onStatus: (val) {
          _dinliyor = val == 'listening';
          debugPrint('STT Durumu: $val');
        },
      );
      return _sttHazir;
    } catch (e) {
      debugPrint('STT başlatılamadı: $e');
      _sttHazir = false;
      return false;
    }
  }

  /// Mikrofonu açıp kullanıcının konuşmasını dinler
  Future<void> dinle({
    required Function(String metin, bool sonMu) onSonuc,
    Duration dinlemeSuresi = const Duration(seconds: 6),
  }) async {
    try {
      if (!_sttHazir) {
        final basarili = await sttBaslat();
        if (!basarili) {
          debugPrint('Mikrofon tanıma servisi hazır değil.');
          return;
        }
      }

      // Konuşma dinlerken asistan susmalı
      await durdur();
      titret(TitresimTuru.secim);

      _dinliyor = true;
      await _stt?.listen(
        onResult: (result) {
          onSonuc(result.recognizedWords, result.finalResult);
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
          localeId: 'tr_TR',
          listenFor: dinlemeSuresi,
          pauseFor: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _dinliyor = false;
      debugPrint('Dinleme başlatılamadı: $e');
    }
  }

  /// Dinlemeyi durdurur
  Future<void> dinlemeyiDurdur() async {
    try {
      if (_stt != null && _dinliyor) {
        await _stt!.stop();
        _dinliyor = false;
      }
    } catch (e) {
      debugPrint('STT durdurma hatası: $e');
    }
  }

  /// Donanımsal haptik titreşim üretir (park sensörü / buton bildirimi)
  void titret(TitresimTuru tur) {
    try {
      switch (tur) {
        case TitresimTuru.hafif:
          HapticFeedback.lightImpact();
          break;
        case TitresimTuru.orta:
          HapticFeedback.mediumImpact();
          break;
        case TitresimTuru.agir:
          HapticFeedback.heavyImpact();
          break;
        case TitresimTuru.secim:
          HapticFeedback.selectionClick();
          break;
        case TitresimTuru.basari:
          HapticFeedback.mediumImpact();
          Future.delayed(const Duration(milliseconds: 100), () {
            HapticFeedback.mediumImpact();
          });
          break;
        case TitresimTuru.hata:
          HapticFeedback.heavyImpact();
          Future.delayed(const Duration(milliseconds: 120), () {
            HapticFeedback.heavyImpact();
          });
          break;
        case TitresimTuru.radarKilitlendi:
          // Güçlü ardışık 3 titreşim: Hedef etiket tam merkezde kilitlendi
          HapticFeedback.heavyImpact();
          Future.delayed(const Duration(milliseconds: 80), () {
            HapticFeedback.heavyImpact();
            Future.delayed(const Duration(milliseconds: 80), () {
              HapticFeedback.heavyImpact();
            });
          });
          break;
      }
    } catch (e) {
      debugPrint('Titreşim hatası: $e');
    }
  }

  /// Kaynakları temizler
  void kapat() {
    _tts?.stop();
    _stt?.stop();
    _konusuyor = false;
    _dinliyor = false;
  }
}
