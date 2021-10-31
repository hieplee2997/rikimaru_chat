import 'package:flutter/material.dart';

import 'cache_avatar.dart';

class FriendItem extends StatefulWidget {
  const FriendItem({Key? key, required this.user}) : super(key: key);

  final user;

  @override
  State<FriendItem> createState() => _FriendItemState();
}

class _FriendItemState extends State<FriendItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 2.2, offset: const Offset(2.0, 2.0), color: Colors.grey[200]!)],
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 0.5, color: Colors.grey)
        ),
        child: Row(children: [
          CachedAvatar("",name: widget.user['full_name'], height: 50, width: 50,),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(children: [
              Text(widget.user['full_name'], style: const TextStyle(fontSize: 16.0,fontWeight: FontWeight.w800)),
              Text(widget.user['user_name'], style: const TextStyle(fontSize: 14.0, color: Colors.grey))
            ], crossAxisAlignment: CrossAxisAlignment.start),
          )
        ]),
      ),
    ); 
  }
}