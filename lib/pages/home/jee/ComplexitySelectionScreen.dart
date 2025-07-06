import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sigma_new/models/menu_models.dart';
import 'package:sigma_new/ui_helper/constant.dart';

import 'jee_subjectwise.dart';

class ComplexitySelectionScreen extends StatelessWidget {
  const ComplexitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Menu> studyMenu = [
      Menu(
          color: 0xFFF2C6DF,
          imagePath: 'assets/svg/exam_prep.svg',
          navigation: () {

          },
          title: 'Elementry Concept'),
      Menu(
          color: 0xFFC5DEF2,
          imagePath: 'assets/svg/exam_prep.svg',
          navigation: () {

          },
          title: 'Advanced Concept'),

    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Complextity'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width * 0.9,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: studyMenu.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      if(index==0){
                        Get.to(JeeSubjectwise(path: "Concept",complex: "e",));}
                      else if(index==1){
                        Get.to(JeeSubjectwise(path: "Concept", complex: "a",));
                      }
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.13,
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(studyMenu[index].color),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SvgPicture.asset(
                          studyMenu[index].imagePath, // Correct interpolation
                          height: 30,
                          width: 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    studyMenu[index].title,
                    style: black14w400MediumTextStyle,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildComplexityButton(String title, String complexity, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Get.to(() => JeeSubjectwise(
          path: '$title Concepts',
          complexity: complexity,
          isConcept: true,
        ));
      },
      child: Text(title),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50),
      ),
    );
  }
}