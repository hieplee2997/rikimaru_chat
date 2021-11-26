import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rikimaru_chat/cache_avatar.dart';
import 'package:rikimaru_chat/models/auth_model.dart';
import 'package:rikimaru_chat/models/user_model.dart';

class UserSetting extends StatefulWidget {
  const UserSetting({Key? key}) : super(key: key);

  @override
  State<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  String userName = "";
  String avatarUrl = "";
  String phone = "";
  File? image;
  bool isDark = false;

  Future<void> browserImageGallery() async {
    try {
      final token = Provider.of<Auth>(context, listen: false).token;
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageSelected = File(image.path);
      setState(() {
        this.image = imageSelected;
      });

      final file = {
        "filename": image.name,
        "path": base64Encode(await image.readAsBytes()),
        "length": await image.length(),
        "mime_type": image.mimeType,
        "name": image.name
      };

      final uploadData = {
        "content_type": "jpg",
        "file": file,
        "mime_type": image.mimeType,
        "key": "VewnQ1l0HPa3zYa4/QeCLIJUs5fxw3Ex26JgmnfIbCo="
      };

      Provider.of<User>(context, listen: false).uploadAvatar(uploadData, token);

    } catch (e) {
      print(e.toString());
    }
  }

  void logout() async {
    await Provider.of<Auth>(context, listen: false).logout();
    await Navigator.of(context).pushNamedAndRemoveUntil('/main_screen', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final me = Provider.of<User>(context, listen: true).me;
    return Material(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: const Text("Done")
                  )
                ),
                Container(
                  height: 250,
                  // color: Colors.blue,
                  margin: const EdgeInsets.symmetric(vertical: 50),
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: browserImageGallery,
                        child: me["avatar_url"] != null && me["avatar_url"] != "" ?
                          Center(
                            child: CachedAvatar(me["avatar_url"], name: me["full_name"], width: 120, height: 120)
                          ) :
                         Center(
                          child: Container(
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                alignment: Alignment.topCenter,
                                image: image != null ? Image.file(image!).image : const NetworkImage(
                                  "https://media1.nguoiduatin.vn/thumb_x992x595/media/ha-thi-linh/2021/01/29/hot-girl-sai-thanh-nghin-do-21.jpg",
                                ),
                                fit: BoxFit.cover
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Center(child: Image(image: AssetImage("assets/images/Code.png")))
                    ],
                  )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: const [
                          Icon(CupertinoIcons.moon_circle_fill, size: 43),
                          SizedBox(width: 8),
                          Text("Dark mode"),
                        ],
                      ),
                      Row(
                        children: [
                          FlutterSwitch(
                            width: 44,
                            height: 24,
                            toggleSize: 20,
                            value: isDark,
                            padding: 2,
                            onToggle: (value) {
                              setState(() {
                                isDark = value;
                              });
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: const [
                          Icon(CupertinoIcons.chat_bubble_2, size: 38),
                          SizedBox(width: 8),
                          Text("Active Status")
                        ],
                      ),
                      TextButton(onPressed: (){}, child: const Text("On"))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: const [
                          Icon(PhosphorIcons.at, size: 38),
                          SizedBox(width: 8),
                          Text("Username")
                        ],
                      ),
                      const Text("Sample username")
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: const [
                          Icon(PhosphorIcons.phone, size: 38),
                          SizedBox(width: 8),
                          Text("Phone")
                        ],
                      ),
                      const Text("Sample phone number")
                    ],
                  ),
                ),
                Container(alignment: Alignment.centerLeft, margin: const EdgeInsets.symmetric(vertical: 10), child: const Text("Preferences")),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: const [
                          Icon(PhosphorIcons.bell, size: 38),
                          SizedBox(width: 8),
                          Text("Notification & Sounds")
                        ],
                      ),
                      Container()
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: const [
                          Icon(CupertinoIcons.person_2, size: 38),
                          SizedBox(width: 8),
                          Text("People")
                        ],
                      ),
                      Container()
                    ],
                  ),
                ),
                Center(
                  child: InkWell(
                    onTap: logout,
                    child: const Text("Log out", style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}