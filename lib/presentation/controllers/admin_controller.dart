import 'package:get/get.dart';
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
import 'quotation_controller_mixin.dart';
import '../../core/services/bootstrap_service.dart';

class AdminController extends GetxController
    with
        CategoryControllerMixin,
        ExperienceControllerMixin,
        CustomerControllerMixin,
        UserControllerMixin,
        ReviewControllerMixin,
        QuotationControllerMixin {
  @override
  final LeadRepository leadRepository;
  @override
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

  bool _isInitialized = false;

  void _initializeAdminData() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Bind real-time stream of all quotations
    rxQuotes.bindStream(quotationRepository.streamAllQuotations());

    loadDashboardStats();
    loadCategories();
    loadExperiences();
    loadCustomers();
    loadUsers();
    loadAdminRoles();
    loadReviews();
  }

  @override
  void onInit() {
    super.onInit();
    
    // Recalculate metrics reactively when quotations list changes
    ever(rxQuotes, (quotesList) {
      quoteCount.value = quotesList.length;
      pipelineRevenue.value = quotesList.fold(
        0.0,
        (total, quote) => total + quote.grandTotal,
      );
    });

    // Wait until application bootstrap is ready and user is admin/staff
    ever(BootstrapService.to.rxIsApplicationReady, (isReady) {
      if (isReady) {
        final role = BootstrapService.to.rxUserRole.value;
        if (role == 'admin' || role == 'staff' || role == 'super_admin' || role == 'demo_admin') {
          _initializeAdminData();
        }
      }
    });

    if (BootstrapService.to.rxIsApplicationReady.value) {
      final role = BootstrapService.to.rxUserRole.value;
      if (role == 'admin' || role == 'staff' || role == 'super_admin' || role == 'demo_admin') {
        _initializeAdminData();
      }
    }
  }

  @override
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
}
