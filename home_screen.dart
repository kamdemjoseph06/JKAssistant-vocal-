import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/voice_bloc.dart';
import '../widgets/mic_button.dart';
import '../widgets/confirmation_dialog.dart';
import '../../core/voice/voice_recognizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: BlocBuilder<VoiceBloc, VoiceState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context, state),
                const Spacer(),
                _buildStatusArea(state),
                const SizedBox(height: 16),

                // Dialogue de confirmation si confiance faible
                if (state.pendingConfirmation != null)
                  ConfirmationDialog(
                    suggestion: state.pendingConfirmation!,
                    onConfirm: () => context.read<VoiceBloc>().add(VoiceConfirmed()),
                    onDeny: () => context.read<VoiceBloc>().add(VoiceDenied()),
                    onRepeat: () => context.read<VoiceBloc>().add(VoiceStartListening()),
                  ),

                const Spacer(),
                _buildMicArea(context, state),
                const SizedBox(height: 32),
                _buildQuickCommands(context, state),
                const SizedBox(height: 16),
                _buildBottomBar(context, state),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VoiceState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VOCAL', style: GoogleFonts.spaceGrotesk(
                fontSize: 26, fontWeight: FontWeight.w700,
                color: Colors.white, letterSpacing: 4,
              )),
              Text('ASSIST', style: GoogleFonts.spaceGrotesk(
                fontSize: 26, fontWeight: FontWeight.w300,
                color: const Color(0xFF4ECDC4), letterSpacing: 4,
              )),
            ],
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),

          const Spacer(),

          // Indicateur Hotword
          GestureDetector(
            onTap: () => context.read<VoiceBloc>().add(VoiceHotwordToggled()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: state.hotwordActive
                    ? const Color(0xFF4ECDC4).withOpacity(0.15)
                    : const Color(0xFF141824),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: state.hotwordActive
                      ? const Color(0xFF4ECDC4)
                      : const Color(0xFF2A3040),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.hotwordActive ? Icons.hearing : Icons.hearing_disabled,
                    color: state.hotwordActive
                        ? const Color(0xFF4ECDC4)
                        : const Color(0xFF6B7280),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.hotwordActive ? 'Hey Vocal ON' : 'Hey Vocal',
                    style: GoogleFonts.spaceGrotesk(
                      color: state.hotwordActive
                          ? const Color(0xFF4ECDC4)
                          : const Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Toggle langue
          _LanguageToggle(
            currentLanguage: state.language,
            onChanged: (lang) =>
                context.read<VoiceBloc>().add(VoiceLanguageChanged(lang)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusArea(VoiceState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(state.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _statusColor(state.status).withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8, height: 8,
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
                    fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1,
                  ),
                ),
                // Mode voiture actif
                if (state.carModeActive) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.directions_car, color: Color(0xFFFFB347), size: 14),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Texte partiel (gris, en cours de reconnaissance)
          if (state.partialText.isNotEmpty)
            Text(
              state.partialText,
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFF6B7280), fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(),

          // Texte principal
          Text(
            state.displayText,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white, fontSize: 20,
              fontWeight: FontWeight.w500, height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ).animate(key: ValueKey(state.displayText)).fadeIn(duration: 300.ms),

          // Barre de confiance NLU
          if (state.lastConfidence > 0 && state.lastConfidence < 1.0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _ConfidenceBar(confidence: state.lastConfidence),
            ),
        ],
      ),
    );
  }

  Widget _buildMicArea(BuildContext context, VoiceState state) {
    return MicButton(
      status: state.status,
      onPressed: () {
        if (state.status == AssistantStatus.listening) {
          context.read<VoiceBloc>().add(VoiceStopListening());
        } else if (state.status == AssistantStatus.ready) {
          context.read<VoiceBloc>().add(VoiceStartListening());
        }
      },
    );
  }

  // Commandes rapides en bas de l'écran
  Widget _buildQuickCommands(BuildContext context, VoiceState state) {
    final lang = state.language == VoiceLanguage.french;
    final commands = lang
        ? ['Appelle [nom]', 'SMS à [nom]', 'Réveil [heure]', 'Mode voiture']
        : ['Call [name]', 'Text [name]', 'Alarm [time]', 'Car mode'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: commands.map((cmd) => GestureDetector(
          onTap: () {
            // Simuler la commande pour la démo
            context.read<VoiceBloc>().add(VoiceTextReceived(cmd));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF141824),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A3040)),
            ),
            child: Text(
              cmd,
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFF6B7280), fontSize: 12,
              ),
            ),
          ),
        )).toList(),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildBottomBar(BuildContext context, VoiceState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141824),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3040)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoChip(Icons.contacts_outlined, '${state.contactsCount}', 'contacts'),
          Container(width: 1, height: 36, color: const Color(0xFF2A3040)),
          _infoChip(
            state.carModeActive ? Icons.directions_car : Icons.directions_car_outlined,
            state.carModeActive ? 'ON' : 'OFF',
            'voiture',
          ),
          Container(width: 1, height: 36, color: const Color(0xFF2A3040)),
          GestureDetector(
            onTap: () => context.read<VoiceBloc>().add(VoiceContactsSynced()),
            child: _infoChip(Icons.refresh_rounded, 'Sync', 'contacts'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _infoChip(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.spaceGrotesk(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13,
        )),
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
      ],
    );
  }

  Color _statusColor(AssistantStatus status) => switch (status) {
    AssistantStatus.listening    => const Color(0xFF4ECDC4),
    AssistantStatus.processing   => const Color(0xFFFFB347),
    AssistantStatus.speaking     => const Color(0xFF9B8DFF),
    AssistantStatus.error        => const Color(0xFFFF6B6B),
    AssistantStatus.ready        => const Color(0xFF4CAF50),
    AssistantStatus.initializing => const Color(0xFF6B7280),
  };

  String _statusLabel(AssistantStatus status) => switch (status) {
    AssistantStatus.listening    => 'ÉCOUTE',
    AssistantStatus.processing   => 'ANALYSE',
    AssistantStatus.speaking     => 'PARLE',
    AssistantStatus.error        => 'ERREUR',
    AssistantStatus.ready        => 'PRÊT',
    AssistantStatus.initializing => 'CHARGEMENT',
  };
}

// ── Barre de confiance NLU ─────────────────────────────────
class _ConfidenceBar extends StatelessWidget {
  final double confidence;
  const _ConfidenceBar({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final color = confidence > 0.75
        ? const Color(0xFF4CAF50)
        : confidence > 0.5
            ? const Color(0xFFFFB347)
            : const Color(0xFFFF6B6B);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Confiance NLU',
                style: TextStyle(color: const Color(0xFF6B7280), fontSize: 11)),
            Text('${(confidence * 100).round()}%',
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: const Color(0xFF2A3040),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

// ── Toggle langue ──────────────────────────────────────────
class _LanguageToggle extends StatelessWidget {
  final VoiceLanguage currentLanguage;
  final ValueChanged<VoiceLanguage> onChanged;
  const _LanguageToggle({required this.currentLanguage, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141824),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A3040)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn('FR', VoiceLanguage.french),
          _btn('EN', VoiceLanguage.english),
        ],
      ),
    );
  }

  Widget _btn(String label, VoiceLanguage lang) {
    final isActive = currentLanguage == lang;
    return GestureDetector(
      onTap: () => onChanged(lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4ECDC4) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: GoogleFonts.spaceGrotesk(
          color: isActive ? const Color(0xFF0A0E1A) : const Color(0xFF6B7280),
          fontWeight: FontWeight.w700, fontSize: 12,
        )),
      ),
    );
  }
}
