// Amir ERP — login screen with mandatory Amir Saoudi footer.
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
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final screenW = MediaQuery.of(context).size.width;
    final isWide = screenW >= 1000;
    final cardW = isWide ? screenW.clamp(1000.0, 1100.0) : screenW.clamp(0.0, 460.0);

    return Scaffold(
      body: AmirAnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AmirSpacing.lg),
              child: SizedBox(
                width: cardW.toDouble(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isWide ? _wideLayout(auth) : _form(auth),
                    const SizedBox(height: AmirSpacing.lg),
                    const AmirFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wideLayout(AuthState auth) {
    return SizedBox(
      height: 620,
      child: AmirGlassCard(
        padding: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _hero()),
            Container(
              width: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: _form(auth, embedded: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AmirColors.primary.withValues(alpha: 0.18),
            AmirColors.secondary.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AmirLogo(size: 72),
          const SizedBox(height: AmirSpacing.lg),
          ShaderMask(
            shaderCallback: (r) => AmirGradients.brandSoft.createShader(r),
            child: const Text(
              'Run your business at\nthe speed of light.',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1.2,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: AmirSpacing.md),
          Text(
            'Multi-tenant SaaS ERP — accounting, sales, CRM, inventory, POS, manufacturing, HR, and more.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: AmirSpacing.xl),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _Pill(icon: Icons.lock_outline, label: 'Schema-per-tenant'),
              _Pill(icon: Icons.bolt_outlined, label: 'Offline-first POS'),
              _Pill(icon: Icons.translate, label: 'AR · EN · RTL'),
              _Pill(icon: Icons.layers_outlined, label: '20+ modules'),
            ],
          ),
          const SizedBox(height: AmirSpacing.xxl),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AmirColors.primary.withValues(alpha: 0.2),
                child: const Icon(Icons.person, size: 18, color: AmirColors.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AmirBranding.author,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(
                    AmirBranding.authorEmail,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _form(AuthState auth, {bool embedded = false}) {
    final inner = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!embedded) ...[
          const Center(child: AmirLogo(size: 72)),
          const SizedBox(height: AmirSpacing.md),
        ],
        ShaderMask(
          shaderCallback: (r) => AmirGradients.brandSoft.createShader(r),
          child: Text(
            embedded ? 'Welcome back' : AmirBranding.appName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          embedded ? 'Sign in to your workspace.' : AmirBranding.tagline,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
        ),
        const SizedBox(height: AmirSpacing.xl),
        TextField(
          controller: _tenant,
          decoration: const InputDecoration(
            labelText: 'Workspace',
            prefixIcon: Icon(Icons.domain_outlined),
            hintText: 'demo',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _email,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.alternate_email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _password,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
        ),
        if (auth.error != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AmirColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AmirRadius.md),
              border: Border.all(color: AmirColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AmirColors.danger, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    auth.error!,
                    style: const TextStyle(color: AmirColors.danger, fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AmirSpacing.lg),
        _GradientButton(
          loading: auth.loading,
          onTap: () => ref.read(authControllerProvider.notifier).login(
                email: _email.text,
                password: _password.text,
                tenant: _tenant.text,
              ),
          label: 'Sign In',
          icon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: AmirSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 14, color: AmirColors.muted.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Text(
              'Secured with JWT + Argon2id',
              style: TextStyle(color: AmirColors.muted.withValues(alpha: 0.7), fontSize: 11),
            ),
          ],
        ),
      ],
    );

    if (embedded) return inner;
    return AmirGlassCard(
      padding: const EdgeInsets.all(36),
      glow: true,
      child: inner,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AmirRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AmirColors.secondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.onTap, required this.label, required this.icon, this.loading = false});
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(AmirRadius.md),
      child: Ink(
        decoration: BoxDecoration(
          gradient: AmirGradients.brand,
          borderRadius: BorderRadius.circular(AmirRadius.md),
          boxShadow: [
            BoxShadow(
              color: AmirColors.primary.withValues(alpha: 0.45),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(
                  height: 22, width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.white, size: 18),
                  ],
                ),
        ),
      ),
    );
  }
}
