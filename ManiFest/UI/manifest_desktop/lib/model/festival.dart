import 'package:json_annotation/json_annotation.dart';

part 'festival.g.dart';

@JsonSerializable()
class Festival {
  final int id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final double basePrice;
  final String? location;
  final bool isActive;
  final int cityId;
  final String cityName;
  final int subcategoryId;
  final String subcategoryName;
  final int organizerId;
  final String organizerName;
  final List<dynamic> assets;

  const Festival({
    this.id = 0,
    this.title = '',
    required this.startDate,
    required this.endDate,
    this.basePrice = 0.0,
    this.location,
    this.isActive = true,
    this.cityId = 0,
    this.cityName = '',
    this.subcategoryId = 0,
    this.subcategoryName = '',
    this.organizerId = 0,
    this.organizerName = '',
    this.assets = const [],
  });

  factory Festival.fromJson(Map<String, dynamic> json) =>
      _$FestivalFromJson(json);
  Map<String, dynamic> toJson() => _$FestivalToJson(this);

  // Helper method to get coordinates from location string
  List<double>? get coordinates {
    if (location == null || location!.isEmpty) return null;
    try {
      final parts = location!.split(',');
      if (parts.length == 2) {
        return [double.parse(parts[0].trim()), double.parse(parts[1].trim())];
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  // Helper method to get formatted date range
  String get dateRange {
    final start = startDate;
    final end = endDate;

    if (start.year == end.year) {
      if (start.month == end.month) {
        return '${start.day}-${end.day} ${_getMonthName(start.month)} ${start.year}';
      } else {
        return '${_getMonthName(start.month)} ${start.day} - ${_getMonthName(end.month)} ${end.day}, ${start.year}';
      }
    } else {
      return '${_getMonthName(start.month)} ${start.day}, ${start.year} - ${_getMonthName(end.month)} ${end.day}, ${end.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
