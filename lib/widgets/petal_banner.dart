import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// No platform view (and no SDK call) until the user opts in separately.
class PetalBanner extends StatelessWidget {
  const PetalBanner({super.key, required this.allowed});
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    if (!allowed || kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }
    // A fixed 320dp banner cannot safely be displayed on a narrower surface.
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 320) return const SizedBox.shrink();
      return SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: Center(
            child: SizedBox(
              width: 320,
              height: 50,
              child: AndroidView(
                viewType: 'com.floatingbutton.app/petal_banner',
                creationParams: const {
                  // Debug builds and explicitly requested test builds use test ads.
                  'test': !kReleaseMode || bool.fromEnvironment('PETAL_ADS_TEST'),
                },
                creationParamsCodec: const StandardMessageCodec(),
              ),
            ),
          ),
        ),
      );
    });
  }
}
