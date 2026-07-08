part of '../system_settings_screen.dart';

extension _SettingsAdvancedFormExtension on _SystemSettingsScreenState {
  Widget _buildAnalyticsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ANALYTICS INTEGRATION",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Measurement ID (GA4)", _analyticsId),
        CheckboxListTile(
          title: const Text("Enable Analytics Tracking"),
          value: _analyticsEnable,
          onChanged: (v) {
            updateState(() {
              _analyticsEnable = v ?? false;
            });
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('analytics', () async {
                await _repository.saveAnalytics(
                  AnalyticsSettings(
                    measurementId: _analyticsId.text,
                    enableTracking: _analyticsEnable,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildDashboardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ADMIN DASHBOARD CONFIG",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Welcome Greeting Message", _dashboardWelcome),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('dashboard', () async {
                final current = AppConfigService.to.rxDashboardSettings.value;
                await _repository.saveDashboard(
                  DashboardSettings(
                    welcomeMessage: _dashboardWelcome.text,
                    activeWidgets: current.activeWidgets,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildFeatureFlagsForm() {
    return Obx(() {
      final flags = AppConfigService.to.rxFeatureFlagsSettings.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SYSTEM FEATURE FLAGS",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text("Enable Reviews Section"),
            value: flags.enableReviews,
            onChanged: (v) => _updateFeatureFlags(enableReviews: v),
          ),
          SwitchListTile(
            title: const Text("Enable Gallery Section"),
            value: flags.enableGallery,
            onChanged: (v) => _updateFeatureFlags(enableGallery: v),
          ),
          SwitchListTile(
            title: const Text("Enable Self Booking Mode"),
            value: flags.enableBooking,
            onChanged: (v) => _updateFeatureFlags(enableBooking: v),
          ),
          SwitchListTile(
            title: const Text("Enable Online Payments Integration"),
            value: flags.enablePayments,
            onChanged: (v) => _updateFeatureFlags(enablePayments: v),
          ),
        ],
      );
    });
  }

  Future<void> _updateFeatureFlags({
    bool? enableReviews,
    bool? enableGallery,
    bool? enableBooking,
    bool? enablePayments,
  }) async {
    final current = AppConfigService.to.rxFeatureFlagsSettings.value;
    await _saveAndPublish('feature_flags', () async {
      await _repository.saveFeatureFlags(
        FeatureFlagsSettings(
          enableReviews: enableReviews ?? current.enableReviews,
          enableGallery: enableGallery ?? current.enableGallery,
          enableBooking: enableBooking ?? current.enableBooking,
          enablePayments: enablePayments ?? current.enablePayments,
          enableCart: current.enableCart,
          enableQuotes: current.enableQuotes,
          enableAnalytics: current.enableAnalytics,
        ),
      );
    });
  }

  Widget _buildMaintenanceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SYSTEM MAINTENANCE MODE",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        Obx(() {
          final maint = AppConfigService.to.rxMaintenanceSettings.value;
          return SwitchListTile(
            title: const Text("Activate Maintenance Mode"),
            value: maint.maintenanceMode,
            onChanged:
                (v) => _saveAndPublish('maintenance', () async {
                  await _repository.saveMaintenance(
                    MaintenanceSettings(
                      maintenanceMode: v,
                      message: _maintenanceMsg.text,
                      eta: maint.eta,
                    ),
                  );
                }),
          );
        }),
        const SizedBox(height: 16),
        _field("Banner Message", _maintenanceMsg),
      ],
    );
  }

  Widget _buildAppForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "APPLICATION SPECIFICATIONS",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("App Current Version ID", _appVersion),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('app', () async {
                final current = AppConfigService.to.rxAppSettings.value;
                await _repository.saveApp(
                  AppSettings(
                    version: _appVersion.text,
                    forceUpdate: current.forceUpdate,
                    buildNumber: current.buildNumber,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildReviewsFilterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CUSTOMER REVIEWS FILTER",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Minimum Star Rating allowed", _reviewsMinStars),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('review_settings', () async {
                final current = AppConfigService.to.rxReviewSettings.value;
                await _repository.saveReviewSettings(
                  ReviewSettings(
                    enableSorting: current.enableSorting,
                    minimumStars:
                        double.tryParse(_reviewsMinStars.text) ??
                        current.minimumStars,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildStatisticsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("STATISTICS METRICS", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Completed Events Count", _statEvents),
        _field("Happy Clients Count", _statClients),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('statistics', () async {
                final current = AppConfigService.to.rxStatisticsSettings.value;
                await _repository.saveStatistics(
                  StatisticsSettings(
                    completedEvents:
                        int.tryParse(_statEvents.text) ??
                        current.completedEvents,
                    happyClients:
                        int.tryParse(_statClients.text) ?? current.happyClients,
                    cities: current.cities,
                    years: current.years,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }
}
