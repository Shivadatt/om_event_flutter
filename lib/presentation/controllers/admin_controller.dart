import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../domain/entities/lead.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import 'category_controller_mixin.dart';
import 'experience_controller_mixin.dart';
import 'customer_controller_mixin.dart';
import 'user_controller_mixin.dart';
import 'review_controller_mixin.dart';

class AdminController extends GetxController
    with
        CategoryControllerMixin,
        ExperienceControllerMixin,
        CustomerControllerMixin,
        UserControllerMixin,
        ReviewControllerMixin {
  final LeadRepository leadRepository;
  final QuotationRepository quotationRepository;
  final CatalogRepository catalogRepository;
  final CustomerRepository customerRepository;
  final AuthRepository authRepository;

  AdminController({
    required this.leadRepository,
    required this.quotationRepository,
    required this.catalogRepository,
    required this.customerRepository,
    required this.authRepository,
  });

  // State Observables
  final rxLeads = <Lead>[].obs;
  final rxQuotes = <Quotation>[].obs;

  final isLoadingStats = false.obs;

  // Calculated Metrics
  final leadCount = 0.obs;
  final quoteCount = 0.obs;
  final pipelineRevenue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Bind real-time stream of all quotations
    rxQuotes.bindStream(quotationRepository.streamAllQuotations());
    
    // Recalculate metrics reactively when quotations list changes
    ever(rxQuotes, (quotesList) {
      quoteCount.value = quotesList.length;
      pipelineRevenue.value = quotesList.fold(
        0.0,
        (total, quote) => total + quote.grandTotal,
      );
    });

    loadDashboardStats();
    loadCategories();
    loadExperiences();
    loadCustomers();
    loadUsers();
    loadAdminRoles();
    loadReviews();
  }

  Future<void> loadDashboardStats() async {
    try {
      isLoadingStats.value = true;

      final leadsList = await leadRepository.getLeads();
      leadsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      rxLeads.assignAll(leadsList);
      leadCount.value = leadsList.length;
    } catch (e) {
      Get.snackbar(
        "Dashboard Error",
        "Failed to retrieve stats: ${e.toString()}",
      );
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> updateLead(String leadId, String status) async {
    try {
      await leadRepository.updateLeadStatus(leadId, status);
      await loadDashboardStats();
      Get.snackbar("Status Updated", "Lead status updated successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> updateQuotation(String id, String status) async {
    try {
      final targetStatus = QuotationStatus.fromString(status);
      if (targetStatus == QuotationStatus.acceptedByClient || targetStatus == QuotationStatus.rejectedByClient) {
        throw Exception("Customer acceptance or rejection must always originate from the Client Portal.");
      }
      await quotationRepository.updateQuotationStatus(id, status);
      await loadDashboardStats();
      Get.snackbar("Status Updated", "Quotation status updated successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> sendProposalMessage(String id, String message) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection(AppCollections.quotations).doc(id).update({
        'adminMessage': message,
      });
      
      final doc = await db.collection(AppCollections.quotations).doc(id).get();
      final data = doc.data() ?? {};
      final customerId = data['customerId'] ?? data['customer_id'] ?? '';
      
      if (customerId.isNotEmpty) {
        await db.collection(AppCollections.customerNotifications).add({
          'customerId': customerId,
          'title': 'New Message from Studio',
          'body': 'Admin sent a message regarding proposal ${data['public_id'] ?? id}: "$message"',
          'type': 'message',
          'isRead': false,
          'createdAt': DateTime.now().toIso8601String(),
          'branch': data['location'] ?? '',
        });
      }
      Get.snackbar("Message Sent", "Proposal message sent successfully.");
    } catch (e) {
      Get.snackbar("Error", "Failed to send message: ${e.toString()}");
    }
  }
}
