import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../database/db.dart';
import '../manga_overview.dart';
import '../sources/mangatown.dart';
import 'arguments.dart';


class ReaderState extends State<Reader> {
  final MangaTown _source = MangaTown();
  final List<String> _images = <String>[];
  final Set<String> _chapters = <String>{};
  String _manga;
  
  bool _isFetching = false;
  String _prevChapter;
  String _currChapter;
  String _nextChapter;


  @override
  Widget build(BuildContext context) {
    ReaderArguments args = ModalRoute.of(context).settings.arguments;
    _manga = args.mangaUrl;

    var chapterUrl = args.chapterUrl;   
    if (!_chapters.contains(chapterUrl)) {
      _nextChapter = chapterUrl;
    }

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            NavBar(),
            Expanded(
              child: _buildPages(this._images),
            )
          ],
        )
      )
    );
  }

  Widget _buildPages(List<String> images) {
    return ListView.builder(
      itemBuilder: (BuildContext _context, int i) {
        if (i >= _images.length) {
          if (!_isFetching) {
            _fetchPages(_nextChapter);
          }
          return null;
        }

        return _buildPage(images[i]);
      }
    );
  }

  void _fetchPages(String url) async {
    if (_chapters.contains(url)) {
      return;
    }

    _isFetching = true;
    var chpt = await _source.getChapterPages(url);

    if (_manga != '') DBHelper().saveRead(_manga, url);

    if (_currChapter == chpt.nextChapterUrl) {
      // append at the back
    } else {
      _images.addAll(chpt.pages);
    }

    if (!mounted) return;
    setState(() {
      _chapters.add(url);
      _prevChapter = chpt.prevChapterUrl;
      _currChapter = url;
      _nextChapter = chpt.nextChapterUrl;
      _isFetching = false;
    });
  }
}

class Reader extends StatefulWidget {
  @override
  ReaderState createState() => ReaderState();
}

Widget _buildPage(String pageUrl) {
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    child: ZoomableWidget(
      child: CachedNetworkImage(
        imageUrl: pageUrl,
        placeholder: (context, url) => Center(
          child: SizedBox(
            child: CupertinoActivityIndicator(),
            height:70.0,
            width: 70.0,
          )
        ),
        errorWidget: (context, url, error) => Container(
          color: CupertinoColors.systemGrey,
          child: Icon(Icons.error),
        )
      ),
    ),
  );
}

class ZoomableWidgetState extends State<ZoomableWidget> 
  with SingleTickerProviderStateMixin {
  var matrix = Matrix4.identity();
  var zoomOffset = Offset.zero;
  var originalSize;
  var oldGlobalPoint = Offset.zero;
  var _scale = 1.0;

  AnimationController _zoomController;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
        vsync: this,
        lowerBound: 1 / 1.2,
        upperBound: 1.2,
        duration: Duration(seconds: 1));
    _zoomController.addListener(() {
      setState(() {
        _scale = _zoomController.value;
        if (_scale == 1 / 1.2) {
          matrix = Matrix4.identity();
        } else {
          matrix.scale(_scale, _scale);
        }
      });
    });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: GestureDetector(
        child: Transform(
          transform: matrix,
          origin: zoomOffset,
          child: widget.child
        ),
        onTapDown: _onTapDown,
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (matrix == Matrix4.identity()) {
      var x = details.localPosition.dx;
      var y = details.localPosition.dy;
      zoomOffset = Offset(x, y);
    }

    var currGlobalPointX = details.globalPosition.dx;
    var currGlobalPointY = details.globalPosition.dy;
    var currGlobalPoint = Offset(currGlobalPointX, currGlobalPointY);

    if (_isDoubleTap(currGlobalPoint)) {
      _onDoubleTap();
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

  void _onDoubleTap() {
    // Prevent interaction
    if (_zoomController.isAnimating) {
      return;
    }

    oldGlobalPoint = Offset.zero;
    setState(() {
      if (matrix == Matrix4.identity()) {
        _zoomController.forward(from: 1.0);
      } else {
        _zoomController.reverse(from: 1.0);
      }
    });
  }

  // Offset _clampOffset(Offset offset) {
  //   final Size size = context.size;
  //   final Offset minOffset =
  //       new Offset(size.width, size.height) * (1.0 - _scale);
  //   return new Offset(
  //       offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  // }
}

class ZoomableWidget extends StatefulWidget {
  final Widget child;

  ZoomableWidget({
    @required this.child,
  });

  @override
  ZoomableWidgetState createState() => ZoomableWidgetState();
}
