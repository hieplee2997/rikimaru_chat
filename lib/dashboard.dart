import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/models/auth_model.dart';

class DashBoard extends StatefulWidget{
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {

  @override
  void initState() {
    super.initState();
    Provider.of<Auth>(context, listen: false).connectSocket(context);
  }

  void logout() async {
    await Provider.of<Auth>(context, listen: false).logout();
    await Navigator.of(context).pushNamedAndRemoveUntil('/main_screen', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return  Material(
      child:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("Bạn đã đăng nhập thành công", style: TextStyle(fontSize: 30), textAlign: TextAlign.center),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red)
              ),
              onPressed: logout,
              child: const Text("Log out")
            )
          ],
        )
      ),
    );
  }
}