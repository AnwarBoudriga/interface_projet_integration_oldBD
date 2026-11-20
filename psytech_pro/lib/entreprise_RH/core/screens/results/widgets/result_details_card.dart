import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_table.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/status_badge.dart';
import '../../../models/candidate_result.dart';
import '../../../models/invitation_model.dart';

class ResultDetailsCard extends StatelessWidget {
  const ResultDetailsCard({super.key, required this.invitation, required this.result});

  final InvitationModel? invitation;
  final CandidateResult? result;

  Widget _info(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11.5, color: AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final inv = invitation;
    final res = result;

    return CustomCard(
      title: 'Résultats détaillés par candidat',
      child: (inv == null || res == null)
          ? const EmptyState(
              icon: Icons.description_outlined,
              title: 'Aucun résultat à afficher',
              message:
                  'Lorsqu’un candidat aura des résultats, sélectionnez-le pour consulter le détail ici.',
              verticalPadding: 64,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 40,
                  runSpacing: 14,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    _info('Candidat', inv.name),
                    _info('Email', inv.email),
                    _info('Test', inv.testTitle),
                    _info('Score',
                        '${res.score} / ${res.total} (${res.percent.round()} %)'),
                    StatusBadge(
                      res.passed ? 'Réussi' : 'Échoué',
                      tone: res.passed ? BadgeTone.success : BadgeTone.danger,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: CustomTable(
                    minWidth: 640,
                    headers: const [
                      'N°',
                      'Question',
                      'Réponse du candidat',
                      'Bonne réponse',
                      'Points',
                    ],
                    flexes: const [1, 5, 3, 3, 2],
                    rows: [
                      for (var i = 0; i < res.lines.length; i++)
                        [
                          CustomTable.cell('${i + 1}'),
                          CustomTable.cell(res.lines[i].question),
                          CustomTable.cell(res.lines[i].chosen),
                          CustomTable.cell(res.lines[i].correct, muted: true),
                          StatusBadge(
                            '${res.lines[i].earned} / ${res.lines[i].points}',
                            tone: res.lines[i].earned > 0
                                ? BadgeTone.success
                                : BadgeTone.danger,
                          ),
                        ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
