// lib/utils/classification_utils.dart
String getClassDescription(String classificationCode) {
  final Map<String, String> classificationColor = {
    'N23': 'Antara 2 dan 3',
    'N34': 'Antara 3 dan 4',
    'N45': 'Antara 4 dan 5',

  };
  return classificationColor[classificationCode] ?? classificationCode;
}