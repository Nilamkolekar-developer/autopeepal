import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:autopeepal/utils/ui_helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDropdownTextField extends StatelessWidget {
  final RxString selectedValue;
  final List<String> items;
  final String hint;
  final String title;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double? iconSize;
  final bool readOnly;

  // NEW
  final bool enabled;
  final VoidCallback? onTapDisabled;

  const CustomDropdownTextField({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.title,
    this.hint = "Select",
    this.textStyle,
    this.iconColor,
    this.iconSize,
    this.readOnly = true,
    this.enabled = true,
    this.onTapDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 3,
              blurRadius: 4,
              offset: const Offset(5, 6),
            ),
          ],
        ),
        child: TextField(
          readOnly: readOnly,
          controller: TextEditingController(
              text: selectedValue.value.isEmpty ? "" : selectedValue.value),
          style: textStyle,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: iconColor ?? Colors.blue,
              size: iconSize ?? 30,
            ),
          ),
          onTap: () {
            if (!enabled) {
              if (onTapDisabled != null) {
                onTapDisabled!();
              }
              return;
            }
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        color: AppColors.primaryColor, width: 6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          color: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              color: Colors.white,
                              child: Column(
                                children: items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: InkWell(
                                      onTap: () {
                                        selectedValue.value = item;
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.4),
                                          border: Border.all(
                                              color: Colors.grey.shade400),
                                        ),
                                        child: Text(
                                          item,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        C100()
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    });
  }
}

class CustomDropdownTextField1 extends StatelessWidget {
  final RxString selectedValue;
  final List<String> items;
  final String hint;
  final String title; // used as label
  final TextStyle? textStyle;
  final Color? iconColor;
  final double? iconSize;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTapDisabled;

  const CustomDropdownTextField1({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.title,
    this.hint = "Select",
    this.textStyle,
    this.iconColor,
    this.iconSize,
    this.readOnly = true,
    this.enabled = true,
    this.onTapDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label above the textfield
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: "OpenSans-Regular",
            ),
          ),
          C2(),
          TextField(
            readOnly: readOnly,
            controller: TextEditingController(
                text: selectedValue.value.isEmpty ? "" : selectedValue.value),
            style: TextStyles.textfieldTextStyle2,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyles.hintStyle1,
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3),
                        child: Container(
                          width: 2,
                          color: AppColors.primaryColor,
                          margin: const EdgeInsets.only(right: 6),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: iconColor ?? AppColors.primaryColor,
                        size: iconSize ?? 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {
              if (!enabled) {
                if (onTapDisabled != null) onTapDisabled!();
                return;
              }

              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: AppColors.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            color: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              title.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                color: Colors.white,
                                child: Column(
                                  children: items.map((item) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: InkWell(
                                        onTap: () {
                                          selectedValue.value = item;
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor
                                                .withOpacity(0.4),
                                            border: Border.all(
                                                color: Colors.grey.shade400),
                                          ),
                                          child: Text(
                                            item,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          C100()
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      );
    });
  }
}

class CustomSearchDropdown extends StatelessWidget {
  final RxString selectedValue;
  final List<String> items;
  final String hint;
  final String? title;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double? iconSize;
  final VoidCallback? onFolderTap;
  final bool showFolderIcon;

  CustomSearchDropdown({
    Key? key,
    required this.selectedValue,
    required this.items,
    this.title,
    this.hint = "Select",
    this.textStyle,
    this.iconColor,
    this.iconSize,
    this.onFolderTap,
    this.showFolderIcon = true,
  }) : super(key: key);

  final RxList<String> filteredItems = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 3,
              blurRadius: 4,
              offset: const Offset(5, 6),
            ),
          ],
        ),
        child: TextField(
          readOnly: true,
          controller: TextEditingController(
            text: selectedValue.value,
          ),
          style: TextStyles.textfieldTextStyle1,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: iconColor ?? AppColors.primaryColor,
              size: iconSize ?? 30,
            ),
          ),
          onTap: () {
            filteredItems.value = items;

            showDialog(
              context: context,
              builder: (_) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        color: AppColors.primaryColor, width: 6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: Column(
                      children: [
                        /// HEADER (Title + Search)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                          ),
                          child: Column(
                            children: [
                              if (title != null)
                                Text(
                                  title!.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),

                              const SizedBox(height: 12),

                              /// Search Row
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      style: TextStyles.textfieldTextStyle1,
                                      cursorColor: Colors.black,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        hintText: 'Search...',
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 12,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          size: 22,
                                        ),
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                          minHeight: 30,
                                          minWidth: 35,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          //      borderSide: BorderSide(
                                          //   color: AppColors.white,
                                          // ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: AppColors.white,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: AppColors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        filteredItems.value = items
                                            .where((item) => item
                                                .toLowerCase()
                                                .contains(value.toLowerCase()))
                                            .toList();
                                      },
                                    ),
                                  ),

                                  /// Folder Icon (optional)
                                  if (showFolderIcon && onFolderTap != null)
                                    InkWell(
                                      onTap: onFolderTap,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Image.asset(
                                          "assets/new/ic_opened_folder.png",
                                          height: 34,
                                          width: 34,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        /// LIST SECTION
                        Expanded(
                          child: Obx(() {
                            if (filteredItems.isEmpty) {
                              return const Center(
                                child: Text("No data found"),
                              );
                            }

                            return Container(
                              color: Colors.white,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: InkWell(
                                      onTap: () {
                                        selectedValue.value = item;
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.3),
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: Text(
                                          item,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),

                        C100(),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    });
  }
}
