class MapLocation {
  final double latitude;
  final double longitude;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String formattedAddress;

  const MapLocation({
    required this.latitude,
    required this.longitude,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    required this.formattedAddress,
  });
}
