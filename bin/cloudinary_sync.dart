import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  final config = _Config.fromArgs(args);

  if (config.showHelp) {
    _printUsage();
    exit(0);
  }

  final cloudName = Platform.environment['CLOUDINARY_CLOUD_NAME']?.trim();
  final apiKey = Platform.environment['CLOUDINARY_API_KEY']?.trim();
  final apiSecret = Platform.environment['CLOUDINARY_API_SECRET']?.trim();

  if (cloudName == null || apiKey == null || apiSecret == null) {
    stderr.writeln('Missing Cloudinary environment variables:');
    stderr.writeln('- CLOUDINARY_CLOUD_NAME');
    stderr.writeln('- CLOUDINARY_API_KEY');
    stderr.writeln('- CLOUDINARY_API_SECRET');
    exit(2);
  }

  final assetsDir = Directory(config.assetsDir);
  if (!assetsDir.existsSync()) {
    stderr.writeln('Assets directory not found: ${config.assetsDir}');
    exit(2);
  }

  final uploader = _CloudinaryUploader(
    cloudName: cloudName,
    apiKey: apiKey,
    apiSecret: apiSecret,
    folder: config.folder,
    overwrite: config.overwrite,
    dryRun: config.dryRun,
  );

  final existingMap = _loadMap(config.mapFilePath);
  final existingByPath = {
    for (final item in existingMap.entries) item.localPath: item,
  };

  final files = _discoverImageFiles(assetsDir, config.assetsDir)
    ..sort((a, b) => a.localPath.compareTo(b.localPath));

  if (files.isEmpty) {
    stdout.writeln('No image files found under ${config.assetsDir}.');
    exit(0);
  }

  stdout.writeln('Found ${files.length} local images in ${config.assetsDir}.');

  final uploadedEntries = <_AssetMapEntry>[];
  var uploadedCount = 0;
  var reusedCount = 0;

  for (final image in files) {
    final previous = existingByPath[image.localPath];
    final fileStat = File(image.localPath).statSync();
    final sizeChanged = previous != null && previous.sizeBytes != fileStat.size;
    final mtimeChanged =
        previous != null &&
        previous.modifiedAt != fileStat.modified.toUtc().toIso8601String();

    final shouldUpload =
        previous == null || config.overwrite || sizeChanged || mtimeChanged;

    if (!shouldUpload && previous != null) {
      reusedCount++;
      uploadedEntries.add(previous);
      stdout.writeln('Reuse: ${image.localPath} -> ${previous.secureUrl}');
      continue;
    }

    final result = await uploader.upload(image);
    uploadedCount++;
    uploadedEntries.add(
      _AssetMapEntry(
        localPath: image.localPath,
        relativePath: image.relativePath,
        fileName: p.basename(image.localPath),
        publicId: result.publicId,
        secureUrl: result.secureUrl,
        sizeBytes: fileStat.size,
        modifiedAt: fileStat.modified.toUtc().toIso8601String(),
      ),
    );
    stdout.writeln('Upload: ${image.localPath} -> ${result.secureUrl}');
  }

  final mapPayload = _CloudinaryMap(
    generatedAt: DateTime.now().toUtc().toIso8601String(),
    cloudName: cloudName,
    folder: config.folder,
    entries: uploadedEntries,
  );

  _saveMap(config.mapFilePath, mapPayload);

  stdout.writeln('');
  stdout.writeln('Sync complete');
  stdout.writeln('- Uploaded: $uploadedCount');
  stdout.writeln('- Reused: $reusedCount');
  stdout.writeln('- Map file: ${config.mapFilePath}');

  if (config.applyRewrites) {
    final rewriteTargets = _resolveRewriteTargets(config);
    final changes = _applyRewrites(
      targets: rewriteTargets,
      entries: uploadedEntries,
      rewriteRemoteByBasename: config.rewriteRemoteByBasename,
      dryRun: config.dryRun,
    );

    stdout.writeln('');
    stdout.writeln('Rewrite mode: ${config.dryRun ? 'dry-run' : 'apply'}');
    if (changes.isEmpty) {
      stdout.writeln('- No target file changes.');
    } else {
      for (final change in changes) {
        stdout.writeln('- ${change.path}: ${change.replacements} replacements');
      }
    }
  }
}

class _Config {
  final String assetsDir;
  final String folder;
  final bool overwrite;
  final bool dryRun;
  final bool applyRewrites;
  final bool rewriteRemoteByBasename;
  final bool includeViewTargets;
  final String mapFilePath;
  final List<String> targets;
  final bool showHelp;

  const _Config({
    required this.assetsDir,
    required this.folder,
    required this.overwrite,
    required this.dryRun,
    required this.applyRewrites,
    required this.rewriteRemoteByBasename,
    required this.includeViewTargets,
    required this.mapFilePath,
    required this.targets,
    required this.showHelp,
  });

  factory _Config.fromArgs(List<String> args) {
    final defaults = _Config(
      assetsDir: 'assets/images',
      folder:
          Platform.environment['CLOUDINARY_FOLDER']?.trim().isNotEmpty == true
          ? Platform.environment['CLOUDINARY_FOLDER']!.trim()
          : 'pro-grocery',
      overwrite: _envBool('CLOUDINARY_OVERWRITE', fallback: false),
      dryRun: _envBool('DRY_RUN', fallback: false),
      applyRewrites: false,
      rewriteRemoteByBasename: false,
      includeViewTargets: false,
      mapFilePath: '.cloudinary-map.json',
      targets: const [
        'lib/core/constants/app_images.dart',
        'lib/core/constants/dummy_data.dart',
        'dataconnect/seed_data.gql',
      ],
      showHelp: false,
    );

    var config = defaults;

    for (final arg in args) {
      if (arg == '--help' || arg == '-h') {
        config = config._copy(showHelp: true);
      } else if (arg == '--dry-run') {
        config = config._copy(dryRun: true);
      } else if (arg == '--overwrite') {
        config = config._copy(overwrite: true);
      } else if (arg == '--apply') {
        config = config._copy(applyRewrites: true);
      } else if (arg == '--rewrite-remote-by-basename') {
        config = config._copy(rewriteRemoteByBasename: true);
      } else if (arg == '--include-view-targets') {
        config = config._copy(includeViewTargets: true);
      } else if (arg.startsWith('--assets-dir=')) {
        config = config._copy(assetsDir: arg.split('=').sublist(1).join('='));
      } else if (arg.startsWith('--folder=')) {
        config = config._copy(folder: arg.split('=').sublist(1).join('='));
      } else if (arg.startsWith('--map-file=')) {
        config = config._copy(mapFilePath: arg.split('=').sublist(1).join('='));
      } else if (arg.startsWith('--targets=')) {
        final value = arg.split('=').sublist(1).join('=');
        final parsedTargets = value
            .split(',')
            .map((path) => path.trim())
            .where((path) => path.isNotEmpty)
            .toList();
        config = config._copy(targets: parsedTargets);
      } else {
        stderr.writeln('Unknown argument: $arg');
        _printUsage();
        exit(2);
      }
    }

    return config;
  }

  _Config _copy({
    String? assetsDir,
    String? folder,
    bool? overwrite,
    bool? dryRun,
    bool? applyRewrites,
    bool? rewriteRemoteByBasename,
    bool? includeViewTargets,
    String? mapFilePath,
    List<String>? targets,
    bool? showHelp,
  }) {
    return _Config(
      assetsDir: assetsDir ?? this.assetsDir,
      folder: folder ?? this.folder,
      overwrite: overwrite ?? this.overwrite,
      dryRun: dryRun ?? this.dryRun,
      applyRewrites: applyRewrites ?? this.applyRewrites,
      rewriteRemoteByBasename:
          rewriteRemoteByBasename ?? this.rewriteRemoteByBasename,
      includeViewTargets: includeViewTargets ?? this.includeViewTargets,
      mapFilePath: mapFilePath ?? this.mapFilePath,
      targets: targets ?? this.targets,
      showHelp: showHelp ?? this.showHelp,
    );
  }
}

class _ImageAsset {
  final String localPath;
  final String relativePath;

  const _ImageAsset({required this.localPath, required this.relativePath});
}

class _UploadResult {
  final String publicId;
  final String secureUrl;

  const _UploadResult({required this.publicId, required this.secureUrl});
}

class _CloudinaryUploader {
  final String cloudName;
  final String apiKey;
  final String apiSecret;
  final String folder;
  final bool overwrite;
  final bool dryRun;

  const _CloudinaryUploader({
    required this.cloudName,
    required this.apiKey,
    required this.apiSecret,
    required this.folder,
    required this.overwrite,
    required this.dryRun,
  });

  Future<_UploadResult> upload(_ImageAsset image) async {
    final publicId = _publicIdFor(image.relativePath);
    final normalizedFolder = folder.trim();

    if (dryRun) {
      final dryRunPath = normalizedFolder.isEmpty
          ? publicId
          : '$normalizedFolder/$publicId';
      return _UploadResult(
        publicId: publicId,
        secureUrl:
            'https://res.cloudinary.com/$cloudName/image/upload/$dryRunPath',
      );
    }

    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();
    final overwriteParam = overwrite ? 'true' : 'false';

    final signatureParams = <String, String>{
      'overwrite': overwriteParam,
      'public_id': publicId,
      'timestamp': timestamp,
    };
    if (normalizedFolder.isNotEmpty) {
      signatureParams['folder'] = normalizedFolder;
    }

    final signature = _cloudinarySignature(signatureParams, apiSecret);

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp
      ..fields['signature'] = signature
      ..fields['public_id'] = publicId
      ..fields['overwrite'] = overwriteParam
      ..files.add(await http.MultipartFile.fromPath('file', image.localPath));

    if (normalizedFolder.isNotEmpty) {
      request.fields['folder'] = normalizedFolder;
    }

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      if (streamed.statusCode == 401) {
        throw Exception(
          'Cloudinary upload failed (401): $body\n'
          'Tip: verify CLOUDINARY_API_KEY/CLOUDINARY_API_SECRET exactly (common issue: letter I vs number 1), and ensure no trailing spaces/newlines in .env values.',
        );
      }
      throw Exception(
        'Cloudinary upload failed (${streamed.statusCode}): $body',
      );
    }

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = decoded['secure_url'] as String?;
    final resolvedPublicId = decoded['public_id'] as String?;

    if (secureUrl == null || resolvedPublicId == null) {
      throw Exception(
        'Cloudinary response missing secure_url/public_id: $body',
      );
    }

    return _UploadResult(publicId: resolvedPublicId, secureUrl: secureUrl);
  }
}

class _AssetMapEntry {
  final String localPath;
  final String relativePath;
  final String fileName;
  final String publicId;
  final String secureUrl;
  final int sizeBytes;
  final String modifiedAt;

  const _AssetMapEntry({
    required this.localPath,
    required this.relativePath,
    required this.fileName,
    required this.publicId,
    required this.secureUrl,
    required this.sizeBytes,
    required this.modifiedAt,
  });

  factory _AssetMapEntry.fromJson(Map<String, dynamic> json) {
    return _AssetMapEntry(
      localPath: json['localPath'] as String,
      relativePath: json['relativePath'] as String,
      fileName: json['fileName'] as String,
      publicId: json['publicId'] as String,
      secureUrl: json['secureUrl'] as String,
      sizeBytes: json['sizeBytes'] as int,
      modifiedAt: json['modifiedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localPath': localPath,
      'relativePath': relativePath,
      'fileName': fileName,
      'publicId': publicId,
      'secureUrl': secureUrl,
      'sizeBytes': sizeBytes,
      'modifiedAt': modifiedAt,
    };
  }
}

class _CloudinaryMap {
  final String generatedAt;
  final String cloudName;
  final String folder;
  final List<_AssetMapEntry> entries;

  const _CloudinaryMap({
    required this.generatedAt,
    required this.cloudName,
    required this.folder,
    required this.entries,
  });

  factory _CloudinaryMap.fromJson(Map<String, dynamic> json) {
    final rawEntries = (json['entries'] as List<dynamic>? ?? const []);
    return _CloudinaryMap(
      generatedAt: json['generatedAt'] as String? ?? '',
      cloudName: json['cloudName'] as String? ?? '',
      folder: json['folder'] as String? ?? '',
      entries: rawEntries
          .map((item) => _AssetMapEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generatedAt': generatedAt,
      'cloudName': cloudName,
      'folder': folder,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }
}

class _RewriteChange {
  final String path;
  final int replacements;

  const _RewriteChange({required this.path, required this.replacements});
}

List<_RewriteChange> _applyRewrites({
  required List<String> targets,
  required List<_AssetMapEntry> entries,
  required bool rewriteRemoteByBasename,
  required bool dryRun,
}) {
  final changes = <_RewriteChange>[];

  final localPathMap = {
    for (final entry in entries)
      entry.localPath.replaceAll('\\', '/'): entry.secureUrl,
  };

  final basenameCandidates = <String, List<String>>{};
  for (final entry in entries) {
    final name = entry.fileName.toLowerCase();
    basenameCandidates.putIfAbsent(name, () => <String>[]).add(entry.secureUrl);
  }

  final urlRegex = RegExp(r'''https?://[^\s\)\]"']+''');

  for (final target in targets) {
    final file = File(target);
    if (!file.existsSync()) {
      continue;
    }

    final original = file.readAsStringSync();
    var updated = original;
    var replacementCount = 0;

    for (final item in localPathMap.entries) {
      final before = updated;
      updated = updated.replaceAll(item.key, item.value);
      if (updated != before) {
        replacementCount++;
      }
    }

    if (rewriteRemoteByBasename) {
      final matches = urlRegex.allMatches(updated).toList();
      for (final match in matches) {
        final url = match.group(0)!;
        final uri = Uri.tryParse(url);
        if (uri == null) continue;

        final fileName = p.basename(uri.path).toLowerCase();
        if (fileName.isEmpty) continue;

        final candidates = basenameCandidates[fileName];
        if (candidates == null || candidates.length != 1) continue;

        final replacement = candidates.first;
        if (url != replacement) {
          updated = updated.replaceAll(url, replacement);
          replacementCount++;
        }
      }
    }

    if (replacementCount > 0) {
      if (!dryRun) {
        file.writeAsStringSync(updated);
      }
      changes.add(_RewriteChange(path: target, replacements: replacementCount));
    }
  }

  return changes;
}

List<String> _resolveRewriteTargets(_Config config) {
  final targetSet = <String>{...config.targets};

  if (!config.includeViewTargets) {
    return targetSet.toList()..sort();
  }

  final viewsDir = Directory('lib/views');
  if (viewsDir.existsSync()) {
    for (final entity in viewsDir.listSync(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;
      targetSet.add(entity.path.replaceAll('\\', '/'));
    }
  }

  final extraTargets = [
    'lib/core/routes/unknown_page.dart',
    'lib/core/constants/app_images.dart',
    'lib/core/constants/dummy_data.dart',
    'dataconnect/seed_data.gql',
  ];

  for (final target in extraTargets) {
    if (File(target).existsSync()) {
      targetSet.add(target);
    }
  }

  return targetSet.toList()..sort();
}

List<_ImageAsset> _discoverImageFiles(Directory rootDir, String rootPath) {
  const allowedExt = {'.png', '.jpg', '.jpeg', '.webp', '.gif', '.svg'};

  final entries = <_ImageAsset>[];

  for (final entity in rootDir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;

    final ext = p.extension(entity.path).toLowerCase();
    if (!allowedExt.contains(ext)) continue;

    final normalizedFull = entity.path.replaceAll('\\', '/');
    final normalizedRoot = rootPath.replaceAll('\\', '/');
    final relativeFromRoot = p
        .relative(normalizedFull, from: normalizedRoot)
        .replaceAll('\\', '/');

    entries.add(
      _ImageAsset(localPath: normalizedFull, relativePath: relativeFromRoot),
    );
  }

  return entries;
}

_CloudinaryMap _loadMap(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return const _CloudinaryMap(
      generatedAt: '',
      cloudName: '',
      folder: '',
      entries: [],
    );
  }

  final raw = file.readAsStringSync();
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  return _CloudinaryMap.fromJson(decoded);
}

void _saveMap(String path, _CloudinaryMap map) {
  final file = File(path);
  file.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(map.toJson()),
  );
}

String _publicIdFor(String relativePath) {
  final noExt = p.withoutExtension(relativePath).replaceAll('\\', '/');
  final sanitized = noExt
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'[^a-zA-Z0-9_\-/]'), '')
      .replaceAll(RegExp(r'/+'), '/');

  return sanitized;
}

String _cloudinarySignature(Map<String, String> params, String apiSecret) {
  final sortedKeys = params.keys.toList()..sort();
  final joined = sortedKeys.map((key) => '$key=${params[key]}').join('&');
  final payload = '$joined$apiSecret';

  final digest = sha1.convert(utf8.encode(payload));
  return digest.toString();
}

bool _envBool(String key, {required bool fallback}) {
  final raw = Platform.environment[key]?.trim().toLowerCase();
  if (raw == null || raw.isEmpty) return fallback;
  return raw == '1' || raw == 'true' || raw == 'yes' || raw == 'y';
}

void _printUsage() {
  stdout.writeln('Cloudinary sync utility');
  stdout.writeln('');
  stdout.writeln('Required env vars:');
  stdout.writeln('  CLOUDINARY_CLOUD_NAME');
  stdout.writeln('  CLOUDINARY_API_KEY');
  stdout.writeln('  CLOUDINARY_API_SECRET');
  stdout.writeln('');
  stdout.writeln('Optional env vars:');
  stdout.writeln('  CLOUDINARY_FOLDER      (default: pro-grocery)');
  stdout.writeln('  CLOUDINARY_OVERWRITE   (default: false)');
  stdout.writeln('  DRY_RUN                (default: false)');
  stdout.writeln('');
  stdout.writeln('Usage:');
  stdout.writeln('  dart run bin/cloudinary_sync.dart [options]');
  stdout.writeln('');
  stdout.writeln('Options:');
  stdout.writeln('  --assets-dir=<path>                Default: assets/images');
  stdout.writeln('  --folder=<folder>                  Cloudinary folder name');
  stdout.writeln(
    '  --map-file=<path>                  Default: .cloudinary-map.json',
  );
  stdout.writeln(
    '  --overwrite                        Force upload even if unchanged',
  );
  stdout.writeln('  --dry-run                          Print actions only');
  stdout.writeln(
    '  --apply                            Apply rewrites to target files',
  );
  stdout.writeln('  --targets=<csv paths>              Rewrite targets');
  stdout.writeln(
    '  --include-view-targets             Also rewrite all lib/views/**/*.dart',
  );
  stdout.writeln(
    '  --rewrite-remote-by-basename       Replace remote URLs by filename match',
  );
  stdout.writeln('  --help, -h                         Show this help');
}
