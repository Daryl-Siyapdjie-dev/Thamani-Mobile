import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ready_ecommerce/components/ecommerce/decrement_button.dart';
import 'package:ready_ecommerce/components/ecommerce/increment_button.dart';
import 'package:ready_ecommerce/config/app_color.dart';
import 'package:ready_ecommerce/config/app_text_style.dart';
import 'package:ready_ecommerce/config/theme.dart';
import 'package:ready_ecommerce/utils/global_function.dart';

class IncrementDecrementButton extends StatelessWidget {
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

  bool get _atMaxStock => maxStock != null && productQuantity >= maxStock!;
  bool get _atMinQty => productQuantity <= 1;

  void _showQuantityDialog(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: productQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          "Modifier la quantité",
          style: AppTextStyle(context).subTitle.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (maxStock != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  "Stock disponible : $maxStock",
                  style: AppTextStyle(context).bodyText.copyWith(color: Colors.grey),
                ),
              ),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: InputDecoration(
                hintText: "Entrez la quantité",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: TextStyle(color: colors(context).errorColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              int? newQty = int.tryParse(text);
              if (newQty == null || newQty < 1) return;

              if (maxStock != null && newQty > maxStock!) {
                newQty = maxStock;
                HapticFeedback.heavyImpact();
                GlobalFunction.showCustomSnackbar(
                  message: 'Stock limité à $maxStock unités.',
                  isSuccess: false,
                );
              } else {
                HapticFeedback.lightImpact();
              }

              onSetQuantity?.call(newQty!);
              Navigator.pop(context);
            },
            child: const Text("Valider", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditable = onSetQuantity != null;
    final decrementDisabled = _atMinQty || isLoading;
    final incrementDisabled = _atMaxStock || isLoading;
    final themeColors = colors(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecrementButton(
          buttonColor: themeColors.accentColor ?? Colors.grey,
          iconColor: decrementDisabled
              ? EcommerceAppColor.lightGray.withValues(alpha: 0.4)
              : EcommerceAppColor.lightGray,
          onTap: decrementDisabled
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  decrement?.call();
                },
        ),
        Gap(8.w),
        GestureDetector(
          onTap: isEditable && !isLoading ? () => _showQuantityDialog(context) : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: themeColors.accentColor?.withValues(alpha: 0.1) ?? Colors.transparent,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: themeColors.primaryColor?.withValues(alpha: 0.2) ?? Colors.transparent,
              ),
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
                if (isEditable) ...[
                  Gap(4.w),
                  Icon(
                    Icons.edit_outlined,
                    size: 14.sp,
                    color: themeColors.primaryColor,
                  ),
                ],
              ],
            ),
          ),
        ),
        Gap(8.w),
        IncrementButton(
          buttonColor: themeColors.accentColor ?? Colors.grey,
          iconColor: incrementDisabled
              ? EcommerceAppColor.lightGray.withValues(alpha: 0.4)
              : EcommerceAppColor.lightGray,
          onTap: incrementDisabled
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  increment?.call();
                },
        ),
      ],
    );
  }
}
