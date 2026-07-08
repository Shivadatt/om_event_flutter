part of '../settings_notifications_tab.dart';

extension _NotifDashboardExtension on _SettingsNotificationsTabState {
  Widget _buildAnalyticsDashboard() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          _firestore.collection(AppCollections.notificationLogs).snapshots(),
      builder: (context, snapshot) {
        int total = 0;
        int delivered = 0;
        int opened = 0;
        int read = 0;
        int clicked = 0;
        int failed = 0;

        int variantATotal = 0;
        int variantAClicked = 0;
        int variantBTotal = 0;
        int variantBClicked = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          total = docs.length;
          delivered = docs.where((d) {
            final data = d.data();
            return data['status'] == 'delivered';
          }).length;
          opened = docs.where((d) {
            final data = d.data();
            return data['status'] == 'opened';
          }).length;
          read = docs.where((d) {
            final data = d.data();
            return data['status'] == 'read';
          }).length;
          clicked = docs.where((d) {
            final data = d.data();
            return data['status'] == 'clicked';
          }).length;
          failed = docs.where((d) {
            final data = d.data();
            return data['status'] == 'failed';
          }).length;

          variantATotal = docs.where((d) {
            final data = d.data();
            return data['variant'] == 'Variant A';
          }).length;
          variantAClicked = docs.where((d) {
            final data = d.data();
            return data['variant'] == 'Variant A' &&
                data['status'] == 'clicked';
          }).length;
          variantBTotal = docs.where((d) {
            final data = d.data();
            return data['variant'] == 'Variant B';
          }).length;
          variantBClicked = docs.where((d) {
            final data = d.data();
            return data['variant'] == 'Variant B' &&
                data['status'] == 'clicked';
          }).length;
        }

        final int deliveredTotal = delivered + opened + clicked + read;
        final double deliveryRate =
            total > 0 ? (deliveredTotal / total) * 100 : 100.0;
        final double openRate =
            deliveredTotal > 0 ? ((opened + clicked) / deliveredTotal) * 100 : 0.0;
        final double clickRate =
            deliveredTotal > 0 ? (clicked / deliveredTotal) * 100 : 0.0;
        final double readRate =
            deliveredTotal > 0 ? (read / deliveredTotal) * 100 : 0.0;

        final double rateA =
            variantATotal > 0 ? (variantAClicked / variantATotal) * 100 : 0.0;
        final double rateB =
            variantBTotal > 0 ? (variantBClicked / variantBTotal) * 100 : 0.0;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "TOTAL SENT",
                    value: total.toString(),
                    color: const Color(0xFFC9A77E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "DELIVERY RATE",
                    value: "${deliveryRate.toStringAsFixed(1)}%",
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "OPEN RATE",
                    value: "${openRate.toStringAsFixed(1)}%",
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "CLICK RATE",
                    value: "${clickRate.toStringAsFixed(1)}%",
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "WHATSAPP READS",
                    value: "${readRate.toStringAsFixed(1)}%",
                    color: Colors.tealAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "FAILURES / BOUNCES",
                    value: failed.toString(),
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // A/B testing card stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12271F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withAlpha(51)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "A/B SPLIT TESTING SUMMARY (CLICK METRICS)",
                    style: TextStyle(
                      color: Color(0xFFC9A77E),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Variant A (Control): $variantATotal sent | Click Rate: ${rateA.toStringAsFixed(1)}%",
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      Text(
                        "Variant B (Promo copy): $variantBTotal sent | Click Rate: ${rateB.toStringAsFixed(1)}%",
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC9A77E),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool isObscure = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFC9A77E), fontSize: 12),
        filled: true,
        fillColor: Colors.black26,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white12),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC9A77E)),
        ),
      ),
    );
  }
}
