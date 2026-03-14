import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question_bank/practice_report_models.dart';
import '../../i18n/locale_keys.dart';
import 'chapter_stats_card.dart';

class QuestionCategoryStatsCard extends StatelessWidget {
  const QuestionCategoryStatsCard({
    required this.stats,
    super.key,
  });

  final List<PracticeReportStatData> stats;

  @override
  Widget build(BuildContext context) {
    return QuestionBankStatsCard(
      title: LocaleKeys.practiceReportCategoryTitle.tr,
      emptyText: LocaleKeys.practiceReportNoStats.tr,
      stats: stats,
    );
  }
}
