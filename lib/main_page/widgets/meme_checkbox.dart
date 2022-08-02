import 'package:flutter/material.dart';

import 'package:memo/main_page/main_page_screen.dart';


class MemeCheckBox extends StatelessWidget {
  final Memes curr;
  final Memes value;
  final Widget title;
  final Function(bool?) onChanged;
  const MemeCheckBox({
    Key? key,
    required this.curr,
    required this.value,
    required this.title,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (curr == value) {
      return CheckboxListTile(
        activeColor: const Color(0xFF4475ED),
        title: title,
        value: true,
        onChanged: onChanged,
      );
    } else {
      return CheckboxListTile(
        title: title,
        checkColor: const Color(0xFF4475ED),
        value: false,
        onChanged: onChanged,
      );
    }
  }
}
