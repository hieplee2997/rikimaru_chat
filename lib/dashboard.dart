import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/cache_avatar.dart';
import 'package:rikimaru_chat/chat_list.dart';
import 'package:rikimaru_chat/friend_screen.dart';
import 'package:rikimaru_chat/models/auth_model.dart';
import 'package:rikimaru_chat/models/user_model.dart';
import 'package:rikimaru_chat/user_settings.dart';

class DashBoard extends StatefulWidget{
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  Page page = Page.chat;

  @override
  void initState() {
    super.initState();
    Provider.of<Auth>(context, listen: false).connectSocket(context);
  }

  void openFriendList() {
    setState(() {
      page = Page.friend;
    });
  }
  void openChatList() {
    setState(() {
      page = Page.chat;
    });
  }
  void openUserSettings() {
    Navigator.push(context, PageRouteBuilder(pageBuilder: (context, a1, a2) {
      return const UserSetting();
    }));
  }

  @override
  Widget build(BuildContext context) {
    final me = Provider.of<User>(context, listen: true).me;
    return SafeArea(
      maintainBottomViewPadding: true,
      top: false,
      bottom: false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
            print("dassdasd");
        },
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              // boxShadow: const [BoxShadow(blurRadius: 55.0, blurStyle: BlurStyle.outer, color: Colors.black38)],
              borderRadius: BorderRadius.circular(20.0)
            ),
            child: Row(children: [
              Expanded(child: TextButton(onPressed: (){openChatList();}, child: const Icon(Icons.message))),
              Expanded(child: TextButton(onPressed: (){}, child: const Icon(Icons.favorite))),
              Expanded(child: TextButton(onPressed: (){openFriendList();}, child: const Icon(Icons.people_alt_rounded)))
            ]),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(left: 20, top: 70.0, right: 20.0),
            child: Column(children: [
              Row(children: [
                Expanded(child: TextField(
                  decoration: InputDecoration(
                    fillColor: Colors.grey[300],
                    filled: true,
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
                  ),
                  controller: TextEditingController(),
                )),
                Padding(
                  padding: const EdgeInsets.only(left: 13.0),
                  child: IconButton(
                    onPressed: (){},
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.add_alert_rounded),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15.0),
                  width: 68,
                  height: 68,
                  // decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: Colors.blue),
                  child: InkWell(
                    onTap: openUserSettings,
                    child: me["avatar_url"] != null && me["avatar_url"] != "" ?
                    CachedAvatar(me["avatar_url"], name: me["full_name"], width: 120, height: 120) :
                     ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network("https://media1.nguoiduatin.vn/thumb_x992x595/media/ha-thi-linh/2021/01/29/hot-girl-sai-thanh-nghin-do-21.jpg", fit: BoxFit.cover),
                    ),
                  ),
                )
              ]),
              const SizedBox(height: 20.0),
              Expanded(
                child: page == Page.chat ? ChatList() : const FriendScreen(),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

enum Page {
  chat,
  friend
}