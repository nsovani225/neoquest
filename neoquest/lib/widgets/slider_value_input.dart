import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

class SliderValueInput extends StatefulWidget {
  const SliderValueInput({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.prefix,
    this.suffix,
    this.decimalPlaces = 0,
    this.width = 116,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String? prefix;
  final String? suffix;
  final int decimalPlaces;
  final double width;

  @override
  State<SliderValueInput> createState() => _SliderValueInputState();
}

class _SliderValueInputState extends State<SliderValueInput> {
  late final TextEditingController _controller = TextEditingController(
    text: _format(widget.value),
  );
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChanged);

  String _format(double value) {
    final fixed = value.toStringAsFixed(widget.decimalPlaces);
    if (!fixed.contains('.')) return fixed;
    return fixed
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  void didUpdateWidget(covariant SliderValueInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      _controller.text = _format(widget.value);
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _commit() {
    final parsed = double.tryParse(_controller.text.trim());
    if (parsed == null) {
      _controller.text = _format(widget.value);
      return;
    }
    final clamped = parsed.clamp(widget.min, widget.max).toDouble();
    final value = widget.decimalPlaces == 0
        ? clamped.roundToDouble()
        : double.parse(clamped.toStringAsFixed(widget.decimalPlaces));
    _controller.text = _format(value);
    widget.onChanged(value);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width,
    child: TextField(
      controller: _controller,
      focusNode: _focusNode,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.numberWithOptions(
        decimal: widget.decimalPlaces > 0,
      ),
      textInputAction: TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onSubmitted: (_) {
        _commit();
        _focusNode.unfocus();
      },
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF8F9F5),
        prefixText: widget.prefix,
        suffixText: widget.suffix,
        prefixStyle: const TextStyle(
          color: NeoColors.muted,
          fontWeight: FontWeight.w700,
        ),
        suffixStyle: const TextStyle(
          color: NeoColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeoColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeoColors.violet, width: 1.5),
        ),
      ),
    ),
  );
}
