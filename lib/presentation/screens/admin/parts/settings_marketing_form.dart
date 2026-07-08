part of '../system_settings_screen.dart';

extension _SettingsMarketingFormExtension on _SystemSettingsScreenState {
  Widget _buildHomepageForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("HOMEPAGE COPYWRITING", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Hero Title", _homeHeroTitle),
        _field("Hero Subtitle", _homeHeroSubtitle),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('homepage', () async {
                final current = AppConfigService.to.rxHomepageSettings.value;
                await _repository.saveHomepage(
                  HomepageSettings(
                    heroTitle: _homeHeroTitle.text,
                    heroSubtitle: _homeHeroSubtitle.text,
                    heroEyebrow: current.heroEyebrow,
                    heroButtons: current.heroButtons,
                    heroImages: current.heroImages,
                    heroVideo: current.heroVideo,
                    heroBadge: current.heroBadge,
                    statistics: current.statistics,
                    benefits: current.benefits,
                    faqs: current.faqs,
                    about: current.about,
                    cta: current.cta,
                    whyChooseUs: current.whyChooseUs,
                    galleryHeader: current.galleryHeader,
                    reviewHeader: current.reviewHeader,
                    faqHeader: current.faqHeader,
                    sectionVisibility: current.sectionVisibility,
                    sectionOrder: current.sectionOrder,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildAboutForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ABOUT US DETAILS", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Description", _aboutDesc),
        _field("Mission", _aboutMission),
        _field("Vision", _aboutVision),
        _field("Story Text", _aboutStory),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('about', () async {
                await _repository.saveAbout(
                  AboutSettings(
                    description: _aboutDesc.text,
                    mission: _aboutMission.text,
                    vision: _aboutVision.text,
                    story: _aboutStory.text,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("CONTACT DETAILS", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Contact Phone", _contactPhone),
        _field("Contact Email", _contactEmail),
        _field("WhatsApp prefilled text", _contactWhatsapp),
        _field("Google Maps URL", _contactMaps),
        const SizedBox(height: 12),
        Text(
          "Note: Branch office addresses, city, pin code and geolocations are managed dynamically under the 'Business Profile' tab.",
          style: AppTheme.sansBody(
            fontSize: 12,
            color: const Color(0xFFC9A77E),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('contact', () async {
                final bus = AppConfigService.to.rxBusinessProfile.value;
                final primaryBranch = bus.officeBranches.firstWhere(
                  (b) => b.isPrimary,
                  orElse: () => bus.officeBranches.first,
                );

                await _repository.saveContact(
                  ContactSettings(
                    phone: _contactPhone.text,
                    email: _contactEmail.text,
                    whatsapp: _contactWhatsapp.text,
                    address: primaryBranch.address,
                    googleMaps: _contactMaps.text,
                    branches: bus.officeBranches.map((b) => b.toMap()).toList(),
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildFooterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("FOOTER CONFIG", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Footer Description", _footerDesc),
        _field("Copyright line", _footerCopy),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('footer', () async {
                final current = AppConfigService.to.rxFooterSettings.value;
                await _repository.saveFooter(
                  FooterSettings(
                    description: _footerDesc.text,
                    copyright: _footerCopy.text,
                    quickLinks: current.quickLinks,
                    legalLinks: current.legalLinks,
                    contact: current.contact,
                    socialLinks: current.socialLinks,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildSEOForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SEO META CONFIG", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Default Page Title", _seoTitle),
        _field("Meta Keywords (comma separated)", _seoKeywords),
        _field("Meta Description", _seoDesc),
        _field("Canonical URL", _seoCanonical),
        _field("Robots settings", _seoRobots),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('seo', () async {
                final current = AppConfigService.to.rxSEOSettings.value;
                await _repository.saveSEO(
                  SEOSettings(
                    defaultTitle: _seoTitle.text,
                    metaDescription: _seoDesc.text,
                    keywords: _seoKeywords.text,
                    canonicalUrl: _seoCanonical.text,
                    openGraph: current.openGraph,
                    twitterCard: current.twitterCard,
                    jsonLd: current.jsonLd,
                    robots: _seoRobots.text,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildCtaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CUSTOM HERO CTA BUTTON",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Button text", _ctaText),
        _field("Action redirect url", _ctaUrl),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('cta', () async {
                await _repository.saveCta(
                  CtaSettings(
                    buttonText: _ctaText.text,
                    buttonUrl: _ctaUrl.text,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildGalleryGridForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("GALLERY GRID SETUP", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Grid Columns Count", _galleryColumns),
        CheckboxListTile(
          title: const Text("Enable Grid view layout"),
          value: _galleryGridEnable,
          onChanged: (v) {
            updateState(() {
              _galleryGridEnable = v ?? true;
            });
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('gallery_settings', () async {
                await _repository.saveGallerySettings(
                  GallerySettings(
                    enableGrid: _galleryGridEnable,
                    columns: int.tryParse(_galleryColumns.text) ?? 3,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildFaqAccordionsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("FAQ TITLE CONFIG", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("FAQ Accordions Section Title", _faqTitle),
        CheckboxListTile(
          title: const Text("Enable accordion expansion tiles"),
          value: _faqAccordionEnable,
          onChanged: (v) {
            updateState(() {
              _faqAccordionEnable = v ?? true;
            });
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('faq_settings', () async {
                await _repository.saveFaqSettings(
                  FaqSettings(
                    title: _faqTitle.text,
                    enableAccordion: _faqAccordionEnable,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }
}
