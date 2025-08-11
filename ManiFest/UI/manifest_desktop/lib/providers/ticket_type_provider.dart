import 'package:manifest_desktop/model/ticket_type.dart';
import 'package:manifest_desktop/providers/base_provider.dart';

class TicketTypeProvider extends BaseProvider<TicketType> {
  TicketTypeProvider() : super('TicketType');

  @override
  TicketType fromJson(dynamic json) {
    return TicketType.fromJson(json as Map<String, dynamic>);
  }
}
