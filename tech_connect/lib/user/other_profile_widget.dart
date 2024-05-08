import 'package:flutter/material.dart';

class OtherProfileWidget extends StatelessWidget {
    final String imagePath;
    final bool isEdit;
    final VoidCallback onClicked;

    const OtherProfileWidget({
      Key? key,
      required this.imagePath,
      this.isEdit = false,
      required this.onClicked
    }) :super(key: key);

  @override
  Widget build(BuildContext context){
    final color = Theme.of(context).colorScheme.primary;

    return Center(
        child: buildImage()
    );
    }
    
  Widget buildImage(){
    final image = NetworkImage(imagePath);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(onTap: onClicked,),
      ),
      )
    );
  }
}