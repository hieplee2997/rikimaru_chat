import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/dashboard.dart';
import 'package:rikimaru_chat/friend_screen.dart';
import 'package:rikimaru_chat/login.dart';
import 'package:rikimaru_chat/main_screen.dart';
import 'package:rikimaru_chat/models/auth_model.dart';
import 'package:rikimaru_chat/models/call_modal.dart';
import 'package:rikimaru_chat/models/conversation_model.dart';
import 'package:rikimaru_chat/models/user_model.dart';
import 'package:rikimaru_chat/route.dart';
import 'package:rikimaru_chat/signup.dart';

import 'models/utils.dart';

void main() async {
  AppRoutes.setupRouter();
  runApp(RikimaruAppChat());
  var newDir  =  await getApplicationSupportDirectory();
  var newPath  =  newDir.path + "/pancake_chat_data";
  Hive.init(newPath);
  await Utils.initPairKeyBox();
  await Hive.openBox("pairKey");
}

class RikimaruAppChat extends StatelessWidget {
  RikimaruAppChat({Key? key}) : super(key: key);
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProvider(create: (_) => User()),
        ChangeNotifierProvider(create: (_) => Conversation()),
        ChangeNotifierProvider(create: (_) => Calls())
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'RikimaruChat',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: auth.isAuth ? const DashBoard()
                  : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, authResult) => 
                    authResult.connectionState == ConnectionState.waiting ?
                    Container(color: Colors.red) : const MainScreen(),
                  ),
            onGenerateRoute: AppRoutes.router.generator,
          );
        }
      ),
    );
  }
}

