import 'package:latlong2/latlong.dart';

class FieldOperationModel {
  final String title;
  final String location;
  final String team;
  final String time;
  final String type;
  final LatLng? coordinates;

  FieldOperationModel({
    required this.title,
    required this.location,
    required this.team,
    required this.time,
    required this.type,
    this.coordinates,
  });
}
