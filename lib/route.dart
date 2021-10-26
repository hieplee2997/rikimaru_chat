import 'package:fluro/fluro.dart';
import 'package:rikimaru_chat/dashboard.dart';

class AppRoutes {
  static FluroRouter router = FluroRouter();

  static final Handler _dashboard = Handler(
    handlerFunc: (context, Map<String, dynamic> params) => const DashBoard()
  );

  static void setupRouter() {
    router.define('/dashboard', handler: _dashboard, transitionType: TransitionType.inFromRight);
  }
}