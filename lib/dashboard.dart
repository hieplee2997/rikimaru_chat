import 'package:flutter/material.dart';

class DashBoard extends StatefulWidget{
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    return const Material(
      child:  Center(
        child: Text("Bạn đã đăng kí thành công", style: TextStyle(fontSize: 30), textAlign: TextAlign.center),
      ),
    );
  }
}