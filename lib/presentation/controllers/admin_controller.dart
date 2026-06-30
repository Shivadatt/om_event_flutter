import 'package:get/get.dart';
import '../../domain/entities/lead.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/admin_role.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/admin_repository.dart';

class AdminController extends GetxController {
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
  final rxCategories = <Category>[].obs;
  final rxExperiences = <Experience>[].obs;
  final rxCustomers = <CustomerModel>[].obs;
  final rxUsers = <UserModel>[].obs;
  final rxReviews = <ReviewModel>[].obs;

  final isLoadingStats = false.obs;
  final isLoadingCategories = false.obs;
  final isLoadingExperiences = false.obs;
  final isLoadingCustomers = false.obs;
  final isLoadingUsers = false.obs;
  final isLoadingReviews = false.obs;

  // Calculated Metrics
  final leadCount = 0.obs;
  final quoteCount = 0.obs;
  final pipelineRevenue = 0.0.obs;
  final activeCategoriesCount = 0.obs;
  final totalReviewsCount = 0.obs;
  final pendingReviewsCount = 0.obs;
  final approvedReviewsCount = 0.obs;
  final averageReviewsRating = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
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

  // Categories CRUD methods
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      final list = await catalogRepository.getCategories();
      rxCategories.assignAll(list);
      activeCategoriesCount.value = list.where((c) => c.isActive).length;
    } catch (e) {
      Get.snackbar("Categories Error", e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> saveCategory(Category category, {bool isEdit = false}) async {
    try {
      isLoadingCategories.value = true;
      if (isEdit) {
        await catalogRepository.updateCategory(category);
      } else {
        await catalogRepository.createCategory(category);
      }
      await loadCategories();
      Get.snackbar("Category Saved", "Category saved successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> deleteCategory(String slug) async {
    try {
      isLoadingCategories.value = true;
      await catalogRepository.deleteCategory(slug);
      await loadCategories();
      Get.snackbar("Category Deleted", "Category removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Experiences CRUD methods
  Future<void> loadExperiences() async {
    try {
      isLoadingExperiences.value = true;
      final list = await catalogRepository.getExperiences();
      rxExperiences.assignAll(list);
    } catch (e) {
      Get.snackbar("Experiences Error", e.toString());
    } finally {
      isLoadingExperiences.value = false;
    }
  }

  Future<void> saveExperience(Experience experience, {bool isEdit = false}) async {
    try {
      isLoadingExperiences.value = true;
      if (isEdit) {
        await catalogRepository.updateExperience(experience);
      } else {
        await catalogRepository.createExperience(experience);
      }
      await loadExperiences();
      Get.snackbar("Experience Saved", "Experience saved successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingExperiences.value = false;
    }
  }

  Future<void> deleteExperience(String slug) async {
    try {
      isLoadingExperiences.value = true;
      await catalogRepository.deleteExperience(slug);
      await loadExperiences();
      Get.snackbar("Experience Deleted", "Experience removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingExperiences.value = false;
    }
  }

  // Customers CRUD methods
  Future<void> loadCustomers() async {
    try {
      isLoadingCustomers.value = true;
      final list = await customerRepository.getCustomers();
      rxCustomers.assignAll(list);
    } catch (e) {
      Get.snackbar("Customers Error", e.toString());
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  Future<void> saveCustomer(CustomerModel customer) async {
    try {
      isLoadingCustomers.value = true;
      await customerRepository.updateCustomer(customer);
      await loadCustomers();
      Get.snackbar("Customer Saved", "Customer profile updated successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  Future<void> deleteCustomer(String phone) async {
    try {
      isLoadingCustomers.value = true;
      await customerRepository.deleteCustomer(phone);
      await loadCustomers();
      Get.snackbar("Customer Deleted", "Customer profile deleted successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  // Users CRUD methods
  Future<void> loadUsers() async {
    try {
      isLoadingUsers.value = true;
      final list = await authRepository.getUsers();
      rxUsers.assignAll(list);
    } catch (e) {
      Get.snackbar("Users Error", e.toString());
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> saveUser(UserModel user, {bool isEdit = false}) async {
    try {
      isLoadingUsers.value = true;
      if (isEdit) {
        await authRepository.updateUser(user);
      } else {
        await authRepository.createUser(user);
      }
      await loadUsers();
      Get.snackbar("User Saved", "User profile saved successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      isLoadingUsers.value = true;
      await authRepository.deleteUser(uid);
      await loadUsers();
      Get.snackbar("User Deleted", "User removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingUsers.value = false;
    }
  }

  // RBAC Admin Roles State Management
  final rxAdminRoles = <AdminRole>[].obs;
  final isLoadingAdminRoles = false.obs;

  Future<void> loadAdminRoles() async {
    try {
      isLoadingAdminRoles.value = true;
      final list = await authRepository.getAdminRoles();
      rxAdminRoles.assignAll(list);
    } catch (e) {
      Get.snackbar("RBAC Error", "Failed to load admin roles: ${e.toString()}");
    } finally {
      isLoadingAdminRoles.value = false;
    }
  }

  Future<void> saveAdminRole(AdminRole role, {required bool isEdit}) async {
    try {
      isLoadingAdminRoles.value = true;
      await authRepository.saveAdminRole(role, isEdit: isEdit);
      await loadAdminRoles();
      Get.snackbar("Role Saved", "Administrator permissions updated successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingAdminRoles.value = false;
    }
  }

  Future<void> deleteAdminRole(String uid) async {
    try {
      isLoadingAdminRoles.value = true;
      await authRepository.deleteAdminRole(uid);
      await loadAdminRoles();
      Get.snackbar("Role Deleted", "Administrator removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingAdminRoles.value = false;
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
      await quotationRepository.updateQuotationStatus(id, status);
      await loadDashboardStats();
      Get.snackbar("Status Updated", "Quotation status updated successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // Reviews CRUD Methods
  Future<void> loadReviews() async {
    try {
      isLoadingReviews.value = true;
      final adminRepo = Get.find<AdminRepository>();
      final list = await adminRepo.getReviews();
      rxReviews.assignAll(list);

      // Recalculate review metrics
      totalReviewsCount.value = list.length;
      pendingReviewsCount.value = list.where((r) => !r.isPublished).length;
      approvedReviewsCount.value = list.where((r) => r.isPublished).length;
      if (list.isNotEmpty) {
        final sum = list.fold(0, (prev, element) => prev + element.rating);
        averageReviewsRating.value = sum / list.length;
      } else {
        averageReviewsRating.value = 5.0;
      }
    } catch (e) {
      Get.snackbar("Reviews Error", e.toString());
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> saveReview(ReviewModel review, {required bool isEdit}) async {
    try {
      isLoadingReviews.value = true;
      final adminRepo = Get.find<AdminRepository>();
      await adminRepo.saveReview(review, isEdit: isEdit);
      await loadReviews();
      Get.snackbar("Review Saved", "Review configuration updated successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      isLoadingReviews.value = true;
      final adminRepo = Get.find<AdminRepository>();
      await adminRepo.deleteReview(id);
      await loadReviews();
      Get.snackbar("Review Deleted", "Review removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingReviews.value = false;
    }
  }
}
