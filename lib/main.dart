import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/providers/loader_provider.dart';
import 'package:swarn_abhushan/screens/home_screen.dart';
import 'package:swarn_abhushan/screens/login_screen.dart';
import 'package:swarn_abhushan/services/local_storage.dart';
import 'package:swarn_abhushan/theme.dart';
import 'package:swarn_abhushan/utils/constant.dart';
import 'package:swarn_abhushan/utils/loader_animation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  runApp(const ProviderScope(child: SwarnJeweller()));
}

class SwarnJeweller extends StatefulWidget {
  const SwarnJeweller({super.key});

  @override
  State<SwarnJeweller> createState() => _SwarnJewellerState();
}

class _SwarnJewellerState extends State<SwarnJeweller> {
  late Future<Widget> _initialScreenFuture;
  
  @override
  void initState() {
    super.initState();
    _initialScreenFuture = _getInitialScreen();
  }
  
  Future<Widget> _getInitialScreen() async {
    final token = await LocalStorage.getToken();
    final lastRoute = await LocalStorage.getLastRoute();
    if (token != null && token.isNotEmpty) {
      if (lastRoute != null && lastRoute.isNotEmpty) {
        switch (lastRoute) {
          case '/home':
            return const HomeScreen();
          // case '/profile':
          //   return const ProfileScreen();
          default:
            return const HomeScreen();
        }
      }
      return const HomeScreen();
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      title: 'Swarn Abhushan',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          FutureBuilder(
            future: _initialScreenFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else {
                return snapshot.data!;
              }
            },
          ),

          /// 🔥 GLOBAL FADE-IN LOADER OVERLAY
          Consumer(
            builder: (context, ref, _) {
              final isLoading = ref.watch(loaderProvider);

              return IgnorePointer(
                ignoring: !isLoading,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  opacity: isLoading ? 1.0 : 0.0,
                  child: Container(
                    color: Colors.black54,
                    child: const Center(child: LoaderAnimation()),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
