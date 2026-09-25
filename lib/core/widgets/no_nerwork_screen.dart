import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/controllers/internet_connectivity_controller.dart';
class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  final InternetConnectivityController connectivityController =
  Get.put(InternetConnectivityController());
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImageConstant.no_net_bg),
                  fit: BoxFit.cover,
                  opacity: 0.2,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off,size: 100,color: Colors.red,),
                SizedBox(height: 20,),
                Center(child: Text('No Internet Connection',style: TextStyle(
                  color: Colors.grey,fontSize: 16,
                ),),),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: (){
                        connectivityController.checkAndRetrieveData(context);
                      },
                      child: Text(
                        "Retry",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 0.5,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.appColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],),)
        ],
      ),
    );
  }
}