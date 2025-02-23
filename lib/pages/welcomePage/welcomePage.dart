import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sigma_new/pages/register/register_page.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {


  @override
  Widget build(BuildContext context){

 //   print("Path of2 ${SdCardUtility.listFilesOnSDCard()}");
    print("Path of1 ${SdCardUtility.getSdcardName()}");
    print("Path ofImae ${SdCardUtility.getIntroImages()}");
  //  print("Path of Sigma ${SdCardUtility.isSigmaDirAvl()}");
 //   print("Path of 12 ${SdCardUtility.getSubjectEncJsonData("12/MH/testseries/sigma_data.json")}");
    print("Path of ENENE ${SdCardUtility.getConfigObject()}");

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          SizedBox(
            height: 180,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                height: 90,
                width: 90,
                child: SvgPicture.asset('assets/svg/logo.svg'),
              ),
            ),
          ),
          Text(
            "Learn anytime anywhere",
            style: black22RegularTextStyle,
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            "Mini school in your pocket in the form of offline tablet",
            style: black12MediumTextStyle,
          ),
          Container(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                  height: 300,
                  width: 300,
                  child: Image.asset('assets/svg/welcome_page.png'))),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff7F0081), // Purple color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // Add navigation or functionality here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.,
                children: const [
                  SizedBox(
                    width: 10,
                  ),
                  Text("Let's Start", style: white18MediumTextStyle),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
