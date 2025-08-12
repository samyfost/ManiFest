import 'package:manifest_desktop/model/festival.dart';
import 'package:manifest_desktop/providers/base_provider.dart';

class FestivalProvider extends BaseProvider<Festival> {
  FestivalProvider() : super('Festival');

  @override
  Festival fromJson(dynamic json) {
    return Festival.fromJson(json as Map<String, dynamic>);
  }
}
