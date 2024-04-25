import 'package:flutter/material.dart';

class IDButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final Color backgroundColor;
  final Color edgeColor;
  final AssetImage userImage;
  const IDButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.backgroundColor,
    required this.edgeColor,
    required this.userImage,
  });

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 400,
        height: 200,
        decoration: 
          BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(width: 1, color: edgeColor),
            image: DecorationImage(
              image: userImage,
              scale: 4,
              alignment: Alignment.centerRight,
            )
          ),
        child : Center(
          child: 
          Text(
            text,
            style: 
             const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}