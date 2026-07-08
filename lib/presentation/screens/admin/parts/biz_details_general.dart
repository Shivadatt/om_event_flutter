part of '../business_details_screen.dart';

extension BusinessDetailsGeneral on BusinessDetailsScreen {
  Widget _buildGeneralTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "GENERAL PROFILE",
          style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E)),
        ),
        const SizedBox(height: 24),
        _field("Business Name *", controller.busNameCtrl),
        _field("Company Name", controller.compNameCtrl),
        _field("Business Tagline", controller.taglineCtrl),
        _field("Business Description", controller.descCtrl, maxLines: 3),
        _field("Owner Name", controller.ownerNameCtrl),
        _field("Owner Designation", controller.ownerDesignationCtrl),
        _field("Established Year", controller.estYearCtrl),
        _field("Registration Number", controller.regNumCtrl),
        _field("GST Number", controller.gstNumCtrl),
        _field("PAN Number", controller.panNumCtrl),
        _field("Business License Number", controller.licenseNumCtrl),
      ],
    );
  }
}
