import 'package:flutter/material.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/app_bar.dart';

class EventImagesScreen extends StatelessWidget {
  const EventImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: CustomAppBar(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Images',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteBg,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: const [
                    EventImageItem(
                      imagePath: 'assets/images/ei1.jpg',
                      height: 170,
                    ),
                    SizedBox(height: 20),
                    EventImageItem(
                      imagePath: 'assets/images/ei2 .jpg',
                      height: 170,
                    ),
                    SizedBox(height: 20),
                    EventImageItem(
                      imagePath: 'assets/images/ei3.jpg',
                      height: 170,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventImageItem extends StatelessWidget {
  final String imagePath;
  final double height;

  const EventImageItem({
    super.key,
    required this.imagePath,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
