import 'package:get_it/get_it.dart';
import '../ml/model_handler.dart';

GetIt locator = GetIt.instance;

setupServiceLocator() {
  locator.registerLazySingleton<ModelHandler>(() => ModelHandler());
}
