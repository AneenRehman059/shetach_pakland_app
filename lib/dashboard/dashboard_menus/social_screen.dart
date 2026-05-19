import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/colors.dart';
import '../../constants/image_constant.dart';
import '../../controllers/social_controller.dart';
import '../../social_media_links_screen.dart';

class SocialScreen extends StatefulWidget {

  SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final SocialController controller = Get.put(SocialController());
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = screenSize.width * 0.20;
    return Scaffold(
      appBar: AppBar(
        title: Text("Social",style: TextStyle(color: AppColors.whiteBg),),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.3,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/social1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Column(
            children: [
              SizedBox(height: 10,),
              Obx(() {
                if (controller.isLoading.value && controller.branches.isEmpty) {

                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SpinKitWave(
                            color: AppColors.appColor,
                            size: 50.0,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Loading',
                            style: TextStyle(color: AppColors.appColor),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 30,
                      childAspectRatio: 1.1,
                      children: controller.branches.map((branch) {
                        return _buildSocialButton(
                          branch['image_url'] ?? '',
                          branch['brn_code'] ?? '',
                          branch['brn_name'] ?? '',
                          buttonSize,
                          context,
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ],
          ),

          /// Bottom overlay image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/social2.png',
                height: 200,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton( String imageUrl, String brnCode, String brnName, double size, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => SocialMediaLinksScreen(brnCode: brnCode));
        print(brnCode);
      },
      child:Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ClipOval(
                child: Image.asset(
                  ImageConstant.logo,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: 6),
          Text(
            brnName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}