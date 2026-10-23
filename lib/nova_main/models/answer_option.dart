export 'package:majhe_gaon/core/models/visual_type.dart';
import 'package:majhe_gaon/core/models/visual_type.dart';

enum OptionState {
  idle,
  selected,
  correct,
  gentleTryAgain,
  disabled,
}

class AnswerOptionModel {
  final String id;
  final String label;
  final VisualType visualType;
  final String? visualData;
  final String semanticLabel;

  const AnswerOptionModel({
    required this.id,
    required this.label,
    this.visualType = VisualType.none,
    this.visualData,
    required this.semanticLabel,
  });
}
