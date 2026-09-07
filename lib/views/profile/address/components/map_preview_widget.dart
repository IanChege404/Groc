import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_defaults.dart';

class MapPreviewWidget extends StatelessWidget {
  const MapPreviewWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.height = 120,
  });

  final double? latitude;
  final double? longitude;
  final String? formattedAddress;
  final double height;

  bool get hasLocation => latitude != null && longitude != null;

  String? get _staticMapUrl {
    if (!hasLocation) return null;
    final apiKey = EnvConfig.googleMapsApiKey();
    if (apiKey.isEmpty) return null;
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$latitude,$longitude'
        '&zoom=15'
        '&size=600x${(height * 2).toInt()}'
        '&maptype=roadmap'
        '&markers=color:red%7C$latitude,$longitude'
        '&key=$apiKey';
  }

  @override
  Widget build(BuildContext context) {
    if (!hasLocation) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: AppDefaults.borderRadius,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 32, color: AppColors.placeholder),
              const SizedBox(height: 4),
              Text(
                'No location set',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    final staticUrl = _staticMapUrl;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppDefaults.borderRadius,
      ),
      child: ClipRRect(
        borderRadius: AppDefaults.borderRadius,
        child: staticUrl != null
            ? CachedNetworkImage(
                imageUrl: staticUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceLight,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => _PlaceholderMap(
                  latitude: latitude!,
                  longitude: longitude!,
                  formattedAddress: formattedAddress,
                ),
              )
            : _PlaceholderMap(
                latitude: latitude!,
                longitude: longitude!,
                formattedAddress: formattedAddress,
              ),
      ),
    );
  }
}

class _PlaceholderMap extends StatelessWidget {
  const _PlaceholderMap({
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
  });

  final double latitude;
  final double longitude;
  final String? formattedAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 36, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (formattedAddress != null && formattedAddress!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  formattedAddress!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
