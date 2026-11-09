enum DownloadTaskStatus { queued, running, failed }

class DownloadTask {
  const DownloadTask({
    required this.contentId,
    required this.status,
    this.title = '',
    this.author = '',
    this.coverUrl = '',
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.errorMessage,
  });

  final String contentId;
  final DownloadTaskStatus status;
  final String title;
  final String author;
  final String coverUrl;
  final int receivedBytes;
  final int totalBytes;
  final String? errorMessage;

  double? get progress {
    if (totalBytes <= 0) {
      return null;
    }
    return (receivedBytes / totalBytes).clamp(0.0, 1.0);
  }

  bool get isActive =>
      status == DownloadTaskStatus.queued ||
      status == DownloadTaskStatus.running;

  bool get isFailed => status == DownloadTaskStatus.failed;

  String get displayTitle => title.trim().isEmpty ? contentId : title.trim();

  DownloadTask copyWith({
    DownloadTaskStatus? status,
    int? receivedBytes,
    int? totalBytes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DownloadTask(
      contentId: contentId,
      status: status ?? this.status,
      title: title,
      author: author,
      coverUrl: coverUrl,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
