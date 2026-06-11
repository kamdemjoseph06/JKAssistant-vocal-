import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum CarModeStatus { active, inactive }

class CarModeService {
  CarModeStatus _status = CarModeStatus.inactive;
  CarModeStatus get status => _status;
  bool get isActive => _status == CarModeStatus.active;

  final StreamController<CarModeStatus> _statusController =
      StreamController<CarModeStatus>.broadcast();
  Stream<CarModeStatus> get onStatusChanged => _statusController.stream;

  /// Activer le mode voiture
  /// Commande : "Mode voiture" / "Je conduis" / "Car mode"
  Future<CarModeResult> activate() async {
    try {
      // 1. Garder l'écran allumé en permanence
      await WakelockPlus.enable();

      // 2. Mettre le volume au maximum
      // Note: nécessite AudioManager via platform channel natif
      // implémenté dans android/app/src/main/kotlin/AudioService.kt

      _status = CarModeStatus.active;
      _statusController.add(_status);

      debugPrint('🚗 Mode voiture ACTIVÉ');
      return CarModeResult.success(
        'Mode voiture activé. Écran toujours allumé. Écoute automatique.',
      );
    } catch (e) {
      debugPrint('❌ CarModeService.activate error: $e');
      return CarModeResult.failure('Erreur activation mode voiture: $e');
    }
  }

  /// Désactiver le mode voiture
  /// Commande : "Quitter mode voiture" / "Je suis arrivé"
  Future<CarModeResult> deactivate() async {
    try {
      // Relâcher le wakelock (écran peut s'éteindre normalement)
      await WakelockPlus.disable();

      _status = CarModeStatus.inactive;
      _statusController.add(_status);

      debugPrint('🚗 Mode voiture DÉSACTIVÉ');
      return CarModeResult.success('Mode voiture désactivé.');
    } catch (e) {
      debugPrint('❌ CarModeService.deactivate error: $e');
      return CarModeResult.failure('Erreur désactivation: $e');
    }
  }

  void dispose() {
    WakelockPlus.disable();
    _statusController.close();
  }
}

class CarModeResult {
  final bool success;
  final String message;
  const CarModeResult.success(this.message) : success = true;
  const CarModeResult.failure(this.message) : success = false;
}
