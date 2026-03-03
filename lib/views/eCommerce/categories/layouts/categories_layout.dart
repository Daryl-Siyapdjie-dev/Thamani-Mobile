import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ready_ecommerce/config/app_color.dart';
import 'package:ready_ecommerce/config/app_constants.dart';
import 'package:ready_ecommerce/config/theme.dart';
import 'package:ready_ecommerce/controllers/eCommerce/category/category_controller.dart';
import 'package:ready_ecommerce/routes.dart';
import 'package:ready_ecommerce/utils/context_less_navigation.dart';
import 'package:ready_ecommerce/utils/global_function.dart';
import 'package:ready_ecommerce/views/eCommerce/categories/components/sub_categories_bottom_sheet.dart';
import 'package:ready_ecommerce/views/eCommerce/home/components/category_card.dart';
import 'package:ready_ecommerce/views/eCommerce/products/layouts/product_details_layout.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gap/gap.dart';

class EcommerceCategoriesLayout extends ConsumerWidget {
  const EcommerceCategoriesLayout({
    super.key,
  });

  Widget _buildCategoriesSkeleton(
      BuildContext context, int columnCount, WidgetRef ref) {
    return Shimmer.fromColors(
      baseColor: colors(context).accentColor!,
      highlightColor: colors(context).accentColor!.withValues(alpha: 0.5),
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 15.h,
          crossAxisSpacing: 0.w,
          childAspectRatio: columnCount <= 3 ? 0.80 : 0.85,
          crossAxisCount: columnCount,
        ),
        itemCount: 12,
        itemBuilder: (_, __) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            Gap(8.h),
            Container(
              width: 60.w,
              height: 12.h,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Responsive column count based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    int columnCount;

    if (screenWidth < 360) {
      columnCount = 2; // Small phones
    } else if (screenWidth < 600) {
      columnCount = 3; // Medium phones (Pixel 4, etc.)
    } else if (screenWidth < 900) {
      columnCount = 4; // Large phones / Small tablets
    } else {
      columnCount = 5; // Tablets
    }

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return LoadingWrapperWidget(
      isLoading: ref.watch(subCategoryControllerProvider),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Categories'),
          toolbarHeight: 80.h,
        ),
        backgroundColor:
            isDark ? const Color(0xFF121212) : EcommerceAppColor.offWhite,
        body: Consumer(
          builder: (context, ref, _) {
            final asyncValue = ref.watch(categoryControllerProvider);
            return asyncValue.when(
              data: (categoryList) => AnimationLimiter(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(categoryControllerProvider).value;
                  },
                  child: GridView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 15.h,
                      crossAxisSpacing: 0.w,
                      // Adjusted aspect ratio for better readability
                      childAspectRatio: columnCount <= 3 ? 0.80 : 0.85,
                      crossAxisCount: columnCount,
                    ),
                    itemCount: categoryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        columnCount: columnCount,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: CategoryCard(
                                category: categoryList[index],
                                // TODO need to work here
                                onTap: () {
                                  if (categoryList[index]
                                      .subCategories
                                      .isNotEmpty) {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) =>
                                          SubCategoriesBottomSheet(
                                        category: categoryList[index],
                                      ),
                                    );
                                  } else {
                                    GlobalFunction
                                        .navigatorKey.currentContext!.nav
                                        .pushNamed(
                                      Routes.getProductsViewRouteName(
                                        AppConstants.appServiceName,
                                      ),
                                      arguments: [
                                        categoryList[index].id,
                                        categoryList[index].name,
                                        null,
                                        null,
                                        null,
                                        categoryList[index].subCategories,
                                      ],
                                    );
                                  }
                                }),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Text(
                  error.toString(),
                ),
              ),
              loading: () => _buildCategoriesSkeleton(context, columnCount, ref),
            );
          },
        ),
      ),
    );
  }
}
