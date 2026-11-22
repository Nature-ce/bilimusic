import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileVersionFooter extends StatefulWidget {
  const ProfileVersionFooter({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<ProfileVersionFooter> createState() => _ProfileVersionFooterState();
}

class _ProfileVersionFooterState extends State<ProfileVersionFooter> {
  late final Future<PackageInfo?> _packageInfo = _loadPackageInfo();

  Future<PackageInfo?> _loadPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Center(
            child: FutureBuilder<PackageInfo?>(
              future: _packageInfo,
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo?> snapshot) {
                    final PackageInfo? info = snapshot.data;
                    final String label = info == null
                        ? 'bili-music · 检查更新'
                        : 'bili-music v${info.version} · 检查更新';
                    return Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    );
                  },
            ),
          ),
        ),
      ),
    );
  }
}
