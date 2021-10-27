import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/models/auth_model.dart';

class Login extends StatefulWidget{
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    String userName = _usernameController.text;
    String password = _passwordController.text;
    final result = await Provider.of<Auth>(context, listen: false).loginWithPassword(userName, password);

    if (result) {
      await Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
    }
    else {
      showDialog(context: context, builder: (context) {
        return const AlertDialog(
          alignment: Alignment.center,
          title: Text("Message", textAlign: TextAlign.center,),
          content: SizedBox(width: 100, height: 50, child: Center(child: Text("Đăng nhập không thành công", textAlign: TextAlign.center,),)),
        );
      });
    }
  }

  Future<void> routeToSignup () async {
    routeBack();
    await Navigator.of(context).pushNamed('/signup');
  }

  routeBack() {
    Navigator.of(context).pop();
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
              children: [
                IconButton(
                  padding: const EdgeInsets.all(10),
                  onPressed: routeBack, 
                  icon: const Icon(Icons.arrow_back_ios_new, size:34, color: Colors.white,)
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Text("Welcome \nBack", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.mail_outlined),
                          suffixIcon: Icon(Icons.check),
                        ),
                        controller: _usernameController,
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        autofocus: true,
                        obscureText: true,
                        focusNode: FocusNode(),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                          suffixIcon: Icon(Icons.remove_red_eye_rounded),
                        ),
                        controller: _passwordController,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, right: 20.0),
                      alignment: Alignment.centerRight , 
                      child: const Text("Forgot password?", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.blue))
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  width: double.infinity,
                  child: TextButton(
                    onPressed: login, 
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      overlayColor: MaterialStateProperty.all(Colors.blueAccent)
                    ),
                    child: const Text("Log in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(child: Container(margin: const EdgeInsets.only(right: 10.0) , color: Colors.grey, height: 1.0,)),
                      const Text("or", style: TextStyle(color: Colors.grey, fontSize: 18.0),),
                      Expanded(child: Container(margin: const EdgeInsets.only(left: 10.0), color: Colors.grey, height: 1.0,))
                    ],
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}