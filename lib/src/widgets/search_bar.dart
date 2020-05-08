import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchBarState extends State<SearchBar> {

  var _showClearButton = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateClearButton);
  }

  @override
  Widget build(BuildContext context) {
    var children = [
      Icon(
        CupertinoIcons.search,
        color: CupertinoColors.systemGrey.withOpacity(0.5),
      ),
      Expanded(
        child: CupertinoTextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onSubmitted: widget.onSubmitted,
          cursorColor: CupertinoColors.systemGrey4,
          placeholder: 'Search manga',
          decoration: BoxDecoration(
            color: null,
          ),
          placeholderStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: CupertinoColors.systemGrey,
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: CupertinoColors.white,
          ),
        ),
      ),
    ];

    if (_showClearButton) {
      children.add(GestureDetector(
        onTap: widget.controller.clear,
        child: const Icon(
          CupertinoIcons.clear_thick_circled,
          color: CupertinoColors.systemGrey,
        ),
      ));
    }

    return Container(
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CupertinoColors.black,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        child: Row(
          children: children,
        ),
      ),
    );
  }

  void _updateClearButton() {
    setState(() {
      if (widget.controller.text.isEmpty) {
        _showClearButton = false;
      } else {
        _showClearButton = true;
      }
    });
  }
}

class SearchBar extends StatefulWidget {

  const SearchBar({
    @required this.controller,
    @required this.focusNode,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Function onSubmitted;

  @override
  SearchBarState createState() => SearchBarState();
}
