import 'package:flutter/material.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:provider/provider.dart' show Consumer;
//ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  CustomTextField(
      {super.key,
      required this.controller,
      this.focusNode,
      required this.isMaxLinesNull,
      required this.autoFocus,
      required this.hintText,
      this.fillColor,
       this.xPadding,
       this.yPadding,
       this.contentPadding,
        this.onChanged,
      this.onSubmitted});

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isMaxLinesNull;
  final bool autoFocus;
  final String hintText;
  final Color? fillColor;
  double? xPadding;
  double? yPadding;
  EdgeInsetsGeometry? contentPadding;
  final void Function(String value)? onSubmitted;
  final void Function(String? value)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: xPadding ?? 0 , vertical: yPadding ?? 0),
      child: Consumer<GeneralViewModel>(
        builder: (context,gvm, _) {
          return TextField(
            focusNode: gvm.textFieldNode,
            controller: controller,
            textInputAction: TextInputAction.done,
            maxLines: isMaxLinesNull ? null : 1,
            autofocus: autoFocus,
            cursorColor: Theme.of(context).colorScheme.primary,
            decoration: InputDecoration(
              contentPadding: contentPadding ?? const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              filled: true,
              fillColor: fillColor ?? Theme.of(context).colorScheme.surface,
              hintText: hintText,
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary.withAlpha(155), fontSize: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide.none),
            ),
            onSubmitted: onSubmitted,
            onChanged : onChanged,
          );
        }
      ),
    );
  }
}
