import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TextFieldWidget extends StatelessWidget {
  final bool? requiredMark;
  final String? label;
  final String placeholder;
  final void Function(String) onChanged;
  final String? error;
  final TextInputType? keyboardType;
  final String? initialValue;
  final Widget? leading;
  final FocusNode? focusNode;
  final bool obscureText;
  final Color? fillColor;

  final EdgeInsetsGeometry? padding;

  const TextFieldWidget({
    super.key,
    this.label,
    required this.placeholder,
    required this.onChanged,
    this.error,
    this.keyboardType,
    this.requiredMark = false,
    this.padding,
    this.initialValue,
    this.leading,
    this.focusNode,
    this.obscureText = false,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        ShadInputFormField(
          focusNode: focusNode,
          obscureText: obscureText,
          decoration: ShadDecoration(
            color: fillColor ?? Colors.grey[50],
            border: ShadBorder.all(
              width: 1,
              radius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
          padding: padding,
          leading: leading,
          label: label != null
              ? (requiredMark == true
                    ? RichText(
                        text: TextSpan(
                          text: label,
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: ShadTheme.of(
                                  context,
                                ).colorScheme.destructive,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(label!))
              : null,
          placeholder: Text(placeholder),
          onChanged: onChanged,
          keyboardType: keyboardType,
          initialValue: initialValue,
        ),
        if (error != null && error!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              error!,
              style: ShadTheme.of(context).textTheme.small.copyWith(
                color: ShadTheme.of(context).colorScheme.destructive,
              ),
            ),
          ),
      ],
    );
  }
}
