import 'package:flutter/material.dart';



class StudyTrackerHomePage extends StatelessWidget {
  const StudyTrackerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Time Monitoring Report'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStudyTimeSection(),
            const SizedBox(height: 24),
            _buildCourseProgressSection(),
            const SizedBox(height: 24),
            _buildTargetDatesSection(),
            const SizedBox(height: 24),
            _buildMockExamsSection(),
            const SizedBox(height: 24),
            _buildCompetitiveExamsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyTimeSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real Time Study Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCard('Yesterday', '1 hour'),
                _buildMetricCard('Today', '2 hours'),
                _buildMetricCard('To Date', '3 hours'),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Analytical Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCard('Average', '1 hour/day'),
                _buildMetricCard('Lowest', '0 hours'),
                _buildMetricCard('Highest', '2 hours'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgressSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.67,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text('Overall: 67% completed (33% remaining)'),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mathematics: 30%'),
                Text('Physics: 60%'),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chemistry: 70%'),
                Text('Biology: 40%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetDatesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Target Completion Dates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSubjectTarget('Mathematics', 'Oct 31, 2025', 30),
            _buildSubjectTarget('Physics', 'Oct 31, 2025', 60),
            _buildSubjectTarget('Chemistry', 'Oct 31, 2025', 70),
            _buildSubjectTarget('Biology', 'Oct 31, 2025', 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectTarget(String subject, String date, int progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                date,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 70 ? Colors.green :
              progress >= 40 ? Colors.blue : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text('$progress% completed'),
        ],
      ),
    );
  }

  Widget _buildMockExamsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mock Exam Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildExamPerformance('Mathematics', 13, 'Simple'),
            _buildExamPerformance('Physics', 11, 'Simple'),
            _buildExamPerformance('Chemistry', 8, 'Simple'),
            _buildExamPerformance('Biology', 15, 'Simple'),
            const SizedBox(height: 8),
            const Text(
              'Performance Levels:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLevelIndicator('Simple', 'up to 60%'),
            _buildLevelIndicator('Medium', 'up to 70%'),
            _buildLevelIndicator('Complex', 'up to 80%'),
            _buildLevelIndicator('Difficult', 'up to 90%'),
            _buildLevelIndicator('Advance', 'up to 95%'),
          ],
        ),
      ),
    );
  }

  Widget _buildExamPerformance(String subject, int attempts, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(subject),
          Row(
            children: [
              Text('Attempts: $attempts'),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLevelColor(level),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelIndicator(String level, String range) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getLevelColor(level),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$level: $range'),
        ],
      ),
    );
  }

  Widget _buildCompetitiveExamsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Competitive Exam Preparation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCompetitiveExam('JEE', 'PCM'),
            _buildCompetitiveExam('CET', 'PCM/PCB'),
            _buildCompetitiveExam('NEET', 'PCB'),
            const SizedBox(height: 8),
            const Text(
              'There will be five level Mock Examinations',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitiveExam(String exam, String subjects) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exam,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Subjects: $subjects',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          for (var i = 1; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text('Level $i: Not attempted yet'),
            ),
          const Text('Present Status: Not started'),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'simple':
        return Colors.blue;
      case 'medium':
        return Colors.green;
      case 'complex':
        return Colors.orange;
      case 'difficult':
        return Colors.red;
      case 'advance':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}