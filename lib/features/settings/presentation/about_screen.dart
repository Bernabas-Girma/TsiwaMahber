import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.about)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.church,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              S.appName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${S.version} 1.0.0',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(
                    Icons.info_outline,
                    S.about,
                    'Ethiopian Orthodox Tsiwa Mahber Management App\n'
                        'የገላን ፅዋ ማህበሮች አስተዳደር መተግበሪያ',
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.code,
                    S.developer,
                    'Bernabas Girma',
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.email_outlined,
                    S.contact,
                    'bernabasgirma00@gmail.com',
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.calendar_today,
                    '${S.version} Date',
                    '2025',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Features',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _featureChip('Tsiwa Management'),
                  _featureChip('Member Rotation'),
                  _featureChip('Ethiopian Calendar'),
                  _featureChip('Announcements'),
                  _featureChip('Group Chat'),
                  _featureChip('Edir Management'),
                  _featureChip('CSV Import/Export'),
                  _featureChip('Reports & Analytics'),
                  _featureChip('Premium Themes'),
                  _featureChip('Offline Support'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Made with ♥ in Ethiopia',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _featureChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppTheme.success),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
