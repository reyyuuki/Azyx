import 'package:flutter/material.dart';

typedef ButtonTapCallback = void Function(String? index);

class Sliderbar extends StatefulWidget {
  final Widget child;
  final String? title;
  final String? chapter;
  final int? totalImages;
  final ScrollController scrollController;
  final ButtonTapCallback handleChapter;

  const Sliderbar({
    super.key,
    required this.child,
    required this.title,
    required this.chapter,
    required this.totalImages,
    required this.scrollController,
    required this.handleChapter,
  });

  @override
  State<Sliderbar> createState() => _SlidebarState();
}

class _SlidebarState extends State<Sliderbar> {
  bool _areBarsVisible = false;
  double _scrollProgress = 0.0;
  int _currentPage = 1;

  void _toggleBarsVisibility() {
    setState(() {
      _areBarsVisible = !_areBarsVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateScrollProgress);
  }

  void _updateScrollProgress() {
    if (widget.scrollController.hasClients && widget.totalImages! > 0) {
      final maxScrollExtent = widget.scrollController.position.maxScrollExtent;
      final currentScroll = widget.scrollController.position.pixels;
      final progress = currentScroll / maxScrollExtent;

      setState(() {
        _scrollProgress = progress.clamp(0.0, 1.0);
        _currentPage = ((progress * (widget.totalImages! - 1)) + 1).round();
      });
    }
  }

  void _onProgressBarTap(double progress) {
    if (widget.scrollController.hasClients) {
      final targetPage = (progress * (widget.totalImages! - 1)).round();

      widget.scrollController.jumpTo(
        targetPage *
            (widget.scrollController.position.maxScrollExtent /
                (widget.totalImages! - 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onTap: _toggleBarsVisibility,
              child: widget.child,
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _areBarsVisible ? 0 : -80,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.9),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.surface,),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16,  color: Theme.of(context).colorScheme.surface,)),
                        const SizedBox(height: 3),
                        Text(widget.chapter!,
                            style: TextStyle(fontSize: 12,  color: Theme.of(context).colorScheme.surface,)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _areBarsVisible ? 25 : -100,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: Colors.transparent,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.skip_previous, color: Theme.of(context).colorScheme.surface,),
                            onPressed: () {
                              widget.handleChapter('right');
                            },
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.8),
                            ),
                            child: Slider(
                              thumbColor: Theme.of(context).colorScheme.inversePrimary,
                              value: _scrollProgress,
                              onChanged: (value) {
                                setState(() {
                                  _scrollProgress = value;
                                });
                                _onProgressBarTap(value);
                              },
                              activeColor: Theme.of(context).colorScheme.inversePrimary,
                              inactiveColor: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.skip_next, color: Theme.of(context).colorScheme.surface,),
                            onPressed: () {
                              widget.handleChapter('left');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Text(
                            '$_currentPage / ${widget.totalImages}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateScrollProgress);
    super.dispose();
  }
}