import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JobCardItem extends StatelessWidget {
  final JobCardListModel item;

  const JobCardItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.sessionId ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          C10(),
          Row(
            children: [
              Image.asset(
                'assets/new/Vector.png',
                width: 18,
                height: 18,
                color: Colors.grey,
              ),
              C5(),
              Expanded(
                child: Text(
                  item.chasisId ?? "",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const CircleAvatar(
                radius: 8,
                backgroundColor: AppColors.primaryColor,
              ),
              C5(),
              Text(
                item.status ?? "",
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          C5(),

          /// MODEL + DATE
          Row(
            children: [
              Image.asset(
                'assets/new/Vector (1).png',
                width: 18,
                height: 18,
                color: Colors.grey,
              ),
              C5(),
              Expanded(
                child: Text(
                  item.modelWithSubmodel ?? "",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              C5(),
              Text(
                item.showStartDate != null
                    ? DateFormat('yyyy-MM-dd')
                        .format(DateTime.parse(item.showStartDate.toString()))
                    : "",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
