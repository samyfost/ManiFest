import 'package:manifest_desktop/model/organizer.dart';
import 'package:manifest_desktop/providers/base_provider.dart';

class OrganizerProvider extends BaseProvider<Organizer> {
  OrganizerProvider() : super('Organizer');

  @override
  Organizer fromJson(dynamic json) {
    return Organizer.fromJson(json as Map<String, dynamic>);
  }
}
