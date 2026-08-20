class ProcedureModel {
  final String id;
  String title;
  String categoryId;
  String categoryName;
  String description;
  String processingTime;
  double fee;
  String office;
  String workingHours;
  List<String> requiredDocuments;
  List<String> steps;

  ProcedureModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.processingTime,
    required this.fee,
    required this.office,
    required this.workingHours,
    required this.requiredDocuments,
    required this.steps,
  });

  factory ProcedureModel.fromMap(Map<String, dynamic> map) {
    // Parse required documents list safely
    List<String> parsedDocs = [];
    if (map['required_documents'] != null) {
      if (map['required_documents'] is List) {
        parsedDocs = (map['required_documents'] as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
      }
    }

    // Parse steps list safely
    List<String> parsedSteps = [];
    if (map['steps'] != null) {
      if (map['steps'] is List) {
        parsedSteps = (map['steps'] as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
      }
    }

    // Parse fee safely
    double parsedFee = 0.0;
    if (map['fee'] != null) {
      if (map['fee'] is num) {
        parsedFee = (map['fee'] as num).toDouble();
      } else {
        parsedFee = double.tryParse(map['fee'].toString()) ?? 0.0;
      }
    }

    return ProcedureModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      categoryName: map['category_name']?.toString() ?? map['category']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      processingTime: map['processing_time']?.toString() ?? '1-2 Days',
      fee: parsedFee,
      office: map['office']?.toString() ?? map['room']?.toString() ?? 'Student Section',
      workingHours: map['working_hours']?.toString() ?? '9:00 AM - 4:00 PM',
      requiredDocuments: parsedDocs,
      steps: parsedSteps,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category_id': categoryId,
      'category_name': categoryName,
      'description': description,
      'processing_time': processingTime,
      'fee': fee,
      'office': office,
      'working_hours': workingHours,
      'required_documents': requiredDocuments,
      'steps': steps,
    };
  }
}