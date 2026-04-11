// ignore_for_file: avoid_print

import 'dart:io';

/// Dark Mode Audit Report Generator
/// Analyzes the entire codebase for dark mode compliance
void main(List<String> args) {
  print('🌙 Starting Afri-Commerce Dark Mode Audit...\n');

  const libPath = 'lib';
  final auditResults = <String, dynamic>{};

  // Run all audit checks
  auditResults['shadows'] = _auditShadows(libPath);
  auditResults['images'] = _auditImages(libPath);
  auditResults['overlays'] = _auditOverlays(libPath);
  auditResults['hardcodedColors'] = _auditHardcodedColors(libPath);
  auditResults['themeBrightness'] = _auditThemeBrightness(libPath);

  // Generate report
  _generateReport(auditResults);
}

/// Audit all shadow definitions for dark mode compatibility
Map<String, dynamic> _auditShadows(String libPath) {
  print('📍 Auditing shadows...');
  final issues = <String>[];
  final dir = Directory(libPath);

  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();

      // Check for hardcoded shadow colors without opacity adjustment
      if (content.contains('BoxShadow') && !content.contains('brightness')) {
        if (content.contains("color: Colors.black") ||
            content.contains('color: Color(0xFF000000)')) {
          issues.add(
            '⚠️  ${file.path}: Potential dark mode shadow issue - black shadow may not be visible in dark mode',
          );
        }
      }

      // Check for white overlays
      if (content.contains('color: Colors.white') &&
          content.contains('BoxShadow')) {
        issues.add(
          '⚠️  ${file.path}: White shadow detected - will be invisible in dark mode',
        );
      }
    }
  }

  final report = {
    'total': issues.length,
    'issues': issues,
    'status': issues.isEmpty ? '✅ PASS' : '⚠️  ISSUES FOUND',
  };

  print('  ${report['status']} - ${report['total']} items reviewed\n');
  return report;
}

/// Audit image usage for transparency issues in dark mode
Map<String, dynamic> _auditImages(String libPath) {
  print('📍 Auditing images...');
  final issues = <String>[];
  final dir = Directory(libPath);

  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();

      // Check for images without proper loading states
      if (content.contains('Image.network') ||
          content.contains('NetworkImageWithLoader')) {
        if (!content.contains('placeholder') && !content.contains('shimmer')) {
          issues.add(
            '⚠️  ${file.path}: Network image without placeholder - may show as white/blank in dark mode',
          );
        }
      }

      // Check for PNG images that might have transparency issues
      if (content.contains('.png')) {
        if (!content.contains('fit: BoxFit') ||
            !content.contains('BoxFit.contain')) {
          issues.add(
            '⚠️  ${file.path}: PNG image without proper fit - may have transparency display issues',
          );
        }
      }
    }
  }

  final report = {
    'total': issues.length,
    'issues': issues,
    'status': issues.isEmpty ? '✅ PASS' : '⚠️  REVIEW RECOMMENDED',
  };

  print('  ${report['status']} - ${report['total']} items reviewed\n');
  return report;
}

/// Audit modal and overlay colors for dark mode
Map<String, dynamic> _auditOverlays(String libPath) {
  print('📍 Auditing overlays...');
  final issues = <String>[];
  final dir = Directory(libPath);

  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();

      // Check for hardcoded overlay colors
      if (content.contains('barrierColor: Colors.black') ||
          content.contains("barrierColor: Color(0x00000000)")) {
        // This is fine - fully transparent
      } else if (content.contains('barrierColor') &&
          !content.contains('Theme.of(context)')) {
        issues.add(
          '⚠️  ${file.path}: hardcoded barrierColor - consider using Theme.of(context)',
        );
      }

      // Check for modal overlays without theme awareness
      if (content.contains('showDialog') ||
          content.contains('showBottomSheet')) {
        if (!content.contains('context') ||
            !content.contains('Theme.of(context)')) {
          issues.add(
            '⚠️  ${file.path}: Dialog/BottomSheet may not adapt to dark mode',
          );
        }
      }
    }
  }

  final report = {
    'total': issues.length,
    'issues': issues,
    'status': issues.isEmpty ? '✅ PASS' : '⚠️  REVIEW RECOMMENDED',
  };

  print('  ${report['status']} - ${report['total']} items reviewed\n');
  return report;
}

/// Audit for hardcoded color usage
Map<String, dynamic> _auditHardcodedColors(String libPath) {
  print('📍 Auditing hardcoded colors...');
  final issues = <String>[];
  final dir = Directory(libPath);
  final colorPattern = RegExp(
    r'color:\s*(?:Colors\.(?:white|black)|Color\(0xFF(?:FFFFFF|000000)\))',
  );

  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();
      var lineNum = 1;

      for (var line in content.split('\n')) {
        if (colorPattern.hasMatch(line) &&
            !line.contains('const') &&
            !line.contains('example') &&
            !line.contains('//')) {
          issues.add(
            '⚠️  ${file.path}:$lineNum: Hardcoded color - $line.trim()',
          );
        }
        lineNum++;
      }
    }
  }

  final report = {
    'total': issues.length,
    'issues': issues.take(10).toList(), // Limit to first 10 for readability
    'status': issues.isEmpty ? '✅ PASS' : '⚠️  ${issues.length} FOUND',
  };

  print('  ${report['status']} - ${report['total']} items reviewed\n');
  return report;
}

/// Audit for theme brightness awareness
Map<String, dynamic> _auditThemeBrightness(String libPath) {
  print('📍 Auditing theme brightness handling...');
  final issues = <String>[];
  final compliant = <String>[];
  final dir = Directory(libPath);

  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();

      // Files that should handle brightness
      if ((content.contains('Box') || content.contains('Shadow')) &&
          !content.contains('theme') &&
          !content.contains('AppColors') &&
          (file.path.contains('/components/') ||
              file.path.contains('/views/'))) {
        if (content.contains('Theme.of(context).brightness') ||
            content.contains('AppColors') ||
            content.contains('isDarkMode')) {
          compliant.add('✅ ${file.path}: Theme-aware');
        } else if (!file.path.contains('models') &&
            !file.path.contains('routes')) {
          issues.add('⚠️  ${file.path}: No theme brightness check detected');
        }
      }
    }
  }

  final report = {
    'compliant': compliant.length,
    'total': issues.length,
    'issues': issues.take(5).toList(),
    'status': issues.isEmpty ? '✅ PASS' : '⚠️  REVIEW RECOMMENDED',
  };

  print('  ${report['status']} - ${compliant.length} compliant files\n');
  return report;
}

/// Generate comprehensive audit report
void _generateReport(Map<String, dynamic> results) {
  print('\n${'=' * 70}');
  print('📊 DARK MODE AUDIT REPORT');
  print('=' * 70 + '\n');

  final totalIssues =
      (results['shadows']['total'] ?? 0) +
      (results['images']['total'] ?? 0) +
      (results['overlays']['total'] ?? 0) +
      (results['hardcodedColors']['total'] ?? 0) +
      (results['themeBrightness']['total'] ?? 0);

  print(
    'Overall Status: ${totalIssues == 0 ? "✅ COMPLIANT" : "⚠️  $totalIssues ISSUES FOUND"}\n',
  );

  // Shadows Report
  print('🌑 SHADOWS AUDIT');
  print('-' * 70);
  if (results['shadows']['issues'].isEmpty) {
    print('  ✅ All shadows appear compatible with dark mode\n');
  } else {
    for (var issue in results['shadows']['issues'].take(3)) {
      print('  $issue');
    }
    if (results['shadows']['issues'].length > 3) {
      print(
        '  ... and ${results['shadows']['issues'].length - 3} more issues\n',
      );
    }
  }

  // Images Report
  print('🖼️  IMAGES AUDIT');
  print('-' * 70);
  if (results['images']['issues'].isEmpty) {
    print('  ✅ All images have proper loading states\n');
  } else {
    for (var issue in results['images']['issues'].take(3)) {
      print('  $issue');
    }
    if (results['images']['issues'].length > 3) {
      print(
        '  ... and ${results['images']['issues'].length - 3} more issues\n',
      );
    }
  }

  // Overlays Report
  print('🎭 OVERLAYS AUDIT');
  print('-' * 70);
  if (results['overlays']['issues'].isEmpty) {
    print('  ✅ All overlays are theme-aware\n');
  } else {
    for (var issue in results['overlays']['issues'].take(3)) {
      print('  $issue');
    }
    if (results['overlays']['issues'].length > 3) {
      print(
        '  ... and ${results['overlays']['issues'].length - 3} more issues\n',
      );
    }
  }

  // Hardcoded Colors Report
  print('🎨 HARDCODED COLORS AUDIT');
  print('-' * 70);
  if (results['hardcodedColors']['issues'].isEmpty) {
    print('  ✅ No hardcoded white/black colors detected\n');
  } else {
    for (var issue in results['hardcodedColors']['issues'].take(3)) {
      print('  $issue');
    }
    if (results['hardcodedColors']['total'] > 3) {
      print(
        '  ... and ${results['hardcodedColors']['total'] - 3} more instances\n',
      );
    }
  }

  // Theme Brightness Report
  print('🌓 THEME BRIGHTNESS AUDIT');
  print('-' * 70);
  print(
    '  ✅ ${results['themeBrightness']['compliant']} theme-aware files found\n',
  );

  print('=' * 70);
  print('✨ Audit Complete!\n');

  print(
    '💡 RECOMMENDATIONS:\n'
    '1. Review all ⚠️  items above\n'
    '2. Test app in dark mode on Android/iOS/Web\n'
    '3. Verify shadows are visible with proper opacity\n'
    '4. Check image transparency on dark backgrounds\n'
    '5. Ensure all modals dim content appropriately\n',
  );
}
