import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../services/shell_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/common.dart';
import '../preferences/preference_rows.dart';
import '../profile/page_layout.dart';
import '../profile/profile_widgets.dart';
import 'edit_profile_viewmodel.dart';

class EditProfileView extends StackedView<EditProfileViewModel> {
  const EditProfileView({super.key});

  @override
  Widget builder(BuildContext context, EditProfileViewModel viewModel, Widget? child) {
    final vm = viewModel;

    void toast(String? message) {
      if (message == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> save() async {
      final messenger = ScaffoldMessenger.of(context);
      if (await vm.save()) {
        messenger.showSnackBar(const SnackBar(content: Text('Profile saved on this device.')));
      }
    }

    Future<void> changePhoto() async => toast(await vm.changePhoto());

    final narrow = MediaQuery.sizeOf(context).width < 360 || MediaQuery.textScalerOf(context).scale(14) / 14 > 1.3;
    final nameField = _LabelledField(
      label: 'Full name',
      child: TextFormField(
        controller: vm.nameController,
        validator: vm.validateName,
        maxLength: EditProfileViewModel.maxLength,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.name],
        decoration: const InputDecoration(hintText: 'Your name', counterText: ''),
      ),
    );
    final phoneField = _LabelledField(
      label: 'Phone number',
      child: TextFormField(
        controller: vm.phoneController,
        validator: vm.validatePhone,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.telephoneNumber],
        decoration: const InputDecoration(hintText: '082 123 4567'),
      ),
    );

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: vm.formKey,
          child: ConstrainedListView(
            top: 0,
            children: [
              const PageHeader(title: 'Edit Profile', subtitle: 'Update your details and preferences.', showBack: true),
              const SectionHeader('Profile picture', padding: EdgeInsets.fromLTRB(16, 16, 8, 8)),
              Padding(
                padding: pagePadding,
                child: AppCard(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ProfileAvatar(photoBase64: vm.photoBase64, radius: 40),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AccentOutlinedButton(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change photo',
                            onPressed: vm.busy(EditProfileViewModel.photoKey) ? null : changePhoto,
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: vm.hasPhoto ? vm.removePhoto : null,
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            label: const Text('Remove photo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.colors.muted,
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SectionHeader('Personal information'),
              Padding(
                padding: pagePadding,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (narrow) ...[
                        nameField,
                        const SizedBox(height: 14),
                        phoneField,
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: nameField),
                            const SizedBox(width: 12),
                            Expanded(child: phoneField),
                          ],
                        ),
                      const SizedBox(height: 14),
                      _LabelledField(
                        label: 'Email address',
                        child: TextFormField(
                          controller: vm.emailController,
                          validator: vm.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(hintText: 'you@example.com'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _LabelledField(
                        label: 'Location',
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('location-${vm.locationRevision}'),
                          initialValue: vm.location,
                          isExpanded: true,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined)),
                          items: [
                            for (final o in vm.locationOptions)
                              DropdownMenuItem(
                                value: o,
                                child: Text(o, overflow: TextOverflow.ellipsis),
                              ),
                          ],
                          onChanged: (v) async {
                            if (v == EditProfileViewModel.otherLocation) {
                              final typed = await showDialog<String>(
                                context: context,
                                builder: (_) => const _OtherAreaDialog(),
                              );
                              vm.setLocation(typed);
                            } else {
                              vm.setLocation(v);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExcludeSemantics(
                            child: Icon(Icons.phone_android_rounded, size: 16, color: context.colors.muted),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Stored on this phone only. Commuttr has no accounts.',
                              style: TextStyle(fontSize: 13, color: context.colors.muted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SectionHeader('Preferences'),
              const PreferenceRows(transportTitle: 'Preferred transport modes'),
              const SectionHeader('Account'),
              NavGroup(
                children: [
                  NavRow(icon: Icons.lock_outline_rounded, title: 'Change password', onTap: vm.changePassword),
                  NavRow(icon: Icons.shield_outlined, title: 'Privacy settings', onTap: vm.openPrivacy),
                  NavRow(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete account',
                    destructive: true,
                    onTap: vm.deleteAccount,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: FilledButton(
                  onPressed: vm.isBusy ? null : save,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  child: const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  EditProfileViewModel viewModelBuilder(BuildContext context) => EditProfileViewModel();
}

/// A grey label above its input, as in the mockup.
class _LabelledField extends StatelessWidget {
  const _LabelledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    container: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(label, style: TextStyle(fontSize: 13, color: context.colors.muted)),
        ),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}

/// Asks for an area that isn't in the Location list.
class _OtherAreaDialog extends StatefulWidget {
  const _OtherAreaDialog();

  @override
  State<_OtherAreaDialog> createState() => _OtherAreaDialogState();
}

class _OtherAreaDialogState extends State<_OtherAreaDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() {
    final v = _controller.text.trim();
    Navigator.pop(context, v.isEmpty ? null : v);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Your area'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      maxLength: EditProfileViewModel.maxLength,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _done(),
      decoration: const InputDecoration(hintText: 'e.g. Athlone'),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: _done, child: const Text('Done')),
    ],
  );
}
