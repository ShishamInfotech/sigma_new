// lib/pages/register/register_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  EnrolConfigStandard? selectedStandard;
  EnrolConfigBoard? selectedBoard;
  List<EnrolConfigCourses> selectedCourses = [];

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

  List<EnrolConfigCourses> getFilteredCourses(List<EnrolConfigCourses> courses) {
    if (selectedStandard != null && selectedBoard != null) {
      final filterKey = "${selectedStandard!.stdID}_${selectedBoard!.boardKey}";
      return courses.where((course) => course.stdBoardKey == filterKey).toList();
    }
    return [];
  }

  void _showMultiSelectDialog(List<EnrolConfigCourses> coursesList) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Courses"),
              content: SingleChildScrollView(
                child: Column(
                  children: coursesList.map((course) {
                    return CheckboxListTile(
                      title: Text(course.course),
                      value: selectedCourses.contains(course),
                      onChanged: (bool? selected) {
                        setDialogState(() {
                          if (selected!) {
                            selectedCourses.add(course);
                          } else {
                            selectedCourses.remove(course);
                          }
                        });
                        setState(() {}); // Update main UI
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CLOSE"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveData() {
    if (selectedTitle == null ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        selectedStandard == null ||
        selectedBoard == null ||
        selectedCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields before continuing")),
      );
      return;
    }

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('title', selectedTitle!);
      prefs.setString('firstName', firstNameController.text);
      prefs.setString('lastName', lastNameController.text);
      prefs.setString('standard', selectedStandard!.name);
      prefs.setString('board', selectedBoard!.board);
      prefs.setString('course', selectedCourses.map((e) => e.course).join(", "));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterSuccessPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: enrolDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(body: Center(child: Text("Error loading config")));
        }

        final standardList = snapshot.data!['standard'] as List<EnrolConfigStandard>;
        final boardList = snapshot.data!['board'] as List<EnrolConfigBoard>;
        final coursesList = snapshot.data!['courses'] as List<EnrolConfigCourses>;
        final filteredCourses = getFilteredCourses(coursesList);
        final titleList = ["Mr", "Ms"];

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Center(
                  child: Card(
                    elevation: 6,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Registration", style: black20w400MediumTextStyle),
                          const Text("Register to your account", style: grey14MediumTextStyle),
                          const SizedBox(height: 10),

                          // Title Dropdown
                          _buildDropdown<String>(
                            label: "Title",
                            value: selectedTitle,
                            hint: "Select",
                            items: titleList,
                            onChanged: (value) => setState(() => selectedTitle = value),
                          ),

                          // First Name
                          _buildTextField("First Name", firstNameController),
                          _buildTextField("Last Name", lastNameController),

                          // Standard
                          _buildDropdown<EnrolConfigStandard>(
                            label: "Standard",
                            value: selectedStandard,
                            hint: "Select",
                            items: standardList,
                            onChanged: (value) => setState(() {
                              selectedStandard = value;
                              selectedCourses.clear(); // Reset courses
                            }),
                            itemToString: (e) => e.name,
                          ),

                          // Board
                          _buildDropdown<EnrolConfigBoard>(
                            label: "Board",
                            value: selectedBoard,
                            hint: "Select",
                            items: boardList,
                            onChanged: (value) => setState(() {
                              selectedBoard = value;
                              selectedCourses.clear();
                            }),
                            itemToString: (e) => e.board,
                          ),

                          // Course (Multi-select)
                          const Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Text("Courses", style: black16MediumTextStyle),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (selectedStandard == null || selectedBoard == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please select Standard and Board first")),
                                );
                                return;
                              }
                              _showMultiSelectDialog(filteredCourses);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedCourses.isEmpty
                                          ? "Select Courses"
                                          : selectedCourses.map((e) => e.course).join(", "),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: Colors.blue),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Text(
                            "Selected: ${selectedCourses.isEmpty ? "None" : selectedCourses.map((e) => e.course).join(", ")}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _saveData,
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required List<T> items,
    required void Function(T?) onChanged,
    String Function(T)? itemToString,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 5.0), child: Text(label, style: black16MediumTextStyle)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.only(bottom: 5),
          height: MediaQuery.of(context).size.height * 0.05,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                hint: Text(hint, style: grey16MediumTextStyle),
                onChanged: onChanged,
                items: items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemToString != null ? itemToString(item) : item.toString()),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 5.0), child: Text(label, style: black16MediumTextStyle)),
        Container(
          margin: const EdgeInsets.only(bottom: 5),
          height: MediaQuery.of(context).size.height * 0.05,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              hintText: label,
              hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), gapPadding: 20),
            ),
          ),
        ),
      ],
    );
  }
}
