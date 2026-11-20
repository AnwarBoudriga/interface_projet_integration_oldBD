import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/info_note.dart';
import '../../../models/question_model.dart';
import '../../../services/mock_store.dart';

class TestQuestionsCard extends StatelessWidget {
  const TestQuestionsCard({
    super.key,
    required this.selectedId,
    required this.onSelect,
    required this.onEdit,
    required this.onDeleted,
  });

  final String? selectedId;
  final ValueChanged<String?> onSelect;
  final ValueChanged<QuestionModel> onEdit;
  final ValueChanged<String> onDeleted;

  Future<void> _confirmDelete(BuildContext context, QuestionModel q) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('Supprimer cette question ?',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text('Cette action est définitive.',
            style: GoogleFonts.inter(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      MockStore.instance.deleteQuestion(q.id);
      onDeleted(q.id);
      AppSnackbar.success(context, 'Question supprimée.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = MockStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final test = store.selectedTest;
        final questions = store.selectedQuestions;
        final index = questions.indexWhere((q) => q.id == selectedId);
        final selected = index >= 0 ? questions[index] : null;

        return CustomCard(
          title: 'Questions du test',
          subtitle: test == null ? null : 'Test : ${test.title}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  CustomButton(
                    label: 'Modifier',
                    icon: Icons.edit_outlined,
                    compact: true,
                    variant: ButtonVariant.secondary,
                    onPressed: selected == null ? null : () => onEdit(selected),
                  ),
                  CustomButton(
                    label: 'Supprimer',
                    icon: Icons.delete_outline,
                    compact: true,
                    variant: ButtonVariant.secondary,
                    onPressed: selected == null
                        ? null
                        : () => _confirmDelete(context, selected),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (questions.isEmpty)
                const EmptyState(
                  icon: Icons.checklist_rounded,
                  title: 'Aucune question',
                  message: 'Les questions ajoutées apparaîtront ici.',
                )
              else
                for (var i = 0; i < questions.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _QuestionTile(
                    index: i,
                    question: questions[i],
                    selected: questions[i].id == selectedId,
                    onTap: () => onSelect(
                        questions[i].id == selectedId ? null : questions[i].id),
                  ),
                ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  CustomButton(
                    label: 'Monter',
                    icon: Icons.arrow_upward,
                    compact: true,
                    variant: ButtonVariant.secondary,
                    onPressed: (selected == null || index == 0)
                        ? null
                        : () => store.moveQuestion(selected.id, -1),
                  ),
                  CustomButton(
                    label: 'Descendre',
                    icon: Icons.arrow_downward,
                    compact: true,
                    variant: ButtonVariant.secondary,
                    onPressed: (selected == null || index == questions.length - 1)
                        ? null
                        : () => store.moveQuestion(selected.id, 1),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const InfoNote(
                  'Sélectionnez une question pour la modifier, la supprimer ou la réordonner.'),
            ],
          ),
        );
      },
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    required this.index,
    required this.question,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final QuestionModel question;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final points = question.points;
    return Material(
      color: selected ? AppColors.turquoiseLight : AppColors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: selected ? AppColors.turquoise : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ${question.text}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Réponse correcte : ${question.correctLabel} · $points pt${points > 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                    fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
