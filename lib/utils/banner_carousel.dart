import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BannerItem {
  final String imagePath;
  final String tagline;
  BannerItem({required this.imagePath, required this.tagline});
}

class BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;
  final Duration autoScrollInterval;
  const BannerCarousel({
    super.key,
    required this.banners,
    this.autoScrollInterval = const Duration(seconds: 10),
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _controller;
  Timer? _timer;
  // Use index into the looped list; initialPage = 1 (first real item)
  int _page = 1;
  bool _userDragging = false;

  List<BannerItem> get _real => widget.banners;
  List<BannerItem> get _looped {
    if (_real.isEmpty) return [];
    return [_real.last, ..._real, _real.first];
  }

  @override
  void initState() {
    super.initState();

    // If no banners, create a dummy controller (no scrolling)
    if (_real.isEmpty) {
      _controller = PageController();
      return;
    }

    _controller = PageController(initialPage: _page, viewportFraction: 0.95);

    // Precache once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final b in _real) {
        precacheImage(AssetImage(b.imagePath), context);
      }
    });

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoScrollInterval, (timer) {
      if (!mounted || !_controller.hasClients || _userDragging) return;
      final next = _page + 1;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Helper to jump without animation (for seamless loop)
  void _jumpTo(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.jumpToPage(index);
      _page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final looped = _looped;
    if (looped.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text("No banners")),
      );
    }

    final realCount = _real.length;
    final realIndex = (_page - 1) % realCount;
    final height = MediaQuery.of(context).size.height * 0.22;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: NotificationListener<UserScrollNotification>(
            // detect user drag to pause auto-scroll
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.idle) {
                // user stopped interacting
                _userDragging = false;
                _startAutoScroll();
              } else {
                // user started interacting
                _userDragging = true;
                _stopAutoScroll();
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: looped.length,
              physics: const BouncingScrollPhysics(),
              allowImplicitScrolling: true,
              onPageChanged: (i) {
                // Keep page in state
                setState(() => _page = i);

                // If user swiped to the fake last or fake first, jump to the corresponding real page
                if (i == looped.length - 1) {
                  // moved to fake last -> jump to real first (index 1)
                  _jumpTo(1);
                } else if (i == 0) {
                  // moved to fake first -> jump to real last (index looped.length - 2)
                  _jumpTo(looped.length - 2);
                }
              },
              itemBuilder: (context, index) {
                final banner = looped[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          banner.imagePath,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.broken_image)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.44),
                                Colors.transparent
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC857).withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              banner.tagline,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(realCount, (index) {
            final isActive = index == realIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isActive ? 20 : 8,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFFFC857) : Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
