import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'theme.dart';

class WordDetailContent extends StatelessWidget {
  final int level;
  final String hanzi;
  final String? pinyin;
  final String? meanings;
  final bool isLoading;
  final bool compact;

  const WordDetailContent({
    super.key,
    required this.level,
    required this.hanzi,
    this.pinyin,
    this.meanings,
    this.isLoading = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          hanzi,
          style: TextStyle(
            fontSize: compact ? AppTheme.hanziFontSizeCompact : AppTheme.hanziFontSizeLarge,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: compact ? 4 : 8,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColorLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryColor),
          ),
          child: Text(
            l10n.hskLevel(level),
            style: TextStyle(
              fontSize: compact ? 14 : 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        SizedBox(height: compact ? 8 : 16),
        if (isLoading)
          const CircularProgressIndicator()
        else ...[
          if (pinyin != null)
            Text(
              pinyin!,
              style: TextStyle(
                fontSize: compact ? 24 : 32,
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          if (!compact) const Divider(height: 48),
          if (compact) const SizedBox(height: 8),
          Text(
            l10n.meanings,
            style: TextStyle(
              fontSize: compact ? 18 : 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: compact ? 8 : 16),
          if (meanings != null)
            Text(
              meanings!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 16 : 20,
                height: 1.5,
              ),
            ),
        ],
      ],
    );
  }
}
