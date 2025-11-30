import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/providers/loader_provider.dart';

// class LoaderService {
//   final Ref ref;
//   OverlayEntry? _overlayEntry;

//   LoaderService(this.ref);

//   void showLoader() {
//     if (_overlayEntry != null) return;

//     ref.read(loaderProvider.notifier).state = true;

//     final context = globalNavigatorKey.currentContext!;
//     final overlay = Overlay.of(context);

//     _overlayEntry = OverlayEntry(
//       builder: (_) => Container(
//         color: Colors.black54,
//         child: const Center(
//           child: CircularProgressIndicator(
//             strokeWidth: 3.5,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );

//     overlay.insert(_overlayEntry!);
//   }

//   void hideLoader() {
//     ref.read(loaderProvider.notifier).state = false;

//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }
// }

// final loaderServiceProvider = Provider<LoaderService>((ref) {
//   return LoaderService(ref);
// });

class LoaderService {
  final Ref ref;
  LoaderService(this.ref);

  void show() {
    ref.read(loaderProvider.notifier).state = true;
  }

  void hide() {
    ref.read(loaderProvider.notifier).state = false;
  }
}

final loaderServiceProvider = Provider<LoaderService>((ref) {
  return LoaderService(ref);
});
