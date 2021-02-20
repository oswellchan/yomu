import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class Spinner extends StatelessWidget {
  final height;
  final width;

  Spinner({this.height = 70.0, this.width = 70.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CupertinoActivityIndicator(),
      height: height,
      width: width,
    );
  }
}
