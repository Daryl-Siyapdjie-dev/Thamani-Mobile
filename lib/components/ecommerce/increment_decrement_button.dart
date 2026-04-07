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

class IncrementDecrementButton extends StatelessWidget {
  final void Function()? increment;
  final void Function()? decrement;
  final void Function(int)? onSetQuantity;
  final int productQuantity;
  const IncrementDecrementButton({
    super.key,
    this.increment,
    this.decrement,
    this.onSetQuantity,
    required this.productQuantity,
  });

  void _showQuantityDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _QuantityDialog(
        initialQuantity: productQuantity,
        onSetQuantity: onSetQuantity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecrementButton(
          buttonColor: colors(context).accentColor,
          iconColor: EcommerceAppColor.lightGray,
          onTap: decrement,
        ),
        Gap(8.w),
        GestureDetector(
          onTap: onSetQuantity != null
              ? () => _showQuantityDialog(context)
              : null,
          child: Container(
            constraints: BoxConstraints(minWidth: 36.w),
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: onSetQuantity != null
                  ? colors(context).primaryColor!.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6.r),
              border: onSetQuantity != null
                  ? Border.all(
                      color:
                          colors(context).primaryColor!.withValues(alpha: 0.25),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  productQuantity.toString(),
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (onSetQuantity != null) ...[
                  Gap(4.w),
                  Icon(
                    Icons.edit,
                    size: 10.sp,
                    color: colors(context).primaryColor!.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
          ),
        ),
        Gap(8.w),
        IncrementButton(
          buttonColor: colors(context).accentColor,
          iconColor: EcommerceAppColor.lightGray,
          onTap: increment,
        ),
      ],
    );
  }
}

class _QuantityDialog extends StatefulWidget {
  final int initialQuantity;
  final void Function(int)? onSetQuantity;

  const _QuantityDialog({
    required this.initialQuantity,
    this.onSetQuantity,
  });

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.initialQuantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_formKey.currentState?.validate() ?? false) {
      final newQty = int.parse(_controller.text);
      if (newQty != widget.initialQuantity) {
        widget.onSetQuantity?.call(newQty);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          Icon(
            Icons.edit_outlined,
            size: 20.sp,
            color: colors(context).primaryColor,
          ),
          Gap(8.w),
          Text(
            'Modifier la quantité',
            style: AppTextStyle(context).bodyText.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyle(context).bodyText.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
              ),
          decoration: InputDecoration(
            hintText: '0',
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: colors(context).primaryColor!.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: colors(context).primaryColor!,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Entrez une quantité';
            final qty = int.tryParse(value);
            if (qty == null || qty < 1) return 'Minimum 1';
            return null;
          },
          onFieldSubmitted: (_) => _confirm(),
        ),
      ),
      actionsPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Annuler',
            style: AppTextStyle(context).bodyText.copyWith(
                  color: colors(context).bodyTextSmallColor,
                ),
          ),
        ),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          ),
          child: Text(
            'Confirmer',
            style: AppTextStyle(context).bodyText.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
