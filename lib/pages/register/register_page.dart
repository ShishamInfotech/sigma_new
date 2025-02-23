// lib/pages/register/register_page.dart
import 'package:flutter/material.dart';
import 'package:sigma_new/config/config_loader.dart';
import 'package:sigma_new/pages/register/register_succes.dart';
import 'package:sigma_new/ui_helper/constant.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? selectedTitle;
  EnrolConfigStandard? selectedStandard;
  EnrolConfigBoard? selectedBoard;
  EnrolConfigCourses? selectedCourse;

  late Future<Map<String, dynamic>> enrolDataFuture;

  @override
  void initState() {
    super.initState();
    enrolDataFuture = Future.wait([
      ConfigLoader.getEnrolConfigStandard(),
      ConfigLoader.getEnrolConfigBoard(),
      ConfigLoader.getEnrolConfigCourses(),
    ]).then((results) {
      return {
        'standard': results[0] ?? [],
        'board': results[1] ?? [],
        'courses': results[2] ?? [],
      };
    });
  }

  /// Filters courses based on selected Standard and Board.
  List<EnrolConfigCourses> getFilteredCourses(List<EnrolConfigCourses> courses) {
    if (selectedStandard != null && selectedBoard != null) {
      final filterKey = "${selectedStandard!.stdID}_${selectedBoard!.boardKey}";
      return courses.where((course) => course.stdBoardKey == filterKey).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: enrolDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Error loading enrollment configurations")),
          );
        }
        final standardList = snapshot.data!['standard'] as List<EnrolConfigStandard>;
        final boardList = snapshot.data!['board'] as List<EnrolConfigBoard>;
        final coursesList = snapshot.data!['courses'] as List<EnrolConfigCourses>;

        // Hardcoded title dropdown values.
        final titleList = ["Mr", "Ms"];
        // Filter courses based on selected standard and board.
        final filteredCourses = getFilteredCourses(coursesList);

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Center(
                  child: Card(
                    elevation: 6,
                    shadowColor: blackColor,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("Registration", style: black20w400MediumTextStyle),
                          ),
                          const Text("Register to your account", style: grey14MediumTextStyle),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title Dropdown
                                const Text("Title", style: black16MediumTextStyle),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 1),
                                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  height: MediaQuery.of(context).size.height * 0.05,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedTitle,
                                        isExpanded: true,
                                        hint: const Text("Select", style: grey16MediumTextStyle),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedTitle = newValue;
                                          });
                                        },
                                        items: titleList.map((valueItem) {
                                          return DropdownMenuItem<String>(
                                            value: valueItem,
                                            child: Text(valueItem),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                // First Name Field
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text("First Name", style: black16MediumTextStyle),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  height: MediaQuery.of(context).size.height * 0.05,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                      hintText: "First Name",
                                      hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                        gapPadding: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                // Last Name Field
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text("Last Name", style: black16MediumTextStyle),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  height: MediaQuery.of(context).size.height * 0.05,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                      hintText: "Last Name",
                                      hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                        gapPadding: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                // Standard Dropdown
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text("Standard", style: black16MediumTextStyle),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 1),
                                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  height: MediaQuery.of(context).size.height * 0.05,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<EnrolConfigStandard>(
                                        value: selectedStandard,
                                        isExpanded: true,
                                        hint: const Text("Select", style: grey16MediumTextStyle),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedStandard = newValue;
                                            // When standard changes, reset the course selection.
                                            selectedCourse = null;
                                          });
                                        },
                                        items: standardList.map((valueItem) {
                                          return DropdownMenuItem<EnrolConfigStandard>(
                                            value: valueItem,
                                            child: Text(valueItem.name),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                // Board Dropdown
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text("Board", style: black16MediumTextStyle),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 1),
                                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  height: MediaQuery.of(context).size.height * 0.05,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<EnrolConfigBoard>(
                                        value: selectedBoard,
                                        isExpanded: true,
                                        hint: const Text("Select", style: grey16MediumTextStyle),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedBoard = newValue;
                                            // When board changes, reset course selection.
                                            selectedCourse = null;
                                          });
                                        },
                                        items: boardList.map((valueItem) {
                                          return DropdownMenuItem<EnrolConfigBoard>(
                                            value: valueItem,
                                            child: Text(valueItem.board),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                // Courses Dropdown (dependent on Standard & Board)
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text("Courses", style: black16MediumTextStyle),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 1),
                                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  height: MediaQuery.of(context).size.height * 0.05,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<EnrolConfigCourses>(
                                        value: selectedCourse,
                                        isExpanded: true,
                                        hint: const Text("Select", style: grey16MediumTextStyle),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedCourse = newValue;
                                          });
                                        },
                                        items: getFilteredCourses(coursesList).map((valueItem) {
                                          return DropdownMenuItem<EnrolConfigCourses>(
                                            value: valueItem,
                                            child: Text(valueItem.course),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff7F0081),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Save registration data and update global config accordingly.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterSuccessPage(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 10),
                        Text("Continue", style: white18MediumTextStyle),
                        Icon(Icons.arrow_forward_ios_outlined, color: Colors.white, size: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
