import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manifest_desktop/model/ticket.dart';
import 'package:manifest_desktop/providers/base_provider.dart';

class TicketProvider extends BaseProvider<Ticket> {
  TicketProvider() : super('Ticket');

  @override
  Ticket fromJson(dynamic json) {
    return Ticket.fromJson(json as Map<String, dynamic>);
  }

  Future<Ticket> redeemTicket(String generatedCode) async {
    var url = "${BaseProvider.baseUrl}$endpoint/redeem/$generatedCode";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to redeem ticket");
    }
  }
}
