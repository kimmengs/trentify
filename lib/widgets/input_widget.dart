// lib/input_widget.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

class InputWidget extends StatefulWidget {
  const InputWidget({
    super.key,
    required this.controller,
    required this.placeholder,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.inputAccessoryBuilder, // optional for iOS: Done bar
  });

  final TextEditingController controller;
  final String placeholder;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final Widget Function(BuildContext context)? inputAccessoryBuilder;

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  String? _error;
  void _validate() {
    if (widget.validator != null) {
      setState(() => _error = widget.validator!(widget.controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isCupertino
        ? _CupertinoInput(
            controller: widget.controller,
            placeholder: widget.placeholder,
            prefix: widget.prefix,
            suffix: widget.suffix,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted,
            inputFormatters: widget.inputFormatters,
            focusNode: widget.focusNode,
            error: _error,
            onChanged: (_) => _validate(),
            onEditingComplete: _validate,
            inputAccessoryBuilder: widget.inputAccessoryBuilder,
          )
        : _MaterialInput(
            controller: widget.controller,
            placeholder: widget.placeholder,
            prefix: widget.prefix,
            suffix: widget.suffix,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted,
            inputFormatters: widget.inputFormatters,
            focusNode: widget.focusNode,
            error: _error,
            onChanged: (_) => _validate(),
            onEditingComplete: _validate,
          );
  }
}

/* -------------------- iOS (Cupertino) -------------------- */

class _CupertinoInput extends StatelessWidget {
  const _CupertinoInput({
    required this.controller,
    required this.placeholder,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.error,
    this.onChanged,
    this.onEditingComplete,
    this.inputAccessoryBuilder,
  });

  final TextEditingController controller;
  final String placeholder;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? error;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final Widget Function(BuildContext context)? inputAccessoryBuilder;

  @override
  Widget build(BuildContext context) {
    final bg = CupertinoColors.systemGrey6.resolveFrom(context);
    final borderColor =
        (error == null ? CupertinoColors.separator : CupertinoColors.systemRed)
            .resolveFrom(context);
    final placeholderColor = CupertinoColors.placeholderText.resolveFrom(
      context,
    );
    final textColor = CupertinoColors.label.resolveFrom(context);
    final radius = BorderRadius.circular(14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          controller: controller,
          focusNode: focusNode,
          placeholder: placeholder,
          placeholderStyle: TextStyle(color: placeholderColor),
          style: TextStyle(color: textColor),
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          prefix: prefix != null
              ? Padding(padding: const EdgeInsets.only(left: 12), child: prefix)
              : null,
          suffix: suffix != null
              ? Padding(padding: const EdgeInsets.only(right: 8), child: suffix)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.all(color: borderColor),
          ),
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          // inputAccessoryBuilder: inputAccessoryBuilder, // optional iOS toolbar
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 6),
            child: Text(
              error!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12.5,
              ),
            ),
          ),
      ],
    );
  }
}

/* -------------------- Android (Material) -------------------- */

class _MaterialInput extends StatelessWidget {
  const _MaterialInput({
    required this.controller,
    required this.placeholder,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.error,
    this.onChanged,
    this.onEditingComplete,
  });

  final TextEditingController controller;
  final String placeholder;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? error;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: Color(0xFF528F65),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        errorText: error,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
      ),
    );
  }
}
