import 'package:flutter/material.dart';

import '../../widgets/app_shell.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_row.dart';
import '../../navigation/app_router.dart';
import 'widgets/create_test_card.dart';
import 'widgets/manage_test_card.dart';

class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      currentRoute: AppRoutes.tests,
      pageLabel: 'Tests',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Gestion des tests',
            subtitle: 'Créez vos tests et gérez leur publication.',
          ),
          ResponsiveRow(
            flexes: [6, 5],
            children: [CreateTestCard(), ManageTestCard()],
          ),
        ],
      ),
    );
  }
}
