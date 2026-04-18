import 'package:flutter/material.dart';

class profileImage extends StatelessWidget {
  const profileImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Padding(
          padding: EdgeInsets.all(35),
          child: Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: ClipOval(
                child: SizedBox.fromSize(
                  size: Size.fromRadius(48), // Image radius
                  child:
                      Image.asset('assets/user.png', fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          right: 150,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(100),
                color: Colors.blue),
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 30.0,
            ),
          ),
        ),
      ],
    );
  }
}