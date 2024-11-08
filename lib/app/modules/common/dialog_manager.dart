
import 'package:flutter/material.dart';
import 'package:flutter_plus/flutter_plus.dart';

import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

class DialogManager {
  

  void showSnackbar(String title, String message) {
     Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      forwardAnimationCurve: Curves.elasticInOut,
      reverseAnimationCurve: Curves.easeOut,
    );
  }

  void showDialog(String title, String message) {

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.brown,
        title:  TextPlus(title, color: Colors.white, fontSize: 30,),
        content:  TextPlus(message , color: Colors.white, fontSize: 22,),
        actions: [
          GFButton(
              onPressed: () {
                Get.back();
              },
              size: GFSize.LARGE,
              color: Colors.brown.shade800,
              //blockButton: true,
              child: TextPlus('Ok', fontSize: 24, color: Colors.white,),
            ),
        ],
      ),
    );
  }
}