// Amir ERP — futuristic login screen (mandatory Amir Saoudi signature footer).
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/branding.dart';
import '../../core/auth/auth_controller.dart';
import '../../design_system/components/amir_footer.dart';
import '../../design_system/components/amir_glass_card.dart';
import '../../design_system/components/amir_logo.dart';
import '../../design_system/components/animated_background.dart';
import '../../design_system/tokens/theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(text: 'admin@demo.amir-erp.local');
  final _password = TextEditingController(text: 'AmirAdmin#2026');
  final _tenant = TextEditingController(text: 'demo');
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _tenant.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: AmirAnimatedBackground(
        child: SafeArea(
          child: LayoutBuilder(builder: (ctx, c) {
            final wide = c.maxWidth >= 920;
            final cardW = wide ? 880.0 : c.maxWidth.clamp(0.0, 460.0);
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AmirSpacing.lg),
                child: SizedBox(
                  width: cardW,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _topBadge(),
                      const SizedBox(height: AmirSpacing.lg),
                      AmirNeonBorder(
                        borderRadius: BorderRadius.circular(AmirRadius.xl),
                        thickness: 1.2,
                        child: AmirGlassCard(
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(AmirRadius.xl - 1),
                          child: wide
                              ? IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(width: 380, child: _hero()),
                                      const VerticalDivider(width: 1, thickness: 1, color: Color(0x14FFFFFF)),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
                                          child: _form(auth),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(28),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _heroCompact(),
                                      const SizedBox(height: AmirSpacing.xl),
                                      _form(auth),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AmirSpacing.lg),
                      const AmirFooter(),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _topBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AmirRadius.pill),
          border: Border.all(color: AmirColors.secondary.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(color: AmirColors.success, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              'AMIR ERP · v${AmirBranding.version} · ALL SYSTEMS ONLINE',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AmirColors.primary.withValues(alpha: 0.22),
            AmirColors.secondary.withValues(alpha: 0.10),
            const Color(0xFF8B5CF6).withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AmirGlowPulse(
                color: AmirColors.primary,
                borderRadius: BorderRadius.circular(20),
                child: const AmirLogo(size: 56, glow: false),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AmirBranding.appName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.4),
                    ),
                    Text(
                      'Multi-tenant SaaS ERP',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ShaderMask(
            shaderCallback: (r) => AmirGradients.brandSoft.createShader(r),
            child: const Text(
              'Run your business at\nthe speed of light.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.8,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Accounting · Sales · CRM · Inventory · POS · Manufacturing · HR · Projects.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.62), fontSize: 13, height: 1.55),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _Pill(icon: Icons.shield_moon_outlined, label: 'Schema-per-tenant'),
              _Pill(icon: Icons.bolt_outlined, label: 'Offline POS'),
              _Pill(icon: Icons.translate_rounded, label: 'AR · EN · RTL'),
              _Pill(icon: Icons.auto_awesome_outlined, label: 'AI-ready'),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AmirRadius.md),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AmirGradients.brand,
                    borderRadius: BorderRadius.circular(AmirRadius.sm),
                  ),
                  child: const Center(
                    child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AmirBranding.author,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      Text(
                        AmirBranding.authorEmail,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.verified_rounded, color: AmirColors.secondary, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AmirGlowPulse(
              color: AmirColors.primary,
              borderRadius: BorderRadius.circular(16),
              child: const AmirLogo(size: 48, glow: false),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AmirBranding.appName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('Multi-tenant SaaS ERP',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.5)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _form(AuthState auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (r) => AmirGradients.brandSoft.createShader(r),
          child: const Text(
            'Welcome back',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.6, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to your workspace.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
        ),
        const SizedBox(height: 20),
        _field(
          ctrl: _tenant,
          label: 'Workspace',
          hint: 'demo',
          icon: Icons.business_rounded,
        ),
        const SizedBox(height: 12),
        _field(
          ctrl: _email,
          label: 'Email',
          hint: 'you@company.com',
          icon: Icons.alternate_email_rounded,
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _field(
          ctrl: _password,
          label: 'Password',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscure: _obscure,
          suffix: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
          ),
        ),
        if (auth.error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AmirColors.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AmirRadius.sm),
              border: Border.all(color: AmirColors.danger.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AmirColors.danger, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    auth.error!,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        _PrimaryButton(
          loading: auth.loading,
          onTap: () => ref.read(authControllerProvider.notifier).login(
                email: _email.text,
                password: _password.text,
                tenant: _tenant.text,
              ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 14, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(width: 6),
            Text(
              'Secured with JWT + Argon2id',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboard,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: suffix,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AmirRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AmirColors.secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;
  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        decoration: BoxDecoration(
          gradient: AmirGradients.brand,
          borderRadius: BorderRadius.circular(AmirRadius.md),
          boxShadow: [
            BoxShadow(
              color: AmirColors.primary.withValues(alpha: _hover ? 0.7 : 0.45),
              blurRadius: _hover ? 26 : 18,
              spreadRadius: -3,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AmirRadius.md),
            onTap: widget.loading ? null : widget.onTap,
            child: Center(
              child: widget.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
