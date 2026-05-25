import 'package:flutter/material.dart';
import 'package:golden_test/golden_test.dart';

import '../golden_test_config.dart';

class _DeletePackDialogPreview extends StatelessWidget {
  final String packName;
  const _DeletePackDialogPreview({required this.packName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Delete pack',
        // Using a simple text because localization may vary in tests
      ),
      content: Text('Are you sure you want to delete "$packName"?'),
      actions: [
        TextButton(onPressed: () {}, child: const Text('Cancel')),
        TextButton(onPressed: () {}, child: const Text('Delete')),
      ],
    );
  }
}

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'delete_pack_dialog',
    subdirectory: 'home',
    builder: (_) => const _DeletePackDialogPreview(packName: 'Sample Pack'),
  );
}
