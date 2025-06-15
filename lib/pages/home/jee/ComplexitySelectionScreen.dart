import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'jee_subjectwise.dart';

class ComplexitySelectionScreen extends StatelessWidget {
  const ComplexitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Complexity Level'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildComplexityButton('Elementary', 'e', context),
            const SizedBox(height: 20),
            _buildComplexityButton('Advanced', 'a', context),
          ],
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