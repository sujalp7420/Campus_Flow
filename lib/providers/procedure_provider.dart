import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/procedure_model.dart';

class ProcedureProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  final List<ProcedureModel> _procedures = [];
  bool _isLoading = false;

  List<ProcedureModel> get procedures => List.unmodifiable(_procedures);
  bool get isLoading => _isLoading;

  // Fallback initial procedures ensuring all categories (especially Certificates) work out-of-the-box
  static final List<ProcedureModel> defaultProcedures = [
    ProcedureModel(
      id: 'cert-1',
      title: 'Bonafide Certificate',
      categoryId: 'cert',
      categoryName: 'Certificates',
      description: 'Required for passport applications, bus/train student concessions, visa processing, bank accounts, and educational loans.',
      processingTime: '1-2 Working Days',
      fee: 20.0,
      office: 'Student Section (Admin Block Room 102)',
      workingHours: '10:00 AM - 4:00 PM',
      requiredDocuments: [
        'Valid College ID Card',
        'Current Semester Fee Receipt',
        'Application Form (available at counter)',
      ],
      steps: [
        'Collect Bonafide Application form from Student Section or download online.',
        'Fill in personal details, roll number, department, and purpose of certificate.',
        'Attach photocopy of College ID card and latest semester fee receipt.',
        'Get form signed and stamped by Head of Department (HOD).',
        'Submit form at Counter 2 of Student Section and pay ₹20 fee.',
        'Collect the stamped Bonafide Certificate on the next working day.',
      ],
    ),
    ProcedureModel(
      id: 'cert-2',
      title: 'Degree / Provisional Passing Certificate',
      categoryId: 'cert',
      categoryName: 'Certificates',
      description: 'Issued upon course completion for higher education admissions or employment background verification.',
      processingTime: '3-5 Working Days',
      fee: 150.0,
      office: 'Examination & Academic Cell',
      workingHours: '10:00 AM - 3:30 PM',
      requiredDocuments: [
        'All Semester Grade Cards / Marksheets',
        'Central No-Dues Clearance Slip',
        'Valid Photo ID Proof',
      ],
      steps: [
        'Obtain No-Dues Clearance from Library, Hostel, Lab, and Accounts department.',
        'Fill Provisional Certificate Application at the Academic desk.',
        'Submit photocopies of all semester marksheets along with Clearance slip.',
        'Pay ₹150 processing fee at Accounts counter and collect receipt voucher.',
        'Submit receipt copy at Examination counter.',
        'Collect Provisional Certificate after verification by Registrar.',
      ],
    ),
    ProcedureModel(
      id: 'cert-3',
      title: 'Character & Conduct Certificate',
      categoryId: 'cert',
      categoryName: 'Certificates',
      description: 'Official certificate testifying good conduct, required for government job applications and study abroad.',
      processingTime: '2 Working Days',
      fee: 50.0,
      office: 'Dean of Student Affairs Office',
      workingHours: '11:00 AM - 4:00 PM',
      requiredDocuments: [
        'College ID Card',
        'Class Mentor / Teacher Recommendation Note',
        'Fee Clearance Slip',
      ],
      steps: [
        'Obtain Character Certificate Request form from Student Affairs office.',
        'Get endorsement and signature from Class Mentor or Faculty Advisor.',
        'Submit application to Dean of Student Affairs desk.',
        'Pay ₹50 fee at cash counter.',
        'Collect signed Character Certificate after 2 working days.',
      ],
    ),
    ProcedureModel(
      id: 'cert-4',
      title: 'College Leaving / Transfer Certificate (TC)',
      categoryId: 'cert',
      categoryName: 'Certificates',
      description: 'Issued when a student graduates or transfers to another institution or university.',
      processingTime: '4-7 Working Days',
      fee: 100.0,
      office: 'Registrar Office',
      workingHours: '10:00 AM - 3:00 PM',
      requiredDocuments: [
        'Original Student ID Card (to surrender)',
        'Complete Central No-Dues Clearance Form',
        'Final Semester Marksheet Photocopy',
      ],
      steps: [
        'Collect Central No Dues Clearance form from Registrar Office.',
        'Get sign-off stamps from Library, Sports, Accounts, Department Labs, and Hostel.',
        'Surrender original Student ID Card at Student Section.',
        'Pay TC processing fee of ₹100.',
        'Submit complete dossier to Registrar Office.',
        'Collect original Transfer Certificate along with original documents.',
      ],
    ),
    ProcedureModel(
      id: 'cert-5',
      title: 'Migration Certificate',
      categoryId: 'cert',
      categoryName: 'Certificates',
      description: 'Required for students shifting to an affiliated board or overseas university.',
      processingTime: '5-7 Working Days',
      fee: 250.0,
      office: 'University Examination Section',
      workingHours: '10:00 AM - 3:30 PM',
      requiredDocuments: [
        'Transfer Certificate (TC) Copy',
        'Final Degree / Marksheet Copy',
        'Migration Application Form',
      ],
      steps: [
        'Fill Migration Application form with previous registration number.',
        'Attach Transfer Certificate copy and final grade report.',
        'Pay migration fee of ₹250 online or at bank counter.',
        'Submit application to University Liaison desk.',
        'Receive Migration Certificate via post or in-person pickup.',
      ],
    ),
    ProcedureModel(
      id: 'exam-1',
      title: 'Semester Examination Hall Ticket',
      categoryId: 'exam',
      categoryName: 'Examination',
      description: 'Mandatory admit card required to appear for mid-semester and end-semester examinations.',
      processingTime: 'Immediate / 1 Day',
      fee: 0.0,
      office: 'Examination Cell (Block A)',
      workingHours: '9:30 AM - 4:30 PM',
      requiredDocuments: [
        'Student ID Card',
        'Semester Fee Paid Receipt',
        '75% Attendance Clearance Slip',
      ],
      steps: [
        'Check eligibility status on student portal (verify minimum 75% attendance).',
        'Ensure all semester tuition and lab dues are cleared with Accounts.',
        'Login to exam portal and generate Hall Ticket or visit Exam Cell Counter.',
        'Get Hall Ticket verified and stamped by Department HOD.',
        'Carry Hall Ticket and ID card to all examination halls.',
      ],
    ),
    ProcedureModel(
      id: 'fin-1',
      title: 'Fee Concession & Scholarship Verification',
      categoryId: 'fin',
      categoryName: 'Finance',
      description: 'Verification and documentation for state/central government scholarships and fee concessions.',
      processingTime: '3-4 Working Days',
      fee: 0.0,
      office: 'Accounts & Scholarship Desk',
      workingHours: '10:00 AM - 3:00 PM',
      requiredDocuments: [
        'Income Certificate from competent authority',
        'Caste / Category Certificate if applicable',
        'Previous Year Marksheet',
        'Bank Passbook photocopy',
      ],
      steps: [
        'Register on the National / State Scholarship portal and print application draft.',
        'Attach verified income certificate and previous year academic grade cards.',
        'Submit draft to Scholarship Desk for internal verification.',
        'Collect signed institute endorsement letter and upload to portal.',
        'Submit physical dossier to Accounts Section.',
      ],
    ),
    ProcedureModel(
      id: 'host-1',
      title: 'Hostel Room Allocation & Admission',
      categoryId: 'host',
      categoryName: 'Hostel',
      description: 'Application process for on-campus hostel accommodation for academic year.',
      processingTime: '2-3 Working Days',
      fee: 0.0,
      office: 'Chief Warden Office (Hostel Block 1)',
      workingHours: '9:00 AM - 5:00 PM',
      requiredDocuments: [
        'College Admission Letter / ID',
        'Hostel Fee Receipt',
        'Medical Fitness Certificate',
        '2 Passport Photos',
      ],
      steps: [
        'Submit Hostel Application form with preference for room sharing.',
        'Pay semester hostel & mess fees via online payment portal.',
        'Submit fee receipt and medical clearance to Chief Warden office.',
        'Collect room allotment slip and hostel rules handbook.',
        'Check into designated room and complete inventory checklist.',
      ],
    ),
    ProcedureModel(
      id: 'lib-1',
      title: 'Library Card & Digital Access Registration',
      categoryId: 'lib',
      categoryName: 'Library',
      description: 'Access physical book lending and IEEE/ScienceDirect remote digital library databases.',
      processingTime: 'Same Day',
      fee: 0.0,
      office: 'Central Library Desk (1st Floor)',
      workingHours: '9:00 AM - 6:00 PM',
      requiredDocuments: [
        'College ID Card',
        'Current Semester Fee Receipt',
        '1 Passport Photograph',
      ],
      steps: [
        'Visit Central Library circulation desk with Student ID Card.',
        'Fill library membership card form and provide college email ID.',
        'Get barcode tag affixed to your College ID.',
        'Receive login credentials for digital library portal and remote VPN access.',
      ],
    ),
  ];

  Future<void> loadProcedures() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('procedures')
          .select()
          .order('created_at');

      final loadedList = (data as List)
          .map((item) => ProcedureModel.fromMap(item))
          .toList();

      _procedures.clear();
      if (loadedList.isNotEmpty) {
        _procedures.addAll(loadedList);
      } else {
        // Fallback to default comprehensive catalog
        _procedures.addAll(defaultProcedures);
      }
    } catch (e) {
      debugPrint('Load procedures error: $e');
      if (_procedures.isEmpty) {
        _procedures.addAll(defaultProcedures);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProcedureModel> getProceduresByCategory(String categoryName) {
    if (categoryName.trim().isEmpty) return _procedures;
    final term = categoryName.trim().toLowerCase();
    return _procedures.where((p) {
      return p.categoryName.toLowerCase() == term ||
          p.categoryId.toLowerCase() == term ||
          p.categoryName.toLowerCase().contains(term);
    }).toList();
  }

  List<ProcedureModel> searchProcedures(String query, {String? categoryFilter}) {
    final q = query.trim().toLowerCase();
    return _procedures.where((p) {
      final matchesQuery = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q) ||
          p.office.toLowerCase().contains(q);

      final matchesCategory = categoryFilter == null ||
          categoryFilter.isEmpty ||
          categoryFilter.toLowerCase() == 'all' ||
          p.categoryName.toLowerCase() == categoryFilter.toLowerCase();

      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<void> addProcedure({
    required String title,
    required String categoryId,
    required String categoryName,
    required String description,
    required String processingTime,
    required double fee,
    required String office,
    required String workingHours,
    required List<String> requiredDocuments,
    required List<String> steps,
  }) async {
    try {
      await _supabase.from('procedures').insert({
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
      });

      await loadProcedures();
    } catch (e) {
      debugPrint('Add procedure error: $e');
      rethrow;
    }
  }

  Future<void> updateProcedure({
    required String id,
    required String title,
    required String categoryId,
    required String categoryName,
    required String description,
    required String processingTime,
    required double fee,
    required String office,
    required String workingHours,
    required List<String> requiredDocuments,
    required List<String> steps,
  }) async {
    try {
      await _supabase.from('procedures').update({
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
      }).eq('id', id);

      await loadProcedures();
    } catch (e) {
      debugPrint('Update procedure error: $e');
      rethrow;
    }
  }

  Future<void> deleteProcedure(String id) async {
    try {
      await _supabase.from('procedures').delete().eq('id', id);
      await loadProcedures();
    } catch (e) {
      debugPrint('Delete procedure error: $e');
      rethrow;
    }
  }
}