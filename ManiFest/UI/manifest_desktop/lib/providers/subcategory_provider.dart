import 'package:manifest_desktop/model/subcategory.dart';
import 'package:manifest_desktop/providers/base_provider.dart';

class SubcategoryProvider extends BaseProvider<Subcategory> {
  SubcategoryProvider() : super('Subcategory');

  @override
  Subcategory fromJson(dynamic json) {
    return Subcategory.fromJson(json as Map<String, dynamic>);
  }
}
