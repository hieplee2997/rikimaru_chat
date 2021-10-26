import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/models/auth_model.dart';
import 'package:rikimaru_chat/route.dart';
import 'package:rikimaru_chat/signup.dart';

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
        ChangeNotifierProvider(create: (_) => Auth())
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'RikimaruChat',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const Signup(),
            onGenerateRoute: AppRoutes.router.generator,
          );
        }
      ),
    );
  }
}

