import 'package:get_it/get_it.dart';

import 'package:orion/helper/database.dart';
GetIt locator = GetIt();

void setupLocator(){
  locator.registerLazySingleton<DatabaseHandler>(()=>DatabaseHandler());
}