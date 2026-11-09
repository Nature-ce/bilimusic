enum UpdateSource {
  fork(
    repo: 'Nature-ce/bilimusic',
    label: '本仓库',
    description: '跟随本仓库发布的版本，包含本仓库的功能改进与修复',
  ),
  upstream(
    repo: 'AprDeci/bili-music',
    label: '上游仓库',
    description: '跟随上游原版发布的版本，更新节奏与上游一致',
  );

  const UpdateSource({
    required this.repo,
    required this.label,
    required this.description,
  });

  final String repo;
  final String label;
  final String description;

  String get releaseApiUrl =>
      'https://api.github.com/repos/$repo/releases/latest';

  String get releaseListUrl => 'https://github.com/$repo/releases';

  String get issuesUrl => 'https://github.com/$repo/issues/new';

  String get repositoryUrl => 'https://github.com/$repo';

  List<UpdateSource> get lookupOrder => <UpdateSource>[
    this,
    if (this != UpdateSource.upstream) UpdateSource.upstream,
  ];

  static UpdateSource fromName(String? name) {
    final String trimmed = name?.trim() ?? '';
    for (final UpdateSource source in values) {
      if (source.name == trimmed) {
        return source;
      }
    }
    return fork;
  }
}
