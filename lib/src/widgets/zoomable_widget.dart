import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';


class ZoomableWidgetState extends State<ZoomableWidget> 
  with TickerProviderStateMixin {
  var oldGlobalPoint = Offset.zero;
  
  var _scale = 1.0;
  var _reference = Offset.zero;
  var _translateOffset = Offset.zero;
  var _reverseTranslateOffset = Offset.zero;
  var _zoomOffset = Offset.zero;

  AnimationController _zoomController;
  AnimationController _resetController;
  Animation _zoomAnimation;
  Animation _resetAnimation;

  @override
  void initState() {
    super.initState();
    _initZoomController();
    _initResetController();

    _zoomAnimation = new Tween(
      begin: 1.0,
      end: 2.0,
    ).animate(new CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeOutExpo
    ));

    _resetAnimation = new Tween(
      begin: 1.0,
      end: 2.0,
    ).animate(new CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeInExpo
    ));
  }

  void _initZoomController() {
    _zoomController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300)
    );
    _zoomController.addListener(() {
      setState(() {
        _scale = _zoomAnimation.value;
      });
    });
  }

  void _initResetController() {
    _resetController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300)
    );
    _resetController.addListener(() {
      setState(() {
        var val = _resetAnimation.value;
        _translateOffset = _reverseTranslateOffset * (val - 1);
        _scale = val;

        if (_scale == 1) {
          _reference = Offset.zero;
          _translateOffset = Offset.zero;
          _reverseTranslateOffset = Offset.zero;
          _zoomOffset = Offset.zero;
        }
      });
    });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _resetController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: GestureDetector(
        child: Transform(
          transform: Matrix4.identity()
            ..translate(_translateOffset.dx, _translateOffset.dy)
            ..scale(_scale, _scale),
          child: widget.child,
          origin: _zoomOffset,
        ),
        onTapDown: _onTapDown,
        onPanUpdate: _onPanUpdate,
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    var currGlobalPointX = details.globalPosition.dx;
    var currGlobalPointY = details.globalPosition.dy;
    var currGlobalPoint = Offset(currGlobalPointX, currGlobalPointY);

    if (_isDoubleTap(currGlobalPoint)) {
      _onDoubleTap(details.localPosition);
    }

    oldGlobalPoint = currGlobalPoint;
    Timer(Duration(milliseconds: 500), () {
      oldGlobalPoint = Offset.zero;
    });
  }

  bool _isDoubleTap(Offset currGlobalPoint) {
    if ((oldGlobalPoint.dx - currGlobalPoint.dx).abs() < 20 &&
      (oldGlobalPoint.dy - currGlobalPoint.dy).abs() < 20) {
      return true;
    }
    return false;
  }

  void _onDoubleTap(Offset doubleTapPoint) {
    // Prevent interaction
    if (_zoomController.isAnimating || _resetController.isAnimating) {
      return;
    }

    oldGlobalPoint = Offset.zero;
    setState(() {
      if (_scale == 1.0) {
        applyZoom(doubleTapPoint);
      } else {
        reset();
      }
    });
  }

  void applyZoom(Offset doubleTapPoint) {
    _zoomOffset = doubleTapPoint;
    _reference = Offset(
      doubleTapPoint.dx,
      context.size.height - doubleTapPoint.dy
    );
    _zoomController.forward(from: 0.0);
  }

  void reset() {
    _reverseTranslateOffset = _translateOffset;
    _resetController.reverse(from: 2.0);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_scale == 1.0 || 
      _zoomController.isAnimating || 
      _resetController.isAnimating) {
      return;
    }

    var delta = _clampDelta(details.delta);
    setState(() {
      _reference += Offset(delta.dx * -1, delta.dy);
      _translateOffset += delta;
    });
  }

  Offset _clampDelta(Offset delta) {
    final Size size = context.size;
    final Offset bounds = Offset(size.width, size.height) * (_scale - 1.0);

    var normalisedDelta = Offset(delta.dx * -1, delta.dy);

    var expected = _reference + normalisedDelta;
    var actual = Offset(
      expected.dx.clamp(0.0, bounds.dx),
      expected.dy.clamp(0.0, bounds.dy),
    );

    var diff = normalisedDelta - (expected - actual);

    return Offset(diff.dx * -1, diff.dy);
  }
}

class ZoomableWidget extends StatefulWidget {
  final Widget child;
  final Function onInteract;

  ZoomableWidget({
    @required this.child,
    @required this.onInteract,
  });

  @override
  ZoomableWidgetState createState() => ZoomableWidgetState();
}
