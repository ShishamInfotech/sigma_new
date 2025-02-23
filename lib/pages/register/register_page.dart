import 'package:flutter/material.dart';
import 'package:sigma_new/config/config_loader.dart';
import 'package:sigma_new/config/config_loader.dart'; // Contains EnrolConfig model
import 'package:sigma_new/pages/register/register_succes.dart';
import 'package:sigma_new/ui_helper/constant.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? selectedTitle;
  String? selectedStandard;
  String? selectedBoard;
  String? selectedSubject;

  late Future<EnrolConfig?> enrolConfigFuture;

  @override
  void initState() {
    super.initState();
    enrolConfigFuture = ConfigLoader.getEnrolConfig();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EnrolConfig?>(
      future: enrolConfigFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(
              body: Center(child: Text("Error loading enrollment configuration")));
        }
        final enrolConfig = snapshot.data!;
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
                    borderOnForeground: false,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              "Registration",
                              style: black20w400MediumTextStyle,
                            ),
                          ),
                          const Text(
                            "Register to your account",
                            style: grey14MediumTextStyle,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Title',
                                  style: black16MediumTextStyle,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15.0))),
                                  height: MediaQuery.of(context).size.height *
                                      0.05,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        autofocus: true,
                                        value: selectedTitle,
                                        isExpanded: true,
                                        hint: const Text(
                                          "Select",
                                          style: grey16MediumTextStyle,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedTitle = newValue;
                                          });
                                        },
                                        items: enrolConfig.titleList
                                            .map<DropdownMenuItem<String>>(
                                                (valueItem) {
                                              return DropdownMenuItem<String>(
                                                value: valueItem,
                                                child: Text(valueItem),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    'First Name',
                                    style: black16MediumTextStyle,
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0))),
                                  height: MediaQuery.of(context).size.height *
                                      0.05,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: TextFormField(
                                    autofocus: true,
                                    decoration: InputDecoration(
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 10),
                                        hintText: "First Name",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(15.0),
                                            gapPadding: 20)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    'Last Name',
                                    style: black16MediumTextStyle,
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0))),
                                  height: MediaQuery.of(context).size.height *
                                      0.05,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: TextFormField(
                                    autofocus: true,
                                    decoration: InputDecoration(
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 10),
                                        hintText: "Last Name",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(15.0),
                                            gapPadding: 20)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    'Standard',
                                    style: black16MediumTextStyle,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15.0))),
                                  height: MediaQuery.of(context).size.height *
                                      0.05,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        autofocus: true,
                                        value: selectedStandard,
                                        isExpanded: true,
                                        hint: const Text(
                                          "Standard",
                                          style: grey16MediumTextStyle,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedStandard = newValue;
                                          });
                                        },
                                        items: enrolConfig.standardList
                                            .map<DropdownMenuItem<String>>(
                                                (valueItem) {
                                              return DropdownMenuItem<String>(
                                                value: valueItem,
                                                child: Text(valueItem),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    'Board',
                                    style: black16MediumTextStyle,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15.0))),
                                  height: MediaQuery.of(context).size.height *
                                      0.05,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        autofocus: true,
                                        value: selectedBoard,
                                        isExpanded: true,
                                        hint: const Text(
                                          "Select",
                                          style: grey16MediumTextStyle,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedBoard = newValue;
                                          });
                                        },
                                        items: enrolConfig.boardList
                                            .map<DropdownMenuItem<String>>(
                                                (valueItem) {
                                              return DropdownMenuItem<String>(
                                                value: valueItem,
                                                child: Text(valueItem),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    'Subjects',
                                    style: black16MediumTextStyle,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15.0))),
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    width: MediaQuery.of(context).size.width *
                                        0.9,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          autofocus: true,
                                          value: selectedSubject,
                                          isExpanded: true,
                                          hint: const Text(
                                            "Select",
                                            style: grey16MediumTextStyle,
                                          ),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedSubject = newValue;
                                            });
                                          },
                                          items: enrolConfig.subjectList
                                              .map<DropdownMenuItem<String>>(
                                                  (valueItem) {
                                                return DropdownMenuItem<String>(
                                                  value: valueItem,
                                                  child: Text(valueItem),
                                                );
                                              }).toList(),
                                        ),
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
                          ));
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 10),
                        Text("Continue", style: white18MediumTextStyle),
                        Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
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
