import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../data/models/customer_model.dart';
import '../../controllers/admin_controller.dart';
import '../../../core/utils/formatters.dart';
import 'widgets/admin_back_button.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;
  final adminController = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const AdminBackButton(),
        title: Text(
          widget.customer.name.toUpperCase(),
          style: AppTheme.serifHeader(fontSize: 18),
        ),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: const Color(0xFFC9A77E),
          unselectedLabelColor: Colors.white60,
          indicatorColor: const Color(0xFFC9A77E),
          tabs: const [
            Tab(text: "Profile"),
            Tab(text: "Leads"),
            Tab(text: "Bookings"),
            Tab(text: "Gallery"),
            Tab(text: "Timeline"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildProfileTab(isDark),
          _buildLeadsTab(),
          _buildBookingsTab(),
          _buildGalleryTab(),
          _buildTimelineTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Name", widget.customer.name),
          _infoRow("Phone", widget.customer.phone),
          _infoRow("Email", widget.customer.email),
          _infoRow("Address", widget.customer.address),
          _infoRow("City", widget.customer.city),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
          Text(value, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildLeadsTab() {
    final leads = adminController.rxLeads.where((l) => l.phone == widget.customer.phone).toList();
    if (leads.isEmpty) {
      return const Center(child: Text("No leads found for this customer."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final l = leads[index];
        return Card(
          color: const Color(0xFF12271F),
          child: ListTile(
            title: Text(l.requestType.toUpperCase(), style: const TextStyle(color: Color(0xFFC9A77E))),
            subtitle: Text("Event Date: ${l.eventDate.toString().split(' ').first}"),
            trailing: Text(l.status),
          ),
        );
      },
    );
  }

  Widget _buildBookingsTab() {
    final bookings = adminController.rxBookings.where((b) {
      final q = adminController.rxQuotes.firstWhereOrNull((quote) => quote.id == b.quotationId);
      return q != null && q.customerPhone == widget.customer.phone;
    }).toList();

    if (bookings.isEmpty) {
      return const Center(child: Text("No bookings found."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];
        final q = adminController.rxQuotes.firstWhereOrNull((quote) => quote.id == b.quotationId);
        final title = q != null ? "Event for ${q.customerName}" : "Booking ${b.bookingNumber}";
        final subtitle = q != null ? "Total: ${AppFormatters.formatCurrency(q.grandTotal)} | Status: ${b.status}" : "Status: ${b.status}";

        return Card(
          color: const Color(0xFF12271F),
          child: ListTile(
            title: Text(title, style: const TextStyle(color: Color(0xFFC9A77E))),
            subtitle: Text(subtitle),
          ),
        );
      },
    );
  }

  Widget _buildGalleryTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.upload),
            label: const Text("Upload Media"),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
            onPressed: () {
              Get.snackbar("Simulated Upload", "Uploading to Supabase customer-gallery bucket...");
            },
          ),
          const SizedBox(height: 24),
          const Text("No shared media found in customer-gallery."),
        ],
      ),
    );
  }

  Widget _buildTimelineTab() {
    final leads = adminController.rxLeads.where((l) => l.phone == widget.customer.phone).toList();
    final bookings = adminController.rxBookings.where((b) {
      final q = adminController.rxQuotes.firstWhereOrNull((quote) => quote.id == b.quotationId);
      return q != null && q.customerPhone == widget.customer.phone;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Unified Customer History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFC9A77E))),
        const SizedBox(height: 16),
        ...leads.map((l) => _buildTimelineTile("Inquiry Received: ${l.requestType}", l.createdAt, Icons.inbox)),
        ...bookings.map((b) {
          final q = adminController.rxQuotes.firstWhereOrNull((quote) => quote.id == b.quotationId);
          final title = q != null ? "Event for ${q.customerName}" : "Booking ${b.bookingNumber}";
          return _buildTimelineTile("Booking Confirmed: $title", b.createdAt, Icons.check_circle);
        }),
      ],
    );
  }

  Widget _buildTimelineTile(String title, DateTime date, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFC9A77E)),
      title: Text(title),
      subtitle: Text(date.toLocal().toString()),
    );
  }
}
