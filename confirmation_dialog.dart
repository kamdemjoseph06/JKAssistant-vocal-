import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Affiché quand la confiance NLU est entre 0.3 et 0.6
/// "Vous voulez dire : Appeler Jean ?" → Oui / Non / Répéter
class ConfirmationDialog extends StatelessWidget {
  final String suggestion;         // ex: "Appeler Jean ?"
  final VoidCallback onConfirm;
  final VoidCallback onDeny;
  final VoidCallback onRepeat;

  const ConfirmationDialog({
    super.key,
    required this.suggestion,
    required this.onConfirm,
    required this.onDeny,
    required this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141824),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB347).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB347).withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône
          const Icon(Icons.help_outline_rounded,
              color: Color(0xFFFFB347), size: 32),
          const SizedBox(height: 12),

          // Question
          Text(
            'Vous voulez dire :',
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            suggestion,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Boutons
          Row(
            children: [
              // NON
              Expanded(
                child: _ActionButton(
                  label: 'Non',
                  icon: Icons.close_rounded,
                  color: const Color(0xFFFF6B6B),
                  onTap: onDeny,
                ),
              ),
              const SizedBox(width: 10),

              // RÉPÉTER
              Expanded(
                child: _ActionButton(
                  label: 'Répéter',
                  icon: Icons.mic_rounded,
                  color: const Color(0xFF6B7280),
                  onTap: onRepeat,
                ),
              ),
              const SizedBox(width: 10),

              // OUI
              Expanded(
                child: _ActionButton(
                  label: 'Oui',
                  icon: Icons.check_rounded,
                  color: const Color(0xFF4ECDC4),
                  onTap: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
