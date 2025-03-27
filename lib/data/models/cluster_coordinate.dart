import 'package:barberdule/data/models/coordinate.dart';
import 'package:vexana/vexana.dart';

class ClusterCoordinate extends INetworkModel<ClusterCoordinate> {
  List<Coordinate> coordinates = [];

  ClusterCoordinate(this.coordinates);

  ClusterCoordinate.fromJson(Map<String, dynamic> json) {
    if (json['coordinates'] != null) {
      json['coordinates'].forEach((v) {
        final _list = v as List;
        coordinates.add(Coordinate(lat: _list.first, long: _list.last));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }

  @override
  ClusterCoordinate fromJson(Map<String, dynamic> json) =>
    ClusterCoordinate.fromJson(json);
}