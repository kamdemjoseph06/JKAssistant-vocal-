import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/voice_bloc.dart';
import '../../core/voice/voice_recognizer.dart';

// ── Bouton microphone principal ────────────────────────────
class MicButton extends StatelessWidget {
  final AssistantStatus status;
  final VoidCallback onPressed;

  const MicButton({
    super.key,
    required this.status,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isListening = status == AssistantStatus.listening;
    final isProcessing = status == AssistantStatus.processing ||
        status == AssistantStatus.speaking;
    final isReady = status == AssistantStatus.ready;

    return GestureDetector(
      onTap: (isReady || isListening) ? onPressed : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anneau pulsant quand écoute active
          if (isListening)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
                  width: 2,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.3, 1.3),
                  duration: 1200.ms,
                  curve: Curves.easeOut,
                )
                .fadeOut(duration: 1200.ms),

          // Bouton principal
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening
                  ? const Color(0xFF4ECDC4)
                  : isProcessing
                      ? const Color(0xFFFFB347)
                      : const Color(0xFF1E2A3A),
              boxShadow: [
                BoxShadow(
                  color: isListening
                      ? const Color(0xFF4ECDC4).withOpacity(0.4)
                      : Colors.black.withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
              border: Border.all(
                color: isListening
                    ? const Color(0xFF4ECDC4)
                    : const Color(0xFF2A3A50),
                width: 2,
              ),
            ),
            child: Icon(
              isListening
                  ? Icons.mic
                  : isProcessing
                      ? Icons.hourglass_top_rounded
                      : Icons.mic_none_rounded,
              size: 40,
              color: isListening
                  ? const Color(0xFF0A0E1A)
                  : const Color(0xFF4ECDC4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Affichage du statut et texte reconnu ──────────────────
class StatusDisplay extends StatelessWidget {
  final VoiceState state;

  const StatusDisplay({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Indicateur de statut
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor(state.status).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _statusColor(state.status).withOpacity(0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _statusColor(state.status),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _statusLabel(state.status),
                style: GoogleFonts.spaceGrotesk(
                  color: _statusColor(state.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Texte partiel en cours (gris)
        if (state.partialText.isNotEmpty)
          Text(
            state.partialText,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF6B7280),
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(),

        // Texte principal
        Text(
          state.displayText,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ).animate(key: ValueKey(state.displayText)).fadeIn(duration: 300.ms),
      ],
    );
  }

  Color _statusColor(AssistantStatus status) {
    return switch (status) {
      AssistantStatus.listening => const Color(0xFF4ECDC4),
      AssistantStatus.processing => const Color(0xFFFFB347),
      AssistantStatus.speaking => const Color(0xFF9B8DFF),
      AssistantStatus.error => const Color(0xFFFF6B6B),
      AssistantStatus.ready => const Color(0xFF4CAF50),
      AssistantStatus.initializing => const Color(0xFF6B7280),
    };
  }

  String _statusLabel(AssistantStatus status) {
    return switch (status) {
      AssistantStatus.listening => 'ÉCOUTE',
      AssistantStatus.processing => 'TRAITEMENT',
      AssistantStatus.speaking => 'PARLE',
      AssistantStatus.error => 'ERREUR',
      AssistantStatus.ready => 'PRÊT',
      AssistantStatus.initializing => 'CHARGEMENT',
    };
  }
}

// ── Toggle langue FR / EN ──────────────────────────────────
class LanguageToggle extends StatelessWidget {
  final VoiceLanguage currentLanguage;
  final ValueChanged<VoiceLanguage> onChanged;

  const LanguageToggle({
    super.key,
    required this.currentLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141824),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3040)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langButton('FR', VoiceLanguage.french),
          _langButton('EN', VoiceLanguage.english),
        ],
      ),
    );
  }

  Widget _langButton(String label, VoiceLanguage lang) {
    final isActive = currentLanguage == lang;
    return GestureDetector(
      onTap: () => onChanged(lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4ECDC4) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: isActive ? const Color(0xFF0A0E1A) : const Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Placeholder pour l'historique ─────────────────────────
class CommandHistoryTile extends StatelessWidget {
  final String command;
  final String result;
  final DateTime time;

  const CommandHistoryTile({
    super.key,
    required this.command,
    required this.result,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141824),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: Color(0xFF4ECDC4), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(command,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(result,
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
