import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'models/utils.dart';

class CachedAvatar extends StatelessWidget {
  final imageUrl;
  final bool isRound;
  final double radius;
  final double height;
  final double width;
  final BoxFit fit;
  final String? name;
  final bool isAvatar;
  final bool full;
  final double fontSize;

  final String noImageAvailable = "https://statics.pancake.vn/web-media/3e/24/0b/bb/09a144a577cf6867d00ac47a751a0064598cd8f13e38d0d569a85e0a.png";

  CachedAvatar(
    this.imageUrl, {
    required this.name,
    required this.width,
    required this.height,
    this.isRound = false,
    this.fit = BoxFit.cover,
    this.isAvatar = false,
    this.fontSize = 12,
    this.full = false,
    this.radius = 50,
  });
  
  @override
  Widget build(BuildContext context) {
    try {
      return SizedBox(
        height: height,
        width: width,
        child: (!Utils.checkedTypeEmpty(imageUrl) || imageUrl == noImageAvailable) 
        ? DefaultAvatar(name: name, fontSize: fontSize, radius: height / 2)
        : ClipOval(
          child: Container(
            color: Color(0xFFffffff),
            child: ExtendedImage.network(
            (imageUrl != null && imageUrl != "") ? imageUrl : noImageAvailable,
              fit: BoxFit.cover,
              repeat: ImageRepeat.repeat,
              cache: true,
            ),
          )
        ),
      );
    } catch (e) {
      return Container( 
        child: DefaultAvatar(name: name, radius: radius)
      );
    }
  }
}
class DefaultAvatar extends StatelessWidget {
  const DefaultAvatar({
    Key? key,
    this.name = "",
    this.fontSize = 12.0,
    this.radius = 2
  }) : 
  super();

  final name;
  final double radius;
  final double fontSize;

  getColorAvatar(letter) {
    List alphabets = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];

    final index = alphabets.indexWhere((e) => e == letter);
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final firstLetter = (Utils.checkedTypeEmpty(name) ? name : "P").substring(0, 1).toUpperCase();
    final index = getColorAvatar(firstLetter) + 1;
    
    return !Utils.checkedTypeEmpty(name) ? Container() : Container(
      decoration: BoxDecoration(
        color: Color(((index + 1) * 3.1412 * 0.1 * 0xFFFFFF).toInt()).withOpacity(1.0),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 20,
        child: Text(
          firstLetter,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: Colors.white
          ),
        ),
      ),
    );
  }
}