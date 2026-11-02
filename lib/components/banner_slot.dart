import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app_scope.dart';
import '../config/tokens.dart';
import '../l10n/app_localizations.dart';

class BannerSlot extends StatelessWidget {
  const BannerSlot({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<BannerAd?>(
      valueListenable: AppScope.of(context).ads.banner,
      builder: (context, ad, _) {
        if (ad == null) {
          return SizedBox(
            height: 50,
            width: double.infinity,
            child: ColoredBox(
              color: AppColors.blueInk,
              child: Center(
                child: Text(
                  l10n.adSlot,
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ),
          );
        }
        return SizedBox(
          height: ad.size.height.toDouble(),
          width: ad.size.width.toDouble(),
          child: AdWidget(ad: ad),
        );
      },
    );
  }
}
