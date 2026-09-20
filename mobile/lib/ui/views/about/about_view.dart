import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../core/config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/common.dart';
import 'about_viewmodel.dart';

class AboutView extends StackedView<AboutViewModel> {
  const AboutView({super.key});

  @override
  Widget builder(BuildContext context, AboutViewModel viewModel, Widget? child) => Scaffold(
    appBar: AppBar(title: const Text('About')),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const SizedBox(height: 16),
              const Center(child: BrandMark(size: 72)),
              const SizedBox(height: 16),
              Text(AppConfig.appName, textAlign: TextAlign.center, style: context.text.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Plan smarter. Move better.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.muted),
              ),
              const SizedBox(height: 4),
              Text(
                'Version ${viewModel.version}',
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(color: context.colors.muted),
              ),
              const SectionHeader('Timetable data'),
              NavGroup(
                children: [
                  NavRow(icon: Icons.inventory_2_outlined, title: 'Data snapshot', subtitle: viewModel.dataSnapshot),
                  NavRow(icon: Icons.update_rounded, title: 'Last refreshed', subtitle: viewModel.lastRefreshed),
                  NavRow(
                    icon: Icons.storage_rounded,
                    title: 'Offline & data',
                    subtitle: 'Refresh timetables, backup, erase',
                    onTap: viewModel.openOfflineData,
                  ),
                ],
              ),
              const SectionHeader('Sources & attribution'),
              NavGroup(
                children: [
                  NavRow(
                    icon: Icons.directions_bus_outlined,
                    title: 'Bus timetables and fares',
                    subtitle: "Golden Arrow Bus Services' published PDF timetables and fare tables (gabs.co.za)",
                    trailing: Icon(Icons.open_in_new_rounded, size: 18, color: context.colors.muted),
                    onTap: () => _open(context, viewModel.openGoldenArrow),
                  ),
                  NavRow(
                    icon: Icons.directions_bus_outlined,
                    title: 'MyCiTi timetables',
                    subtitle:
                        "MyCiTi: City of Cape Town's published route timetables (myciti.org.za); "
                        'stop positions © OpenStreetMap contributors',
                    trailing: Icon(Icons.open_in_new_rounded, size: 18, color: context.colors.muted),
                    onTap: () => _open(context, viewModel.openMyCiti),
                  ),
                  NavRow(
                    icon: Icons.train_outlined,
                    title: 'Train timetables and fares',
                    subtitle: "Metrorail's (PRASA's) published timetables and fare zones (metrorail.co.za)",
                    trailing: Icon(Icons.open_in_new_rounded, size: 18, color: context.colors.muted),
                    onTap: () => _open(context, viewModel.openMetrorail),
                  ),
                  NavRow(
                    icon: Icons.map_outlined,
                    title: 'Maps',
                    subtitle: '© OpenStreetMap contributors',
                    trailing: Icon(Icons.open_in_new_rounded, size: 18, color: context.colors.muted),
                    onTap: () => _open(context, viewModel.openOsm),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: InfoBanner(
                  message:
                      'Commuttr is an independent app. It is not affiliated with or endorsed by Golden Arrow '
                      'Bus Services, Metrorail (PRASA) or MyCiTi (City of Cape Town). Times are scheduled times '
                      'from published timetables, not live. Fares are the last published cash fares and may have '
                      'changed. MyCiTi fares are not shown yet.',
                ),
              ),
              const SectionHeader('Legal'),
              NavGroup(
                children: [
                  NavRow(icon: Icons.gavel_rounded, title: 'Terms & conditions', onTap: viewModel.openTerms),
                  NavRow(icon: Icons.privacy_tip_outlined, title: 'Privacy policy', onTap: viewModel.openPrivacy),
                  NavRow(
                    icon: Icons.code_rounded,
                    title: 'Open-source licences',
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: AppConfig.appName,
                      applicationVersion: viewModel.version,
                      applicationIcon: const Padding(padding: EdgeInsets.all(8), child: BrandMark(size: 48)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _open(BuildContext context, Future<bool> Function() open) async {
    final ok = await open();
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't open a browser.")));
    }
  }

  @override
  AboutViewModel viewModelBuilder(BuildContext context) => AboutViewModel();
}
