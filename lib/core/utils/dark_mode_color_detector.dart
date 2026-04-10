import 'dart:io';

import 'package:flutter/foundation.dart';

/// Detects hardcoded Colors.white/Colors.black for dark mode issues
class DarkModeColorDetector {
  /// Analyzes lib folder and returns all hardcoded color instances
  static Future<DarkModeReport> analyzeProject(String libPath) async {
    final directory = Directory(libPath);
    final report = DarkModeReport();

    if (!directory.existsSync()) {
      report.addError('Library path not found: $libPath');
      return report;
    }

    await _scanDirectory(directory, report);
    return report;
  }

  static Future<void> _scanDirectory(
    Directory dir,
    DarkModeReport report,
  ) async {
    try {
      final entities = dir.listSync();
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          _scanFile(entity, report);
        } else if (entity is Directory && !entity.path.contains('.')) {
          await _scanDirectory(entity, report);
        }
      }
    } catch (e) {
      // Skip directories with permission issues
    }
  }

  static void _scanFile(File file, DarkModeReport report) {
    try {
      final lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];

        // Detect Colors.white
        if (line.contains('Colors.white') && !_isCommented(line)) {
          report.addWhiteInstance(
            file: file.path,
            lineNumber: i + 1,
            snippet: line.trim(),
          );
        }

        // Detect Colors.black
        if (line.contains('Colors.black') && !_isCommented(line)) {
          report.addBlackInstance(
            file: file.path,
            lineNumber: i + 1,
            snippet: line.trim(),
          );
        }
      }
    } catch (e) {
      // Skip unreadable files
    }
  }

  static bool _isCommented(String line) {
    final trimmed = line.trim();
    return trimmed.startsWith('//') || trimmed.startsWith('/*');
  }
}

// ========== REPORT CLASS ==========
class DarkModeReport {
  final List<ColorInstance> whiteInstances = [];
  final List<ColorInstance> blackInstances = [];
  final List<String> errors = [];

  void addWhiteInstance({
    required String file,
    required int lineNumber,
    required String snippet,
  }) {
    whiteInstances.add(
      ColorInstance(file: file, lineNumber: lineNumber, snippet: snippet),
    );
  }

  void addBlackInstance({
    required String file,
    required int lineNumber,
    required String snippet,
  }) {
    blackInstances.add(
      ColorInstance(file: file, lineNumber: lineNumber, snippet: snippet),
    );
  }

  void addError(String error) => errors.add(error);

  int get totalIssues => whiteInstances.length + blackInstances.length;

  String generateMarkdownReport() {
    final sb = StringBuffer();

    sb.writeln('# Dark Mode Hardcoded Color Report\n');
    sb.writeln('**Total Issues Found:** $totalIssues\n');

    // White instances
    if (whiteInstances.isNotEmpty) {
      sb.writeln('## Colors.white Issues (${whiteInstances.length})\n');
      for (final instance in whiteInstances) {
        sb.writeln(
          '- **${instance.file.split('/').last}** (Line ${instance.lineNumber})',
        );
        sb.writeln('  ```\n  ${instance.snippet}\n  ```');
        sb.writeln(
          '  ✨ **Fix:** Replace with `AppColors.onPrimaryLight` or use `Theme.of(context).colorScheme.onSurface`\n',
        );
      }
    }

    // Black instances
    if (blackInstances.isNotEmpty) {
      sb.writeln('## Colors.black Issues (${blackInstances.length})\n');
      for (final instance in blackInstances) {
        sb.writeln(
          '- **${instance.file.split('/').last}** (Line ${instance.lineNumber})',
        );
        sb.writeln('  ```\n  ${instance.snippet}\n  ```');
        sb.writeln(
          '  ✨ **Fix:** Replace with `AppColors.onBackgroundLight` or use `Theme.of(context).colorScheme.onBackground`\n',
        );
      }
    }

    sb.writeln('\n## Fix Guidance\n');
    sb.writeln('### For Text Colors:\n');
    sb.writeln('- **Light Mode:** `AppColors.onBackgroundLight`\n');
    sb.writeln('- **Dark Mode:** `AppColors.onBackgroundDark`\n');
    sb.writeln(
      '- **Theme Aware:** `Theme.of(context).colorScheme.onBackground`\n',
    );

    sb.writeln('### For Vector/Icon Colors:\n');
    sb.writeln('- **Light Mode:** `AppColors.onSurfaceLight`\n');
    sb.writeln('- **Dark Mode:** `AppColors.onSurfaceDark`\n');
    sb.writeln(
      '- **Theme Aware:** `Theme.of(context).colorScheme.onSurface`\n',
    );

    return sb.toString();
  }

  @override
  String toString() =>
      'DarkModeReport(total: $totalIssues, white: ${whiteInstances.length}, black: ${blackInstances.length})';
}

class ColorInstance {
  final String file;
  final int lineNumber;
  final String snippet;

  ColorInstance({
    required this.file,
    required this.lineNumber,
    required this.snippet,
  });
}

// ========== MAIN FUNCTION FOR TESTING ==========
Future<void> main(List<String> args) async {
  final libPath = args.isNotEmpty ? args[0] : 'lib';

  debugPrint('🔍 Analyzing $libPath for hardcoded dark mode colors...\n');

  final report = await DarkModeColorDetector.analyzeProject(libPath);

  if (report.errors.isNotEmpty) {
    debugPrint('⚠️ Errors encountered:');
    for (final error in report.errors) {
      debugPrint('  - $error');
    }
    debugPrint('');
  }

  if (report.totalIssues == 0) {
    // ✅ No hardcoded Colors.white or Colors.black found!
  } else {
    // 📊 Summary generated in report
  }
}
