import 'package:orion/helper/database.dart';
import 'package:orion/helper/service_locator.dart';

class CategoryList{
  List<String> _categories = [];
  List<String> getCategorySuggestion(String pattern){
    return _categories.where((c)=>c.toLowerCase().contains(pattern));
  }
  Future<void> fetchCategories() async {
    _categories = await locator.get<DatabaseHandler>().listCategory();
  }
}