import 'package:manifest_desktop/model/category.dart';
import 'package:manifest_desktop/providers/base_provider.dart';

class CategoryProvider extends BaseProvider<Category> {
  CategoryProvider() : super('Category');

  @override
  Category fromJson(dynamic json) {
    return Category.fromJson(json as Map<String, dynamic>);
  }
}
