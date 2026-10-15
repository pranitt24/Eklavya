import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/db/database.dart';
import '../../../core/db/student_repository.dart';
import '../../../nova_main/screens/onboarding/welcome_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  int _selectedStandard = 3;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startJourney() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final repository = ref.read(studentRepositoryProvider);
    final newId = DateTime.now().millisecondsSinceEpoch.toString();

    final profile = StudentProfilesCompanion(
      id: Value(newId),
      name: Value(name),
      enrolledStandard: Value(_selectedStandard),
      activeStandard: Value(_selectedStandard),
      streakCount: const Value(0),
      seedsBalance: const Value(0),
    );

    await repository.insertStudentProfile(profile);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'माझे गाव मध्ये तुमचे स्वागत आहे!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'मुलाचे नाव (Child\'s Name)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: _buildStandardCard(3, 'इयत्ता ३ री', 'Std 3'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStandardCard(4, 'इयत्ता ४ थी', 'Std 4'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startJourney,
        label: const Text(
          'Start Journey',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.rocket_launch, size: 28),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStandardCard(int standard, String marathiText, String englishText) {
    final isSelected = _selectedStandard == standard;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStandard = standard;
        });
      },
      child: Card(
        color: isSelected ? colorScheme.secondary.withOpacity(0.1) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? colorScheme.secondary : Colors.transparent,
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Column(
            children: [
              Text(
                marathiText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? colorScheme.secondary : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                englishText,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? colorScheme.secondary.withOpacity(0.8) : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
