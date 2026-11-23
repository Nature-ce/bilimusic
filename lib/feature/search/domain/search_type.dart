enum SearchType { video, up }

extension SearchTypeExtension on SearchType {
  String get apiValue {
    switch (this) {
      case SearchType.video:
        return 'video';
      case SearchType.up:
        return 'bili_user';
    }
  }
}
