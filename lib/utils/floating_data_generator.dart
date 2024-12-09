// ignore_for_file: avoid_print

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/data_generator.dart';
import 'package:leak_guard/utils/strings.dart';

/// Provides UI components for data generation in the LeakGuard application.
///
/// Main Components:
/// 1. GenerateTestDataButton:
///    - A Neumorphic floating action button with progress dialog
///    - Shows real-time generation progress
///    - Handles errors and displays them via SnackBar
///
/// 2. Progress Dialog:
///    - Displays current operation status
///    - Shows progress bar and percentage
///    - Non-dismissible during data generation
///
/// Usage Examples:
///
/// 1. Basic usage with state refresh:
/// ```dart
/// floatingActionButton: GenerateTestDataButton(
///   onComplete: () => setState(() {}),
/// ),
/// ```
///
/// 2. Custom completion handling:
/// ```dart
/// floatingActionButton: GenerateTestDataButton(
///   onComplete: () {
///     setState(() {});
///     ScaffoldMessenger.of(context).showSnackBar(
///       SnackBar(content: Text('Data generation completed!')),
///     );
///   },
/// ),
/// ```
///
/// 3. Quick data generation without UI (not recommended for production):
/// ```dart
/// await generateTestData();
/// ```
///
/// Note: The button should be used within a Scaffold widget and requires
/// flutter_neumorphic_plus package for styling.

class GenerateTestDataButton extends StatelessWidget {
  final void Function()? onComplete;

  const GenerateTestDataButton({
    super.key,
    this.onComplete,
  });

  Future<void> generateData(BuildContext context) async {
    final progressDialogKey = GlobalKey<_ProgressDialogState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ProgressDialog(key: progressDialogKey),
    );

    try {
      await DataGenerator.generateTestData((status, progress) {
        print(
            'Progress update: $status - ${(progress * 100).toStringAsFixed(1)}%');
        if (context.mounted) {
          progressDialogKey.currentState?.updateProgress(status, progress);
        }
      });
    } catch (e, stackTrace) {
      print('Error during data generation: $e');
      print(stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating data: $e')),
        );
      }
    } finally {
      if (context.mounted) {
        // Navigator.of(context).pop();
        onComplete?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicFloatingActionButton(
      onPressed: () => generateData(context),
      child: const Icon(Icons.add),
    );
  }
}

class _ProgressDialog extends StatefulWidget {
  const _ProgressDialog({super.key});

  @override
  State<_ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<_ProgressDialog> {
  String _status = 'Initializing...';
  double _progress = 0;

  void updateProgress(String status, double progress) {
    if (mounted) {
      setState(() {
        _status = status;
        _progress = progress;
      });
    }
  }

  Widget _closeButton() {
    if (_status == MyStrings.dataGenerationCompleted) {
      return NeumorphicButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Close'),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generating test data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _progress),
          const SizedBox(height: 16),
          Text(
            _status,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${(_progress * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _closeButton(),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper function for quick data generation without UI
Future<void> generateTestData() async {
  await DataGenerator.generateTestData((_, __) {});
}
