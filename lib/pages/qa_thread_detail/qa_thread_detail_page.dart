import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/question_bank/qa_thread_models.dart';
import '../../i18n/locale_keys.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'qa_thread_detail_controller.dart';

class QaThreadDetailPage extends GetView<QaThreadDetailController> {
  const QaThreadDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text(controller.pageTitle)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          final thread = controller.data;
          if (controller.isLoading.value && thread == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (thread == null) {
            return _ErrorState(
              message: controller.errorText.value.isEmpty
                  ? LocaleKeys.qaThreadDetailMissingThread.tr
                  : controller.errorText.value,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _ThreadHeaderCard(thread: thread),
              const SizedBox(height: AppSpacing.lg),
              _ReplySection(replies: thread.replies),
              if (controller.errorText.value.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _InlineErrorBanner(message: controller.errorText.value),
              ],
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: thread.isClosed || controller.isReplySubmitting.value
                    ? null
                    : controller.openReplyDialog,
                icon: controller.isReplySubmitting.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.reply_outlined),
                label: Text(
                  controller.isReplySubmitting.value
                      ? LocaleKeys.qaThreadDetailReplySubmitting.tr
                      : LocaleKeys.qaThreadDetailReplyAction.tr,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ThreadHeaderCard extends StatelessWidget {
  const _ThreadHeaderCard({
    required this.thread,
  });

  final QaThreadData thread;

  /// 线程头卡片集中展示问题上下文，保证进入详情页后能快速定位所属题目与练习会话。
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            thread.title.trim().isEmpty ? '--' : thread.title.trim(),
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            thread.content.trim().isEmpty
                ? LocaleKeys.qaThreadsContentEmpty.tr
                : thread.content.trim(),
            style: AppTextStyles.body.copyWith(height: 1.7),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            label: LocaleKeys.qaThreadsStatus.tr,
            value: thread.isClosed
                ? LocaleKeys.qaThreadsStatusClosed.tr
                : LocaleKeys.qaThreadsStatusOpen.tr,
          ),
          _InfoRow(
            label: LocaleKeys.qaThreadsQuestionId.tr,
            value: thread.questionId.trim().isEmpty
                ? '--'
                : thread.questionId.trim(),
          ),
          _InfoRow(
            label: LocaleKeys.qaThreadsSessionId.tr,
            value: thread.sessionId.trim().isEmpty
                ? '--'
                : thread.sessionId.trim(),
          ),
          _InfoRow(
            label: LocaleKeys.qaThreadsCreatedAt.tr,
            value: thread.createdAt == null
                ? '--'
                : DateFormat('yyyy-MM-dd HH:mm').format(thread.createdAt!),
          ),
          _InfoRow(
            label: LocaleKeys.qaThreadsLastReplyAt.tr,
            value: thread.lastRepliedAt == null
                ? '--'
                : DateFormat('yyyy-MM-dd HH:mm').format(thread.lastRepliedAt!),
          ),
          if (thread.closeRemark.trim().isNotEmpty)
            _InfoRow(
              label: LocaleKeys.qaThreadDetailCloseRemark.tr,
              value: thread.closeRemark.trim(),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}

class _ReplySection extends StatelessWidget {
  const _ReplySection({
    required this.replies,
  });

  final List<QaReplyData> replies;

  /// 回复区直接消费详情接口返回的 replies，保持与后端最新回复列表一致。
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.qaThreadDetailRepliesTitle.tr,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          if (replies.isEmpty)
            Text(
              LocaleKeys.qaThreadDetailRepliesEmpty.tr,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            ...replies.map(
              (reply) {
                final isAdmin =
                    reply.authorRole.trim().toLowerCase() == 'admin';
                final accent = isAdmin ? AppColors.primary : AppColors.success;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAdmin
                            ? LocaleKeys.qaThreadDetailAuthorAdmin.tr
                            : LocaleKeys.qaThreadDetailAuthorUser.tr,
                        style: AppTextStyles.caption.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        reply.content.trim(),
                        style: AppTextStyles.body.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        reply.createdAt == null
                            ? '--'
                            : DateFormat('yyyy-MM-dd HH:mm')
                                .format(reply.createdAt!),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.16),
        ),
      ),
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
