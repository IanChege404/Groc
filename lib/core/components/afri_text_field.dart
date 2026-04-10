import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_defaults.dart';

class AfriTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool showPasswordToggle;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final int minLines;
  final int? maxLength;
  final bool enabled;

  const AfriTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.enabled = true,
  });

  @override
  State<AfriTextField> createState() => _AfriTextFieldState();
}

class _AfriTextFieldState extends State<AfriTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          enabled: widget.enabled,
          obscureText: _obscureText && widget.obscureText,
          keyboardType: widget.keyboardType,
          maxLines: _obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          onChanged: (value) {
            widget.onChanged?.call(value);
            // Clear error when user starts typing
            setState(() => _errorMessage = null);
          },
          onFieldSubmitted: widget.onSubmitted,
          validator: (value) {
            _errorMessage = widget.validator?.call(value);
            return _errorMessage;
          },
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(isDark),
            errorText: _errorMessage,
            errorMaxLines: 2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDefaults.padding,
              vertical: AppDefaults.padding - 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon(bool isDark) {
    if (widget.showPasswordToggle && widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: isDark ? AppColors.subtleDark : AppColors.subtleLight,
        ),
        onPressed: () {
          setState(() => _obscureText = !_obscureText);
        },
      );
    }
    return widget.suffixIcon;
  }
}
