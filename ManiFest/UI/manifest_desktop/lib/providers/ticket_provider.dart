import 'package:manifest_desktop/model/ticket.dart';
import 'package:manifest_desktop/providers/base_provider.dart';

class TicketProvider extends BaseProvider<Ticket> {
  TicketProvider() : super('Ticket');

  @override
  Ticket fromJson(dynamic json) {
    return Ticket.fromJson(json as Map<String, dynamic>);
  }
}
