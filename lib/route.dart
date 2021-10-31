import 'package:fluro/fluro.dart';
import 'package:rikimaru_chat/dashboard.dart';
import 'package:rikimaru_chat/friend_screen.dart';
import 'package:rikimaru_chat/login.dart';
import 'package:rikimaru_chat/main_screen.dart';
import 'package:rikimaru_chat/signup.dart';

class AppRoutes {
  static FluroRouter router = FluroRouter();

  static final Handler _dashboard = Handler(
    handlerFunc: (context, Map<String, dynamic> params) => const DashBoard()
  );

  static final Handler _login = Handler(
    handlerFunc: (context, Map<String, dynamic> params) => const Login()
  );

  static final Handler _signup = Handler(
    handlerFunc: (context, Map<String, dynamic> params) => const Signup()
  );

  static final Handler _mainScreen = Handler(
    handlerFunc: (context,Map<String, dynamic> params) => const MainScreen()
  );

  static final Handler _friendScreen = Handler(
    handlerFunc: (context,Map<String, dynamic> params) => const FriendScreen()
  );

  static void setupRouter() {
    router.define('/dashboard', handler: _dashboard, transitionType: TransitionType.inFromRight);
    router.define('/login', handler: _login, transitionType: TransitionType.inFromRight);
    router.define('/signup', handler: _signup, transitionType: TransitionType.inFromRight);
    router.define('/main_screen', handler: _mainScreen, transitionType: TransitionType.inFromRight);
    router.define('/friends', handler: _friendScreen, transitionType: TransitionType.inFromRight);
  }
}