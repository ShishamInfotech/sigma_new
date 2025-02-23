import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/pages/10thMh/10thmh.dart';
import 'package:sigma_new/ui_helper/constant.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  @override
  Widget build(BuildContext context) {
    List<Menu> othersMenuList = [
      Menu(
          color: 0xFFFAEDCB, // Corrected color code
          imagePath: 'assets/svg/10_mh.svg',
          navigation: () {
            Get.to(StandardMenu());
          },
          title: '10th MH'),
      Menu(
          color: 0xFFC9E4DF,
          imagePath: 'assets/svg/12_mh.svg',
          navigation: () {
            Get.to(StandardMenu());
          },
          title: '12th MH PCMB'),
      Menu(
          color: 0xFFC5DEF2,
          imagePath: 'assets/svg/jee_cet_neet.svg',
          navigation: () {
            Get.to(StandardMenu(standard: "jee",));
          },
          title: 'JEE CEE NEET'),
      Menu(
          color: 0xFFDBCDF0,
          imagePath: 'assets/svg/engg.svg',
          navigation: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("UI not defined in WireFrame"),
                duration: Duration(seconds: 2),
              ),
            );
          },
          title: 'Engineer'),
    ];
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * 0.9,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 6,
                  childAspectRatio: 0.6,
                ),
                itemCount: othersMenuList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // Navigation logic here
                          if (othersMenuList[index].navigation != null) {
                            othersMenuList[index].navigation!();
                          } else {
                            print(
                                'No navigation route defined for this menu item');
                          }
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.13,
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(othersMenuList[index].color),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 63.0, top: 6),
                                child: SvgPicture.asset(
                                  'assets/svg/arrow.svg', // Correct interpolation
                                  height: 20,
                                  width: 20,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, left: 10.0, bottom: 5, right: 10),
                                child: SvgPicture.asset(
                                  othersMenuList[index]
                                      .imagePath, // Correct interpolation
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        othersMenuList[index].title,
                        style: black14w400MediumTextStyle,
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
