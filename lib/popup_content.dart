import 'package:flutter/material.dart';

class PopupContent extends StatefulWidget {
  final Widget content;

  PopupContent({
    Key key,
    this.content,
  }) : super(key: key);

  _PopupContentState createState() => _PopupContentState();
}

class _PopupContentState extends State<PopupContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.content,
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
