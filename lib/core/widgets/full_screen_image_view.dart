import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImageView extends StatefulWidget {
  final String imageUrl;
  final List<String> allImages;
  final int initialIndex;

  const FullScreenImageView({
    super.key,
    required this.imageUrl,
    required this.allImages,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {

  late int currentIndex;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 300) {
          Navigator.pop(context);
        }
      },

      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "${currentIndex + 1} / ${widget.allImages.length}",
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: PhotoViewGallery.builder(
          pageController: pageController,
          itemCount: widget.allImages.length,
          scrollPhysics: const BouncingScrollPhysics(),

          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(widget.allImages[index]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              heroAttributes: PhotoViewHeroAttributes(
                tag: widget.allImages[index],
              ),
            );
          },

          loadingBuilder: (context, event) => const Center(
            child: AppLoader(),
          ),

          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}