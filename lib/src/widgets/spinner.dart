import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class Spinner extends StatelessWidget {

  var height = 70.0;
  var width = 70.0;

  Spinner({
    this.height,
    this.width
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CupertinoActivityIndicator(),
      height: height,
      width: width,
    );
  }
}
