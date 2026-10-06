import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/team_member.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/member_avatar.dart';
import 'home_shell.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  List<TeamMember> _members = [];
  String? _selectedId;
  bool _showMemberError = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    final members = await StorageService.loadMembers();
    if (!mounted) return;
    setState(() => _members = members);
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  Future<void> _signIn() async {
    final emailValid = _formKey.currentState!.validate();
    final memberId = _selectedId;
    setState(() => _showMemberError = memberId == null);
    if (!emailValid || memberId == null) return;

    await StorageService.signIn(memberId, _emailController.text.trim());
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Center(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      PhosphorIconsRegular.checkSquareOffset,
                      size: 32,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'TaskMate',
                  textAlign: TextAlign.center,
                  style: AppText.cardTitle,
                ),
                const SizedBox(height: 16),
                const Text.rich(
                  TextSpan(
                    text: 'Plan. Track.\n',
                    children: [
                      TextSpan(
                        text: 'Deliver together.',
                        style: TextStyle(color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: AppText.number,
                ),
                const SizedBox(height: 16),
                const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      icon: PhosphorIconsRegular.wifiSlash,
                      label: 'Works offline',
                    ),
                    _Pill(
                      icon: PhosphorIconsRegular.deviceMobile,
                      label: 'Saved on this device',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(PhosphorIconsRegular.envelopeSimple),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 24),
                const Text('WHO ARE YOU?', style: AppText.caps),
                const SizedBox(height: 8),
                for (final member in _members)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      borderColor: member.id == _selectedId
                          ? AppColors.primaryDark
                          : AppColors.outline,
                      onTap: () => setState(() {
                        _selectedId = member.id;
                        _showMemberError = false;
                      }),
                      child: Row(
                        children: [
                          MemberAvatar(
                            members: _members,
                            memberId: member.id,
                            radius: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(member.role, style: AppText.secondary),
                              ],
                            ),
                          ),
                          Icon(
                            member.id == _selectedId
                                ? PhosphorIconsFill.radioButton
                                : PhosphorIconsRegular.circle,
                            color: member.id == _selectedId
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_showMemberError)
                  const Padding(
                    padding: EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      'Choose who you are',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _signIn,
                  child: const Text('SIGN IN'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppText.secondary),
        ],
      ),
    );
  }
}
