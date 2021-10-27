import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/dashboard.dart';
import 'package:rikimaru_chat/main_screen.dart';
import 'package:rikimaru_chat/models/auth_model.dart';
import 'package:rikimaru_chat/models/user_model.dart';
import 'package:rikimaru_chat/route.dart';

void main() {
  AppRoutes.setupRouter();
  runApp(RikimaruAppChat());
}

class RikimaruAppChat extends StatelessWidget {
  RikimaruAppChat({Key? key}) : super(key: key);
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProvider(create: (_) => User())
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
                    Container(color: Colors.red,) : const MainScreen(),
                  ),
            onGenerateRoute: AppRoutes.router.generator,
          );
        }
      ),
    );
  }
}

