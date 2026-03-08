import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/subject/subject_models.dart';
import 'subject_controller.dart';

class SubjectPage extends GetView<SubjectController> {
  const SubjectPage({super.key});

  static const _pageBg = Color(0xFFF5F6F8);
  static const _leftBg = Colors.white;
  static const _searchFieldBg = Color(0xFFF4F5F7);
  static const _rightBg = Color(0xFFF6F7F9);
  static const _primaryBlue = Color(0xFF3B82F6);
  static const _textMain = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Obx(() {
          if (controller.isPageLoading.value && controller.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorText.value.isNotEmpty &&
              controller.categories.isEmpty) {
            return _buildError();
          }

          return Column(
            children: [
              _buildSearch(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const leftWidth = 110.0;
                    return Row(
                      children: [
                        SizedBox(width: leftWidth, child: _buildLeftMenu()),
                        Expanded(
                          child:
                              _buildRightPane(constraints.maxWidth - leftWidth),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _leftBg,
      surfaceTintColor: _leftBg,
      centerTitle: true,
      leadingWidth: 56,
      leading: IconButton(
        onPressed: Get.back,
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      ),
      title: const Text(
        '选择我的考试',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      color: _leftBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 46,
        decoration: BoxDecoration(
          color: _searchFieldBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 20, color: _textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                decoration: const InputDecoration(
                  hintText: '请输入内容',
                  hintStyle: TextStyle(
                    color: _textSecondary,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftMenu() {
    return Container(
      color: _leftBg,
      child: Obx(
        () => ListView.builder(
          itemCount: controller.categories.length,
          itemBuilder: (_, index) {
            final category = controller.categories[index];
            final selected = category.id == controller.selectedCategoryId.value;
            return InkWell(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                controller.onCategoryTap(category.id);
              },
              child: Container(
                height: 52,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    if (selected)
                      Container(
                        width: 3,
                        height: 18,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                          color: selected ? _textMain : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRightPane(double availableWidth) {
    return Obx(() {
      final selectedSubjectId = controller.selectedSubjectId.value;

      if (controller.isGroupLoading.value && controller.groups.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorText.value.isNotEmpty && controller.groups.isEmpty) {
        return _buildError();
      }

      if (controller.groups.isEmpty) {
        return const Center(
          child: Text(
            '该分类下暂无科目',
            style: TextStyle(color: _textSecondary),
          ),
        );
      }

      return Container(
        color: _rightBg,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: controller.groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (_, index) {
            final group = controller.groups[index];
            return _buildTagSection(
              group,
              availableWidth - 32,
              selectedSubjectId,
            );
          },
        ),
      );
    });
  }

  Widget _buildTagSection(
    SubjectGroupItem group,
    double availableWidth,
    String selectedSubjectId,
  ) {
    final crossAxisCount = (availableWidth / 170).floor().clamp(2, 4);
    final childAspectRatio = switch (crossAxisCount) {
      2 => 1.0,
      3 => 1.08,
      _ => 1.16,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.tag.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textMain,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: group.subjects.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (_, index) {
            final subject = group.subjects[index];
            final selected = subject.id == selectedSubjectId;
            return _SubjectCard(
              title: subject.name,
              selected: selected,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                controller.onSubjectTap(subject.id);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('加载失败，请重试'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: controller.loadInitial,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? SubjectPage._primaryBlue
                    : const Color(0xFFF1F3F7),
                width: selected ? 1.2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_rounded, size: 30),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: SubjectPage._textMain,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: SubjectPage._primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(14),
                    topLeft: Radius.circular(14),
                  ),
                ),
                child: const Icon(Icons.check, size: 15, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
