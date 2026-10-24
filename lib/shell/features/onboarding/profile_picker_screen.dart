import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/level_api.dart';
import '../../core/audio/sound_service.dart';
import '../../core/models/user_profile.dart';
import '../../core/widgets/squishy_button.dart';
import '../../theme.dart';

/// ProfilePickerScreen: Allows picking an existing student profile or registering
/// a new one with: name (required), age (5-10 stepper), school (optional),
/// class (optional), gender (optional), language (Marathi default).
/// Persists student ID in SharedPreferences and posts to backend /students.
class ProfilePickerScreen extends StatefulWidget {
  const ProfilePickerScreen({super.key});

  @override
  State<ProfilePickerScreen> createState() => _ProfilePickerScreenState();
}

class _ProfilePickerScreenState extends State<ProfilePickerScreen> {
  final LevelApi _levelApi = LevelApi();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _schoolController;

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isCreatingNew = false;
  List<Map<String, dynamic>> _students = [];
  int? _savedStudentId;

  // Form State
  int _age = 7;
  int? _selectedClass = 2;
  String? _selectedGender;
  final String _language = 'mr';

  static const Map<int, String> _devanagariDigits = {
    5: '५',
    6: '६',
    7: '७',
    8: '८',
    9: '९',
    10: '१०',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _schoolController = TextEditingController();
    _loadProfiles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedStudentId = prefs.getInt('current_student_id');

      final list = await _levelApi.listStudents(timeout: const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _students = list;
          _isLoading = false;
          _isCreatingNew = list.isEmpty;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isCreatingNew = true;
        });
      }
    }
  }

  Future<void> _selectExistingStudent(Map<String, dynamic> student) async {
    SoundService.instance.playDingChime();
    final id = student['id'] as int?;
    final name = (student['name'] ?? 'विद्यार्थी').toString();
    final age = (student['age'] as int?) ?? 7;
    final grade = (student['grade'] as int?) ?? 1;

    if (id != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_student_id', id);
      await prefs.setString('student_name', name);
      await prefs.setInt('student_age', age);
      await prefs.setInt('student_grade', grade);

      UserProfile.instance.setStudentId(id);
      UserProfile.instance.setName(name);
      UserProfile.instance.setAge(age);
      UserProfile.instance.setGrade(grade);
    }

    if (mounted) {
      context.go('/diagnostic-test');
    }
  }

  Future<void> _submitNewStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    SoundService.instance.playPopClick();

    final name = _nameController.text.trim();
    final school = _schoolController.text.trim();

    final payload = <String, dynamic>{
      'name': name,
      'age': _age,
      'language': _language,
      if (school.isNotEmpty) 'school': school,
      if (_selectedClass != null) 'class_declared': _selectedClass,
      if (_selectedGender != null) 'gender': _selectedGender,
    };

    int studentId = DateTime.now().millisecondsSinceEpoch % 100000;
    int assignedGrade = 1;

    try {
      final created = await _levelApi.createStudent(payload);
      if (created != null && created['id'] != null) {
        studentId = created['id'] as int;
        assignedGrade = (created['grade'] as int?) ?? 1;
      }
    } catch (e) {
      debugPrint('Student creation network fallback: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_student_id', studentId);
    await prefs.setString('student_name', name);
    await prefs.setInt('student_age', _age);
    await prefs.setInt('student_grade', assignedGrade);

    UserProfile.instance.setStudentId(studentId);
    UserProfile.instance.setName(name);
    UserProfile.instance.setAge(_age);
    UserProfile.instance.setGrade(assignedGrade);

    SoundService.instance.playDingChime();

    if (mounted) {
      setState(() => _isSubmitting = false);
      context.go('/diagnostic-test');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/screens/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Mascot Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.inkGrape.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // NOVA Guide Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Image.asset(
                              'assets/nova/characters/char_nova_standing.webp',
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Center(
                                child: Text('🤖', style: TextStyle(fontSize: 24)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isCreatingNew
                                  ? 'नवीन प्रोफाईल तयार करा'
                                  : 'विद्यार्थी निवडा',
                              style: GameTypography.headline(color: GameColors.inkGrape)
                                  .copyWith(fontSize: 17),
                            ),
                            Text(
                              _isCreatingNew
                                  ? 'Enter student details below'
                                  : 'Select student profile to continue',
                              style: GameTypography.buttonSublabel(color: GameColors.inkMuted),
                            ),
                          ],
                        ),
                      ),
                      if (!_isCreatingNew && _students.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.person_add_rounded, color: GameColors.electricPurple),
                          onPressed: () {
                            SoundService.instance.playPopClick();
                            setState(() => _isCreatingNew = true);
                          },
                          tooltip: 'नवीन प्रोफाईल (Add New)',
                        ),
                    ],
                  ),
                ),
              ),

              // Main Body
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: GameColors.activeGold),
                      )
                    : _isCreatingNew
                        ? _buildRegistrationForm()
                        : _buildStudentList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// List of existing student profiles
  Widget _buildStudentList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._students.map((st) {
            final id = st['id'] as int?;
            final name = (st['name'] ?? 'विद्यार्थी').toString();
            final age = st['age'] != null ? '${st['age']} वर्षे' : '';
            final school = (st['school'] ?? '').toString();
            final isSaved = id != null && id == _savedStudentId;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _selectExistingStudent(st),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSaved ? GameColors.activeGoldDark : GameColors.cardBorderLavender,
                      width: isSaved ? 3 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.inkGrape.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                          border: Border.all(color: GameColors.robotBlue, width: 2),
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Image.asset(
                              'assets/nova/characters/char_nova_happy.webp',
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Center(
                                child: Text('👦🏽', style: TextStyle(fontSize: 26)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  name,
                                  style: GameTypography.headline(color: GameColors.inkGrape)
                                      .copyWith(fontSize: 18),
                                ),
                                if (isSaved) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text('सध्याचे (Active)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [age, if (school.isNotEmpty) school].join(' • '),
                              style: GameTypography.buttonSublabel(color: GameColors.inkMuted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: GameColors.electricPurple, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Add New Profile Button
          Squishy3DButton(
            height: 58,
            backgroundColor: GameColors.electricPurple,
            bevelColor: GameColors.electricPurpleDark,
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            label: 'नवीन विद्यार्थी जोडा',
            sublabel: '+ ADD NEW PROFILE',
            onPressed: () {
              SoundService.instance.playPopClick();
              setState(() => _isCreatingNew = true);
            },
          ),
        ],
      ),
    );
  }

  /// Student Registration Form
  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back button if existing students exist
            if (_students.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    SoundService.instance.playPopClick();
                    setState(() => _isCreatingNew = false);
                  },
                  icon: const Icon(Icons.arrow_back_rounded, color: GameColors.electricPurple, size: 18),
                  label: const Text('मागील प्रोफाईल दाखवा (Back to Profiles)', style: TextStyle(color: GameColors.electricPurple)),
                ),
              ),

            // Form Container Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: GameColors.cardBorderLavender, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.inkGrape.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Name Field (Required)
                  Text(
                    'विद्यार्थ्याचे नाव (Student Name) *',
                    style: GameTypography.headline(color: GameColors.inkGrape).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'उदा. आरव, सई, रोहन...',
                      prefixIcon: const Icon(Icons.badge_rounded, color: GameColors.electricPurple),
                      filled: true,
                      fillColor: GameColors.canvasCream,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'कृपया नाव प्रविष्ट करा (Please enter name)';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // 2. Age Stepper (5 to 10)
                  Text(
                    'वय (Age: 5-10 वर्षे)',
                    style: GameTypography.headline(color: GameColors.inkGrape).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: GameColors.canvasCream,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: GameColors.cardBorderAmber, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Minus Button
                        IconButton(
                          onPressed: _age > 5
                              ? () {
                                  SoundService.instance.playPopClick();
                                  setState(() => _age--);
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_rounded, size: 32),
                          color: GameColors.electricPurple,
                          disabledColor: Colors.grey.shade300,
                        ),

                        // Age Label Display
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_devanagariDigits[_age] ?? _age} वर्षे',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: GameColors.inkGrape,
                              ),
                            ),
                            Text(
                              '($_age years old)',
                              style: const TextStyle(fontSize: 12, color: GameColors.inkMuted),
                            ),
                          ],
                        ),

                        // Plus Button
                        IconButton(
                          onPressed: _age < 10
                              ? () {
                                  SoundService.instance.playPopClick();
                                  setState(() => _age++);
                                }
                              : null,
                          icon: const Icon(Icons.add_circle_rounded, size: 32),
                          color: GameColors.electricPurple,
                          disabledColor: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. Class (Optional: 1 to 5)
                  Text(
                    'इयत्ता (Class / Standard - Optional)',
                    style: GameTypography.headline(color: GameColors.inkGrape).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [1, 2, 3, 4, 5].map((c) {
                      final isSelected = _selectedClass == c;
                      final devanagariClasses = {1: '१ली', 2: '२री', 3: '३री', 4: '४थी', 5: '५वी'};
                      return ChoiceChip(
                        label: Text(devanagariClasses[c] ?? 'इयत्ता $c'),
                        selected: isSelected,
                        selectedColor: GameColors.electricPurple,
                        backgroundColor: GameColors.canvasCream,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : GameColors.inkGrape,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (sel) {
                          SoundService.instance.playPopClick();
                          setState(() => _selectedClass = sel ? c : null);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // 4. Gender (Optional)
                  Text(
                    'लिंग (Gender - Optional)',
                    style: GameTypography.headline(color: GameColors.inkGrape).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('मुलगा 👦 (Boy)')),
                          selected: _selectedGender == 'boy',
                          selectedColor: const Color(0xFF38BDF8),
                          backgroundColor: GameColors.canvasCream,
                          labelStyle: TextStyle(
                            color: _selectedGender == 'boy' ? Colors.white : GameColors.inkGrape,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (sel) {
                            SoundService.instance.playPopClick();
                            setState(() => _selectedGender = sel ? 'boy' : null);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('मुलगी 👧 (Girl)')),
                          selected: _selectedGender == 'girl',
                          selectedColor: const Color(0xFFF472B6),
                          backgroundColor: GameColors.canvasCream,
                          labelStyle: TextStyle(
                            color: _selectedGender == 'girl' ? Colors.white : GameColors.inkGrape,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (sel) {
                            SoundService.instance.playPopClick();
                            setState(() => _selectedGender = sel ? 'girl' : null);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 5. School (Optional)
                  Text(
                    'शाळा (School Name - Optional)',
                    style: GameTypography.headline(color: GameColors.inkGrape).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _schoolController,
                    decoration: InputDecoration(
                      hintText: 'उदा. जि. प. प्राथमिक शाळा',
                      prefixIcon: const Icon(Icons.school_rounded, color: GameColors.electricPurple),
                      filled: true,
                      fillColor: GameColors.canvasCream,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 6. Language Indicator (Default Marathi)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.language_rounded, color: Color(0xFFD97706), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'भाषा: मराठी (Language: Marathi)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            Squishy3DButton(
              height: 64,
              backgroundColor: GameColors.emeraldGrass,
              bevelColor: GameColors.emeraldGrassDark,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 26),
              label: 'सुरू करा! (START)',
              sublabel: 'SAVE PROFILE & TAKE TEST',
              onPressed: _isSubmitting ? null : _submitNewStudent,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
