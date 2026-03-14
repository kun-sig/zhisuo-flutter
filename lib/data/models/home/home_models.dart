/// 首页横幅点击行为。
class HomeBannerAction {
  final String type;
  final String url;

  const HomeBannerAction({
    required this.type,
    required this.url,
  });

  factory HomeBannerAction.fromJson(Map<String, dynamic> json) {
    return HomeBannerAction(
      type: (json['type'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
    );
  }
}

/// 首页横幅叠加层信息。
class HomeBannerOverlay {
  final String position;
  final String text;
  final String component;
  final HomeBannerAction action;

  const HomeBannerOverlay({
    required this.position,
    required this.text,
    required this.component,
    required this.action,
  });

  factory HomeBannerOverlay.fromJson(Map<String, dynamic> json) {
    return HomeBannerOverlay(
      position: (json['position'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      component: (json['component'] ?? '').toString(),
      action: HomeBannerAction.fromJson(_toMap(json['action'])),
    );
  }
}

/// 首页横幅模型。
class HomeBannerItem {
  final String id;
  final String title;
  final String imageUrl;
  final int sortOrder;
  final String status;
  final int startTime;
  final int endTime;
  final String platform;
  final String subjectId;
  final HomeBannerOverlay overlay;
  final int createdAt;
  final int updatedAt;
  final String imageObjectId;

  const HomeBannerItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.sortOrder,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.platform,
    required this.subjectId,
    required this.overlay,
    required this.createdAt,
    required this.updatedAt,
    required this.imageObjectId,
  });

  factory HomeBannerItem.fromJson(Map<String, dynamic> json) {
    return HomeBannerItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      sortOrder: _toInt(json['sortOrder']),
      status: (json['status'] ?? '').toString(),
      startTime: _toInt(json['startTime']),
      endTime: _toInt(json['endTime']),
      platform: (json['platform'] ?? '').toString(),
      subjectId: (json['subjectId'] ?? '').toString(),
      overlay: HomeBannerOverlay.fromJson(_toMap(json['overlay'])),
      createdAt: _toInt(json['createdAt']),
      updatedAt: _toInt(json['updatedAt']),
      imageObjectId: (json['imageObjectId'] ?? '').toString(),
    );
  }
}

/// 首页资讯模型。
class HomeArticleItem {
  final String id;
  final String title;
  final String summary;
  final String coverUrl;
  final String tag;
  final int publishedAt;
  final int viewCount;
  final int sortOrder;
  final String status;
  final String platform;
  final String subjectId;
  final String jumpType;
  final String jumpUrl;
  final int createdAt;
  final int updatedAt;
  final String currentVersionId;
  final int currentVersion;
  final int wordCount;
  final int contentUpdatedAt;

  const HomeArticleItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.coverUrl,
    required this.tag,
    required this.publishedAt,
    required this.viewCount,
    required this.sortOrder,
    required this.status,
    required this.platform,
    required this.subjectId,
    required this.jumpType,
    required this.jumpUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.currentVersionId,
    required this.currentVersion,
    required this.wordCount,
    required this.contentUpdatedAt,
  });

  HomeArticleItem copyWith({
    String? id,
    String? title,
    String? summary,
    String? coverUrl,
    String? tag,
    int? publishedAt,
    int? viewCount,
    int? sortOrder,
    String? status,
    String? platform,
    String? subjectId,
    String? jumpType,
    String? jumpUrl,
    int? createdAt,
    int? updatedAt,
    String? currentVersionId,
    int? currentVersion,
    int? wordCount,
    int? contentUpdatedAt,
  }) {
    return HomeArticleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      coverUrl: coverUrl ?? this.coverUrl,
      tag: tag ?? this.tag,
      publishedAt: publishedAt ?? this.publishedAt,
      viewCount: viewCount ?? this.viewCount,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      platform: platform ?? this.platform,
      subjectId: subjectId ?? this.subjectId,
      jumpType: jumpType ?? this.jumpType,
      jumpUrl: jumpUrl ?? this.jumpUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentVersionId: currentVersionId ?? this.currentVersionId,
      currentVersion: currentVersion ?? this.currentVersion,
      wordCount: wordCount ?? this.wordCount,
      contentUpdatedAt: contentUpdatedAt ?? this.contentUpdatedAt,
    );
  }

  factory HomeArticleItem.fromJson(Map<String, dynamic> json) {
    return HomeArticleItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      coverUrl: (json['coverUrl'] ?? '').toString(),
      tag: (json['tag'] ?? '').toString(),
      publishedAt: _toInt(json['publishedAt']),
      viewCount: _toInt(json['viewCount']),
      sortOrder: _toInt(json['sortOrder']),
      status: (json['status'] ?? '').toString(),
      platform: (json['platform'] ?? '').toString(),
      subjectId: (json['subjectId'] ?? '').toString(),
      jumpType: (json['jumpType'] ?? '').toString(),
      jumpUrl: (json['jumpUrl'] ?? '').toString(),
      createdAt: _toInt(json['createdAt']),
      updatedAt: _toInt(json['updatedAt']),
      currentVersionId: (json['currentVersionId'] ?? '').toString(),
      currentVersion: _toInt(json['currentVersion']),
      wordCount: _toInt(json['wordCount']),
      contentUpdatedAt: _toInt(json['contentUpdatedAt']),
    );
  }
}

/// 资讯正文版本模型。
class HomeArticleContent {
  final String id;
  final String articleId;
  final int version;
  final String tiptapJson;
  final String htmlContent;
  final String plainText;
  final String contentHash;
  final String renderEngineVersion;
  final String createdBy;
  final int createdAt;
  final int updatedAt;

  const HomeArticleContent({
    required this.id,
    required this.articleId,
    required this.version,
    required this.tiptapJson,
    required this.htmlContent,
    required this.plainText,
    required this.contentHash,
    required this.renderEngineVersion,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HomeArticleContent.fromJson(Map<String, dynamic> json) {
    return HomeArticleContent(
      id: (json['id'] ?? '').toString(),
      articleId: (json['articleId'] ?? '').toString(),
      version: _toInt(json['version']),
      tiptapJson: (json['tiptapJson'] ?? '').toString(),
      htmlContent: (json['htmlContent'] ?? '').toString(),
      plainText: (json['plainText'] ?? '').toString(),
      contentHash: (json['contentHash'] ?? '').toString(),
      renderEngineVersion: (json['renderEngineVersion'] ?? '').toString(),
      createdBy: (json['createdBy'] ?? '').toString(),
      createdAt: _toInt(json['createdAt']),
      updatedAt: _toInt(json['updatedAt']),
    );
  }
}

/// 资讯详情模型（元数据 + 正文）。
class HomeArticleDetailData {
  final HomeArticleItem article;
  final HomeArticleContent content;

  const HomeArticleDetailData({
    required this.article,
    required this.content,
  });

  factory HomeArticleDetailData.fromJson(Map<String, dynamic> json) {
    return HomeArticleDetailData(
      article: HomeArticleItem.fromJson(_toMap(json['article'])),
      content: HomeArticleContent.fromJson(_toMap(json['content'])),
    );
  }
}

/// 首页聚合数据模型（横幅 + 资讯）。
class HomeFeedData {
  final List<HomeBannerItem> banners;
  final List<HomeArticleItem> articles;
  final int page;
  final int pageSize;
  final int totalSize;
  final int serverTime;

  const HomeFeedData({
    required this.banners,
    required this.articles,
    required this.page,
    required this.pageSize,
    required this.totalSize,
    required this.serverTime,
  });

  factory HomeFeedData.fromJson(Map<String, dynamic> json) {
    final banners =
        _toMapList(json['banners']).map(HomeBannerItem.fromJson).toList();
    final articles =
        _toMapList(json['articles']).map(HomeArticleItem.fromJson).toList();
    return HomeFeedData(
      banners: banners,
      articles: articles,
      page: _toInt(json['page']),
      pageSize: _toInt(json['pageSize']),
      totalSize: _toInt(json['totalSize']),
      serverTime: _toInt(json['serverTime']),
    );
  }
}

Map<String, dynamic> _toMap(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}

List<Map<String, dynamic>> _toMapList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw.map(_toMap).toList();
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
