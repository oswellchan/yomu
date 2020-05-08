import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'sources/base.dart';
import 'sources/mangatown.dart';
import 'widgets/manga_row.dart';
import 'widgets/search_bar.dart';

class SearchState extends State<Search> {
  final MangaTown _source = MangaTown();
  List<Manga> _mangas = <Manga>[];
  bool _notFetching = true;
  MangaTownCursor _cursor;

  TextEditingController _controller;
  FocusNode _focusNode;
  String _terms = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onTextChanged);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // TODO: Implement search on demand
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchBar(
        controller: _controller,
        focusNode: _focusNode,
        onSubmitted: _fetchNextList,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        color: CupertinoColors.darkBackgroundGray,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              _buildSearchBox(),
              Expanded(
                child: Container(
                  color: CupertinoColors.black,
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: ListView.builder(
                    itemBuilder: (BuildContext _context, int i) {
                      if (i * 3 >= _mangas.length) {
                        return null;
                      }

                      var start = i * 3;
                      if (start + 3 <= _mangas.length) {
                        return MangaRow(mangas: _mangas.sublist(start, start + 3));
                      }

                      return null;
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fetchNextList(String search) async {
    print(search);
    // var mangas = await _cursor.getNext();
    // if (!mounted) return;

    // setState(() {
    //   _mangas.addAll(mangas);
    //   _notFetching = true;
    // });
  }
}

class Search extends StatefulWidget {
  @override
  SearchState createState() => SearchState();
}
