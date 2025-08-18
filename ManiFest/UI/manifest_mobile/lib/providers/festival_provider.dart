import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manifest_mobile/model/festival.dart';
import 'package:manifest_mobile/model/search_result.dart';
import 'package:manifest_mobile/providers/base_provider.dart';

class FestivalProvider extends BaseProvider<Festival> {
  FestivalProvider() : super('Festival');

  @override
  Festival fromJson(dynamic json) {
    return Festival.fromJson(json as Map<String, dynamic>);
  }

  Future<SearchResult<Festival>> getWithoutAssets({dynamic filter}) async {
    var url = "${BaseProvider.baseUrl}$endpoint/without-assets";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<Festival>();
      result.totalCount = data['totalCount'];
      result.items = List<Festival>.from(data["items"].map((e) => fromJson(e)));
      return result;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<Festival?> recommend(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/recommend/$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }
}
