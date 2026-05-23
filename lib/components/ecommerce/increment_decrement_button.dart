// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ready_ecommerce/components/ecommerce/decrement_button.dart';
import 'package:ready_ecommerce/components/ecommerce/increment_button.dart';
import 'package:ready_ecommerce/config/app_color.dart';
import 'package:ready_ecommerce/config/app_text_style.dart';
import 'package:ready_ecommerce/config/theme.dart';

class IncrementDecrementButton extends StatefulWidget {
  final void Function()? increment;
  final void Function()? decrement;
  final void Function(int)? onSetQuantity;
  final int productQuantity;
  final int? maxStock;
  final bool isLoading;

  const IncrementDecrementButton({
    super.key,
    this.increment,
    this.decrement,
    this.onSetQuantity,
    required this.productQuantity,
    this.maxStock,
    this.isLoading = false,
  });

  @override
  State<IncrementDecrementButton> createState() =>
      _IncrementDecrementButtonState();
}

class _IncrementDecrementButtonState extends State<IncrementDecrementButton> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool get _atMaxStock =>
      widget.maxStock != null && widget.productQuantity >= widget.maxStock!;
  bool get _atMinQty => widget.productQuantity <= 1;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.productQuantity.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(IncrementDecrementButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync le TextField quand +/- modifient la quantité, sauf si l'utilisateur est en train de saisir
    if (oldWidget.productQuantity != widget.productQuantity &&
        !_focusNode.hasFocus) {
      _controller.text = widget.productQuantity.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _confirm();
    }
  }

  void _confirm() {
    if (widget.isLoading) return;

    final text = _controller.text.trim();
    if (text.isEmpty) {
      _controller.text = widget.productQuantity.toString();
      return;
    }

    final newQty = int.tryParse(text);
    if (newQty == null || newQty < 1) {
      _controller.text = widget.productQuantity.toString();
      return;
    }

    if (newQty == widget.productQuantity) return;

    widget.onSetQuantity?.call(newQty);
  }

  @override
  Widget build(BuildContext context) {
    final isEditable = widget.onSetQuantity != null;
    final decrementDisabled = _atMinQty || widget.isLoading;
    final incrementDisabled = _atMaxStock || widget.isLoading;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecrementButton(
          buttonColor: colors(context).accentColor,
          iconColor: decrementDisabled
              ? EcommerceAppColor.lightGray.withValues(alpha: 0.4)
              : EcommerceAppColor.lightGray,
          onTap: decrementDisabled ? null : widget.decrement,
        ),
        Gap(8.w),
        if (isEditable) _buildTextField(context) else _buildStaticQty(context),
        Gap(8.w),
        IncrementButton(
          buttonColor: colors(context).accentColor,
          iconColor: incrementDisabled
              ? EcommerceAppColor.lightGray.withValues(alpha: 0.4)
              : EcommerceAppColor.lightGray,
          onTap: incrementDisabled ? null : widget.increment,
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    return SizedBox(
      width: 52.w,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: !widget.isLoading,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        style: AppTextStyle(context).bodyText.copyWith(
              fontWeight: FontWeight.w700,
            ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide(
              color: colors(context).primaryColor!.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide(
              color: colors(context).primaryColor!,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide(
              color: EcommerceAppColor.lightGray.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        onSubmitted: (_) => _focusNode.unfocus(),
      ),
    );
  }

  Widget _buildStaticQty(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 38.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: Text(
        widget.productQuantity.toString(),
        textAlign: TextAlign.center,
        style: AppTextStyle(context).bodyText.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
