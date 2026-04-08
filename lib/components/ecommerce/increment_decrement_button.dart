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
  // Stock maximum disponible — null = pas d'info stock (pas de limite côté client)
  final int? maxStock;

  const IncrementDecrementButton({
    super.key,
    this.increment,
    this.decrement,
    this.onSetQuantity,
    required this.productQuantity,
    this.maxStock,
  });

  bool get _atMaxStock => maxStock != null && productQuantity >= maxStock!;
  bool get _atMinQty => productQuantity <= 1;

  void _showQuantityDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _QuantityDialog(
        initialQuantity: productQuantity,
        maxStock: maxStock,
        onSetQuantity: onSetQuantity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton décrément — désactivé si quantité = 1
        DecrementButton(
          buttonColor: colors(context).accentColor,
          iconColor: _atMinQty
              ? EcommerceAppColor.lightGray.withValues(alpha: 0.4)
              : EcommerceAppColor.lightGray,
          onTap: _atMinQty ? null : decrement,
        ),
        Gap(8.w),
        // Zone quantité cliquable
        GestureDetector(
          onTap: onSetQuantity != null
              ? () => _showQuantityDialog(context)
              : null,
          child: Container(
            constraints: BoxConstraints(minWidth: 38.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: onSetQuantity != null
                  ? colors(context).primaryColor!.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6.r),
              border: onSetQuantity != null
                  ? Border.all(
                      color:
                          colors(context).primaryColor!.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  productQuantity.toString(),
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (onSetQuantity != null) ...[
                  Gap(3.w),
                  Icon(
                    Icons.edit,
                    size: 10.sp,
                    color: colors(context).primaryColor!.withValues(alpha: 0.5),
                  ),
                ],
              ],
            ),
          ),
        ),
        Gap(8.w),
        // Bouton incrément — désactivé si stock max atteint
        IncrementButton(
          buttonColor: colors(context).accentColor,
          iconColor: _atMaxStock
              ? EcommerceAppColor.lightGray.withValues(alpha: 0.4)
              : EcommerceAppColor.lightGray,
          onTap: _atMaxStock ? null : increment,
        ),
      ],
    );
  }
}

class _QuantityDialog extends StatefulWidget {
  final int initialQuantity;
  final int? maxStock;
  final void Function(int)? onSetQuantity;

  const _QuantityDialog({
    required this.initialQuantity,
    this.maxStock,
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
    // Sélectionner tout le texte pour faciliter la saisie
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_formKey.currentState?.validate() ?? false) {
      final newQty = int.parse(_controller.text.trim());
      if (newQty != widget.initialQuantity) {
        widget.onSetQuantity?.call(newQty);
      }
      Navigator.of(context).pop();
    }
  }

  String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Entrez une quantité';
    final qty = int.tryParse(value.trim());
    if (qty == null) return 'Nombre invalide';
    if (qty < 1) return 'Minimum 1';
    if (widget.maxStock != null && qty > widget.maxStock!) {
      return 'Maximum disponible : ${widget.maxStock}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          Icon(Icons.edit_outlined,
              size: 20.sp, color: colors(context).primaryColor),
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Affichage du stock max si disponible
          if (widget.maxStock != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: widget.maxStock! <= 5
                    ? Colors.orange.withValues(alpha: 0.1)
                    : EcommerceAppColor.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.maxStock! <= 5
                        ? Icons.warning_amber_rounded
                        : Icons.inventory_2_outlined,
                    size: 14.sp,
                    color: widget.maxStock! <= 5
                        ? Colors.orange
                        : EcommerceAppColor.green,
                  ),
                  Gap(6.w),
                  Text(
                    widget.maxStock! <= 5
                        ? 'Plus que ${widget.maxStock} en stock'
                        : '${widget.maxStock} disponibles',
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: widget.maxStock! <= 5
                              ? Colors.orange
                              : EcommerceAppColor.green,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            Gap(12.h),
          ],
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyle(context).bodyText.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                  ),
              decoration: InputDecoration(
                hintText: '1',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color:
                        colors(context).primaryColor!.withValues(alpha: 0.35),
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
                  borderSide:
                      const BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              validator: _validate,
              onFieldSubmitted: (_) => _confirm(),
            ),
          ),
        ],
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Annuler',
            style: AppTextStyle(context)
                .bodyText
                .copyWith(color: colors(context).bodyTextSmallColor),
          ),
        ),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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
