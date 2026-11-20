import 'package:flutter/material.dart';

import '../../widgets/app_shell.dart';
import '../../widgets/page_header.dart';
import '../../widgets/stat_card.dart';
import '../../navigation/app_router.dart';
import '../../services/mock_store.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Les maquettes affichent « — » tant qu'il n'y a pas de données.
  static const String _empty = '—';

  @override
  Widget build(BuildContext context) {
    final store = MockStore.instance;

    return AppShell(
      currentRoute: AppRoutes.dashboard,
      pageLabel: 'Tableau de bord',
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final results = store.results;
          final rate = results.isEmpty
              ? _empty
              : '${(results.where((r) => r.passed).length * 100 / results.length).round()} %';

          final cards = [
            StatCard(
              label: 'Tests',
              icon: Icons.assignment_outlined,
              value: store.tests.isEmpty ? _empty : '${store.tests.length}',
            ),
            StatCard(
              label: 'Candidats',
              icon: Icons.group_outlined,
              value: store.invitations.isEmpty
                  ? _empty
                  : '${store.invitations.length}',
            ),
            StatCard(
              label: 'Taux de réussite',
              icon: Icons.check_circle_outline,
              value: rate,
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Tableau de bord'),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 700) {
                    return Column(
                      children: [
                        for (final c in cards) ...[c, const SizedBox(height: 16)],
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(child: cards[i]),
                      ],
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
