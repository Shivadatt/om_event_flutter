import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/admin_customer_portal_controller.dart';

/// Admin sub-view managing staff assignments, attendance, expenses, and P&L financial reports.
class StaffFinanceView extends StatefulWidget {
  final AdminCustomerPortalController portalController;

  const StaffFinanceView({
    super.key,
    required this.portalController,
  });

  @override
  State<StaffFinanceView> createState() => _StaffFinanceViewState();
}

class _StaffFinanceViewState extends State<StaffFinanceView> {
  final expenseCategoryCtrl = TextEditingController();
  final expenseAmountCtrl = TextEditingController();

  final rxExpenses = <_MockExpense>[
    _MockExpense('E-01', 'Fresh Flower Logistics', 15000, '2026-07-02'),
    _MockExpense('E-02', 'Daily Wage Labor', 8000, '2026-07-02'),
  ].obs;

  final rxStaff = <_MockStaff>[
    _MockStaff('S-01', 'Ramesh Kumar', 'Present', 'Laying carpet on main stage'),
    _MockStaff('S-02', 'Suresh Patel', 'Leave', 'None'),
    _MockStaff('S-03', 'Vikram Singh', 'Present', 'Sound system setup'),
  ].obs;

  @override
  void dispose() {
    expenseCategoryCtrl.dispose();
    expenseAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Finance P&L Cockpit (Module 4)
          Text("Financial Cockpit (P&L)", style: AppTheme.serifHeader(fontSize: 22)),
          const SizedBox(height: 16),
          Obx(() {
            double totalExp = rxExpenses.fold(0.0, (sum, e) => sum + e.amount);
            double totalRev = 185000; // Mock revenue from bookings
            double netProfit = totalRev - totalExp;

            return Row(
              children: [
                Expanded(child: _buildFinancialCard("Total Bookings Revenue", "₹${totalRev.toStringAsFixed(0)}", Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildFinancialCard("Logged Expenses", "₹${totalExp.toStringAsFixed(0)}", Colors.redAccent)),
                const SizedBox(width: 16),
                Expanded(child: _buildFinancialCard("Net Profit Margin", "₹${netProfit.toStringAsFixed(0)}", const Color(0xFFC9A77E))),
              ],
            );
          }),
          const SizedBox(height: 32),

          // Log Expense Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF12271F), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Log Company Expense", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                TextField(
                  controller: expenseCategoryCtrl,
                  decoration: const InputDecoration(labelText: "Expense Category (e.g., Flowers, Travel, Wages)"),
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: expenseAmountCtrl,
                  decoration: const InputDecoration(labelText: "Amount (INR)"),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
                  onPressed: () {
                    final amt = double.tryParse(expenseAmountCtrl.text) ?? 0.0;
                    if (expenseCategoryCtrl.text.isNotEmpty && amt > 0) {
                      setState(() {
                        rxExpenses.add(_MockExpense('E-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', expenseCategoryCtrl.text, amt, '2026-07-02'));
                      });
                      expenseCategoryCtrl.clear();
                      expenseAmountCtrl.clear();
                    }
                  },
                  child: const Text("Log Expense", style: TextStyle(color: Color(0xFF091210))),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Staff Attendance & Tasks progress (Module 3)
          Text("Staff Attendance & Task Allocation", style: AppTheme.serifHeader(fontSize: 20)),
          const SizedBox(height: 16),
          Obx(() {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rxStaff.length,
              itemBuilder: (context, index) {
                final staff = rxStaff[index];
                return Card(
                  color: const Color(0xFF12271F),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                    subtitle: Text("Task: ${staff.taskDescription}"),
                    trailing: DropdownButton<String>(
                      value: staff.attendance,
                      dropdownColor: const Color(0xFF12271F),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'Present', child: Text("Present", style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'Absent', child: Text("Absent", style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'Leave', child: Text("Leave", style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => staff.attendance = val);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          })
        ],
      ),
    );
  }

  Widget _buildFinancialCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _MockExpense {
  final String id;
  final String category;
  final double amount;
  final String date;
  _MockExpense(this.id, this.category, this.amount, this.date);
}

class _MockStaff {
  final String id;
  final String name;
  String attendance;
  final String taskDescription;
  _MockStaff(this.id, this.name, this.attendance, this.taskDescription);
}
