import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';

/// Unified controlled search field with reactive clear button and optional debounce.
/// Fixes stale clear icons and eliminates per-keystroke redundant backend queries.
class SkaviaSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? trailing;
  final Duration debounceDuration;

  const SkaviaSearchField({
    super.key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.readOnly = false,
    this.trailing,
    this.debounceDuration = Duration.zero,
  });

  @override
  State<SkaviaSearchField> createState() => _SkaviaSearchFieldState();
}

class _SkaviaSearchFieldState extends State<SkaviaSearchField> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleChange(String value) {
    _debounce?.cancel();
    if (widget.onChanged == null) return;
    if (widget.debounceDuration == Duration.zero) {
      widget.onChanged!(value);
    } else {
      _debounce = Timer(widget.debounceDuration, () {
        if (mounted) widget.onChanged!(value);
      });
    }
  }

  void _handleClear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return TextField(
          controller: _controller,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: _handleChange,
          onSubmitted: widget.onSubmitted,
          textInputAction: TextInputAction.search,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.mutedText,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: tokens.secondaryText,
              size: 20,
            ),
            suffixIcon: hasText
                ? IconButton(
                    tooltip: 'Clear search',
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: tokens.secondaryText,
                    ),
                    onPressed: _handleClear,
                  )
                : widget.trailing,
            filled: true,
            fillColor: tokens.inputBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(color: tokens.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(color: tokens.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        );
      },
    );
  }
}
