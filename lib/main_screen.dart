import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/models/auth_model.dart';

class MainScreen extends StatefulWidget{
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  Future<void> routeToSignup() async {
    await Navigator.of(context).pushNamed('/signup');
  }
  Future<void> routeToLogin() async {
    await Navigator.of(context).pushNamed('/login');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        maintainBottomViewPadding: true,
        bottom: false,
        // top: false,
        child: Stack(
          children: [
            Container(color: const Color(0xff12171e),),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Text("Welcome \nBack", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  width: double.infinity,
                  child: TextButton(
                    onPressed: routeToLogin, 
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      overlayColor: MaterialStateProperty.all(Colors.blueAccent)
                    ),
                    child: const Text("Log in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: double.infinity,
                  child: TextButton(
                    onPressed: routeToSignup, 
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(const BorderSide(width: 1.0, color: Colors.grey)),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      overlayColor: MaterialStateProperty.all(Colors.lightBlue.shade100)
                    ),
                    child: const Text("Sign up", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                  ),
                ),
                const SizedBox(height: 30.0,)
              ],
            ),
          ],
        ),
      ),
    );
  }
}