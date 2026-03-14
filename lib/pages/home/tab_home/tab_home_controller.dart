import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/home/home_models.dart';
import '../../../data/repositories/home/home_repository.dart';
import '../../../data/repositories/subject/subject_repository.dart';
import '../../../logger/logger.dart';
import 'home_article_detail_page.dart';

class TabHomeController extends GetxController {
  TabHomeController(this._homeRepository, this._subjectRepository);

  static const int _defaultPage = 1;
  static const int _defaultPageSize = 10;
  static const int _preloadOffset = 220;

  final HomeRepository _homeRepository;
  final SubjectRepository _subjectRepository;

  final pageController = PageController();
  final articleScrollController = ScrollController();
  final currentBannerIndex = 0.obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isLoadingArticleDetail = false.obs;
  final errorText = ''.obs;
  final loadMoreErrorText = ''.obs;

  final banners = <HomeBannerItem>[].obs;
  final articles = <HomeArticleItem>[].obs;

  final page = _defaultPage.obs;
  final pageSize = _defaultPageSize.obs;
  final totalSize = 0.obs;
  final serverTime = 0.obs;

  Timer? _bannerTimer;
  String _subjectId = '';
  String _platform = 'phone';

  bool get hasBanners => banners.isNotEmpty;
  bool get hasArticles => articles.isNotEmpty;
  bool get hasMore => articles.length < totalSize.value;

  @override
  void onInit() {
    super.onInit();
    _platform = _resolvePlatform();
    articleScrollController.addListener(_onArticleScroll);
    loadHomeFeed(reset: true);
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    pageController.dispose();
    articleScrollController.dispose();
    super.onClose();
  }

  Future<void> onRefresh() => loadHomeFeed(reset: true);

  Future<void> loadHomeFeed({required bool reset}) async {
    if (reset) {
      if (isLoading.value) {
        return;
      }
      isLoading.value = true;
      errorText.value = '';
      loadMoreErrorText.value = '';
      page.value = _defaultPage;
      try {
        _subjectId = await _resolveSubjectId();
        final data = await _homeRepository.fetchHomeFeed(
          subjectId: _subjectId,
          platform: _platform,
          page: _defaultPage,
          pageSize: _defaultPageSize,
        );
        banners.assignAll(data.banners);
        articles.assignAll(data.articles);
        page.value = data.page <= 0 ? _defaultPage : data.page;
        pageSize.value = data.pageSize <= 0 ? _defaultPageSize : data.pageSize;
        totalSize.value = data.totalSize;
        serverTime.value = data.serverTime;
        _resetBannerState();
        _restartBannerAutoScroll();
      } catch (e, stackTrace) {
        Logger.e('loadHomeFeed failed', error: e, stackTrace: stackTrace);
        errorText.value = '加载首页内容失败，请稍后重试';
        banners.clear();
        articles.clear();
        totalSize.value = 0;
      } finally {
        isLoading.value = false;
      }
      return;
    }

    await loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) {
      return;
    }
    isLoadingMore.value = true;
    loadMoreErrorText.value = '';
    try {
      final nextPage = page.value + 1;
      final data = await _homeRepository.fetchHomeFeed(
        subjectId: _subjectId,
        platform: _platform,
        page: nextPage,
        pageSize: pageSize.value,
      );
      totalSize.value = data.totalSize;
      serverTime.value = data.serverTime;
      page.value = nextPage;
      _appendDistinctArticles(data.articles);
      if (data.articles.isEmpty) {
        totalSize.value = articles.length;
      }
    } catch (e, stackTrace) {
      Logger.e('loadMoreHomeFeed failed', error: e, stackTrace: stackTrace);
      loadMoreErrorText.value = '加载更多失败，点击重试';
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> retryLoadMore() => loadMore();

  void onPageChanged(int index) {
    currentBannerIndex.value = index;
  }

  Future<void> onArticleTap(HomeArticleItem item) async {
    final articleId = item.id.trim();
    if (articleId.isEmpty || isLoadingArticleDetail.value) {
      return;
    }

    isLoadingArticleDetail.value = true;
    try {
      final detail =
          await _homeRepository.fetchHomeArticle(articleId: articleId);
      await Get.to(() => HomeArticleDetailPage(detail: detail));
    } catch (e, stackTrace) {
      Logger.e('onArticleTap failed', error: e, stackTrace: stackTrace);
      Get.snackbar(
        '提示',
        '资讯详情加载失败，请稍后重试',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingArticleDetail.value = false;
    }
  }

  void _onArticleScroll() {
    if (!articleScrollController.hasClients) {
      return;
    }
    final position = articleScrollController.position;
    if (position.pixels + _preloadOffset >= position.maxScrollExtent) {
      loadMore();
    }
  }

  Future<String> _resolveSubjectId() async {
    final dynamic args = Get.arguments;
    if (args is Map) {
      final value = (args['subjectId'] ?? '').toString().trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    try {
      return await _subjectRepository.getLatestClickedSubjectId();
    } catch (e) {
      Logger.w('resolveSubjectId failed: $e');
      return '';
    }
  }

  String _resolvePlatform() {
    if (GetPlatform.isWeb) {
      return 'web';
    }
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      return 'phone';
    }
    if (GetPlatform.isMacOS || GetPlatform.isWindows || GetPlatform.isLinux) {
      return 'pad';
    }
    return 'phone';
  }

  void _appendDistinctArticles(List<HomeArticleItem> incoming) {
    if (incoming.isEmpty) {
      return;
    }
    final existed = articles.map((item) => item.id).toSet();
    final merged =
        incoming.where((item) => !existed.contains(item.id)).toList();
    if (merged.isEmpty) {
      return;
    }
    articles.addAll(merged);
  }

  void _resetBannerState() {
    currentBannerIndex.value = 0;
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
  }

  void _restartBannerAutoScroll() {
    _bannerTimer?.cancel();
    if (banners.length <= 1) {
      return;
    }
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!pageController.hasClients || banners.isEmpty) {
        return;
      }
      final nextPage = (currentBannerIndex.value + 1) % banners.length;
      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }
}
