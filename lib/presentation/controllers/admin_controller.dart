import 'package:get/get.dart';
import '../../domain/entities/lead.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/repositories/quotation_repository.dart';

class AdminController extends GetxController {
  final LeadRepository leadRepository;
  final QuotationRepository quotationRepository;

  AdminController({
    required this.leadRepository,
    required this.quotationRepository,
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
    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    try {
      isLoadingStats.value = true;

      // Parallel fetching
      final results = await Future.wait([
        leadRepository.getLeads(),
        quotationRepository.getQuotations(),
      ]);

      final leadsList = results[0] as List<Lead>;
      final quotesList = results[1] as List<Quotation>;

      rxLeads.assignAll(leadsList);
      rxQuotes.assignAll(quotesList);

      // Calculations
      leadCount.value = leadsList.length;
      quoteCount.value = quotesList.length;
      pipelineRevenue.value = quotesList.fold(0.0, (sum, quote) => sum + quote.grandTotal);
    } catch (e) {
      Get.snackbar("Dashboard Error", "Failed to retrieve stats: ${e.toString()}");
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> updateLead(String leadId, String status) async {
    try {
      await leadRepository.updateLeadStatus(leadId, status);
      // Reload stats
      await loadDashboardStats();
      Get.snackbar("Status Updated", "Lead status updated successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> updateQuotation(String id, String status) async {
    try {
      await quotationRepository.updateQuotationStatus(id, status);
      await loadDashboardStats();
      Get.snackbar("Status Updated", "Quotation status updated successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
