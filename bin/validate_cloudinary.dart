import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  print('=== Cloudinary Credentials Validation ===\n');

  // Load environment variables
  final cloudName = Platform.environment['CLOUDINARY_CLOUD_NAME']?.trim();
  final apiKey = Platform.environment['CLOUDINARY_API_KEY']?.trim();
  final apiSecret = Platform.environment['CLOUDINARY_API_SECRET']?.trim();

  // Check for missing variables
  print('Checking environment variables...');
  final List<String> missing = [];

  if (cloudName == null || cloudName.isEmpty) {
    missing.add('CLOUDINARY_CLOUD_NAME');
  } else {
    print('✓ CLOUDINARY_CLOUD_NAME = $cloudName');
  }

  if (apiKey == null || apiKey.isEmpty) {
    missing.add('CLOUDINARY_API_KEY');
  } else {
    print(
      '✓ CLOUDINARY_API_KEY = ${apiKey.substring(0, 3)}${'*' * (apiKey.length - 3)} (${apiKey.length} chars)',
    );
  }

  if (apiSecret == null || apiSecret.isEmpty) {
    missing.add('CLOUDINARY_API_SECRET');
  } else {
    print(
      '✓ CLOUDINARY_API_SECRET = ${apiSecret.substring(0, 3)}${'*' * (apiSecret.length - 3)} (${apiSecret.length} chars)',
    );
  }

  if (missing.isNotEmpty) {
    print('\n✗ Missing environment variables:');
    for (final m in missing) {
      print('  - $m');
    }
    stderr.writeln('\nFix: Source your .env file before running this script:');
    stderr.writeln(
      '  source .env.production && dart run bin/validate_cloudinary.dart',
    );
    exit(1);
  }

  final safeCloudName = cloudName!;
  final safeApiKey = apiKey!;
  final safeApiSecret = apiSecret!;

  print('\n✓ All environment variables present');

  // Check for whitespace issues
  print('\n--- Checking for whitespace issues ---');
  final rawKey = Platform.environment['CLOUDINARY_API_KEY'] ?? '';
  final rawSecret = Platform.environment['CLOUDINARY_API_SECRET'] ?? '';

  if (rawKey != safeApiKey) {
    print(
      '⚠ API_KEY has leading/trailing whitespace (${rawKey.length} vs ${safeApiKey.length} after trim)',
    );
  } else {
    print('✓ API_KEY has no whitespace issues');
  }

  if (rawSecret != safeApiSecret) {
    print(
      '⚠ API_SECRET has leading/trailing whitespace (${rawSecret.length} vs ${safeApiSecret.length} after trim)',
    );
  } else {
    print('✓ API_SECRET has no whitespace issues');
  }

  // Validate signature generation
  print('\n--- Testing Signature Generation ---');
  try {
    final testParams = <String, String>{
      'public_id': 'test_validation',
      'timestamp': '1234567890',
    };
    final signature = _generateSignature(testParams, safeApiSecret);
    print('✓ Signature generated successfully: $signature');
  } catch (e) {
    print('✗ Signature generation failed: $e');
    exit(1);
  }

  // Test actual upload attempt (what the sync script does)
  print('\n--- Testing with Actual Upload Method ---');
  await _testActualUpload(safeCloudName, safeApiKey, safeApiSecret);
}

String _generateSignature(Map<String, String> params, String apiSecret) {
  final sortedKeys = params.keys.toList()..sort();
  final joined = sortedKeys.map((key) => '$key=${params[key]}').join('&');
  final payload = '$joined$apiSecret';
  final digest = sha1.convert(utf8.encode(payload));
  return digest.toString();
}

Future<void> _testActualUpload(
  String cloudName,
  String apiKey,
  String apiSecret,
) async {
  try {
    // Create a minimal test image (1x1 pixel transparent PNG)
    final testImageBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    );

    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();

    final signatureParams = <String, String>{
      'public_id': 'test_validation',
      'timestamp': timestamp,
    };

    final signature = _generateSignature(signatureParams, apiSecret);

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    print('Uploading test image to: $uri');

    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp
      ..fields['signature'] = signature
      ..fields['public_id'] = 'test_validation'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          testImageBytes,
          filename: 'test.png',
        ),
      );

    final response = await request.send().timeout(const Duration(seconds: 10));
    final body = await response.stream.bytesToString();

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 401) {
      stderr.writeln('\n✗ Upload failed with 401 Unauthorized');
      stderr.writeln('Response body: $body');
      stderr.writeln('\nPossible causes:');
      stderr.writeln(
        '1. API key and secret do not match (not from same key pair)',
      );
      stderr.writeln(
        '2. Cloud name "$cloudName" does not match the API credentials',
      );
      stderr.writeln(
        '3. Credentials are disabled or expired in Cloudinary dashboard',
      );
      stderr.writeln('4. Trailing spaces or special characters in .env file');
      stderr.writeln('\nAction:');
      stderr.writeln('1. Log into Cloudinary dashboard and verify:');
      stderr.writeln(
        '   - API Key and API Secret are from the SAME row (same key pair)',
      );
      stderr.writeln('   - Status shows "Active"');
      stderr.writeln('   - Cloud name matches: $cloudName');
      stderr.writeln(
        '2. Generate a NEW API Key if current one is old/disabled',
      );
      stderr.writeln(
        '3. Copy exact values from dashboard (no copy-paste artifacts)',
      );
      exit(1);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✓ Upload successful (${response.statusCode})');
      print('✓ Credentials are valid and working!');
      final responseData = jsonDecode(body);
      print('Remote URL: ${responseData['secure_url']}');
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 422) {
      stderr.writeln('\n⚠ Validation error (${response.statusCode}): $body');
      stderr.writeln(
        'This usually means credentials are valid, but request format is wrong.',
      );
      exit(1);
    }

    stderr.writeln('\n⚠ Unexpected response status: ${response.statusCode}');
    stderr.writeln('Response body: $body');
    exit(1);
  } on SocketException catch (e) {
    stderr.writeln('\n✗ Network error: $e');
    stderr.writeln('Check your internet connection.');
    exit(1);
  } on TimeoutException catch (_) {
    stderr.writeln('\n✗ Request timeout after 10 seconds');
    stderr.writeln('Check your internet connection or Cloudinary status.');
    exit(1);
  } catch (e) {
    stderr.writeln('\n✗ Unexpected error: $e');
    exit(1);
  }
}
