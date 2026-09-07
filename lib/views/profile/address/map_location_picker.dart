import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/config/env_config.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/map_location.dart';
import '../../../core/utils/logger.dart';
import '../../../core/components/app_back_button.dart';

const _nairobiLat = -1.2921;
const _nairobiLng = 36.8219;

class MapLocationPicker extends ConsumerStatefulWidget {
  const MapLocationPicker({super.key});

  @override
  ConsumerState<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends ConsumerState<MapLocationPicker> {
  GoogleMapController? _mapController;
  LatLng _selectedLatLng = const LatLng(_nairobiLat, _nairobiLng);
  String _selectedAddress = '';
  bool _isLoadingAddress = false;
  bool _isMovingPin = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updateAddress(_selectedLatLng);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _updateAddress(_selectedLatLng);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _updateAddress(_selectedLatLng);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _selectedLatLng = latLng);
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
      _updateAddress(latLng);
    } catch (e) {
      Logger.error('Failed to get location: $e', 'MapLocationPicker');
      _updateAddress(_selectedLatLng);
    }
  }

  Future<void> _updateAddress(LatLng latLng) async {
    setState(() => _isLoadingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isEmpty) {
        setState(() {
          _selectedAddress =
              '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
          _isLoadingAddress = false;
        });
        return;
      }
      final place = placemarks.first;
      final parts = <String>[];
      if (place.street != null && place.street!.isNotEmpty)
        parts.add(place.street!);
      if (place.name != null && place.name!.isNotEmpty) parts.add(place.name!);
      if (place.locality != null && place.locality!.isNotEmpty)
        parts.add(place.locality!);
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty)
        parts.add(place.administrativeArea!);
      if (place.postalCode != null && place.postalCode!.isNotEmpty)
        parts.add(place.postalCode!);
      if (place.country != null && place.country!.isNotEmpty)
        parts.add(place.country!);
      final address = parts.join(', ');
      if (!mounted) return;
      setState(() {
        _selectedAddress = address.isNotEmpty
            ? address
            : '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
        _isLoadingAddress = false;
      });
    } catch (e) {
      Logger.error('Reverse geocoding failed: $e', 'MapLocationPicker');
      if (!mounted) return;
      setState(() {
        _selectedAddress =
            '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    final apiKey = EnvConfig.googleMapsApiKey();
    if (apiKey.isEmpty) {
      Logger.warning('Google Maps API key not found', 'MapLocationPicker');
      return;
    }
    setState(() => _isSearching = true);
    try {
      final uri = Uri.https(
          'maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': query,
        'key': apiKey,
        'components': 'country:ke',
      });
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK') {
          setState(() => _searchResults = json['predictions']);
        } else {
          setState(() => _searchResults = []);
        }
      }
    } catch (e) {
      Logger.error('Place search failed: $e', 'MapLocationPicker');
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _selectPlace(String placeId) async {
    final apiKey = EnvConfig.googleMapsApiKey();
    if (apiKey.isEmpty) return;
    try {
      final uri =
          Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
        'place_id': placeId,
        'key': apiKey,
        'fields': 'geometry',
      });
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = json['result'] ?? {};
        final location = result['geometry']?['location'];
        if (location != null) {
          final latLng = LatLng(
            (location['lat'] as num).toDouble(),
            (location['lng'] as num).toDouble(),
          );
          setState(() => _selectedLatLng = latLng);
          _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
          _updateAddress(latLng);
        }
      }
    } catch (e) {
      Logger.error('Place details fetch failed: $e', 'MapLocationPicker');
    }
    setState(() {
      _searchResults = [];
      _searchController.clear();
    });
  }

  Future<void> _useCurrentLocation() async {
    await _determinePosition();
  }

  MapLocation _buildResult() {
    final placemarks =
        _selectedAddress.split(',').map((e) => e.trim()).toList();
    return MapLocation(
      latitude: _selectedLatLng.latitude,
      longitude: _selectedLatLng.longitude,
      street: placemarks.isNotEmpty ? placemarks[0] : null,
      city: placemarks.length > 2 ? placemarks[placemarks.length - 3] : null,
      state: placemarks.length > 1 ? placemarks[placemarks.length - 2] : null,
      zipCode: _extractZip(placemarks.last),
      country: placemarks.last,
      formattedAddress: _selectedAddress,
    );
  }

  String? _extractZip(String lastPart) {
    final match = RegExp(r'\b\d{5}\b').firstMatch(lastPart);
    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.pickLocationOnMap),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _selectedLatLng, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              if (!_isMovingPin) {
                setState(() {
                  _isMovingPin = true;
                  _selectedLatLng = position.target;
                });
              }
            },
            onCameraIdle: () {
              setState(() {
                _isMovingPin = false;
              });
              _updateAddress(_selectedLatLng);
            },
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),
          const Center(
            child: Icon(Icons.location_on, size: 48, color: AppColors.primary),
          ),
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Column(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchAddress,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null,
                    ),
                    onChanged: _searchPlaces,
                  ),
                ),
                if (_isSearching) const LinearProgressIndicator(minHeight: 2),
                if (_searchResults.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    color: Theme.of(context).colorScheme.surface,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final prediction = _searchResults[index];
                        final description =
                            prediction['description'] as String? ?? '';
                        return ListTile(
                          dense: true,
                          title: Text(description),
                          onTap: () =>
                              _selectPlace(prediction['place_id'] as String),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: _useCurrentLocation,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppDefaults.padding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dragToAdjust,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: AppDefaults.borderRadius,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _isLoadingAddress
                              ? const SizedBox(
                                  height: 16,
                                  child: LinearProgressIndicator(minHeight: 2),
                                )
                              : Text(
                                  _selectedAddress.isEmpty
                                      ? l10n.searchAddress
                                      : _selectedAddress,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedAddress.isEmpty
                          ? null
                          : () {
                              final result = _buildResult();
                              Navigator.pop(context, result);
                            },
                      child: Text(l10n.useThisLocation),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
