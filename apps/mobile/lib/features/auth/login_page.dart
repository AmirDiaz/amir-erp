// Amir ERP — login screen with mandatory Amir Saoudi footer.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/branding.dart';
import '../../core/auth/auth_controller.dart';
import '../../design_system/components/amir_footer.dart';
import '../../design_system/components/amir_logo.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(text: 'admin@demo.amir-erp.local');
  final _password = TextEditingController(text: 'AmirAdmin#2026');
  final _tenant = TextEditingController(text: 'demo');

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 920 : 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Center(child: AmirLogo(size: 64)),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              AmirBranding.appName,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Center(
                            child: Text(
                              AmirBranding.tagline,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _tenant,
                            decoration: const InputDecoration(labelText: 'Tenant', prefixIcon: Icon(Icons.domain)),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _email,
                            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.alternate_email)),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _password,
                            decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                            obscureText: true,
                          ),
                          if (auth.error != null) ...[
                            const SizedBox(height: 12),
                            Text(auth.error!, style: const TextStyle(color: Colors.redAccent)),
                          ],
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: auth.loading
                                ? null
                                : () => ref.read(authControllerProvider.notifier).login(
                                      email: _email.text,
                                      password: _password.text,
                                      tenant: _tenant.text,
                                    ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: auth.loading
                                  ? const SizedBox(
                                      height: 18, width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Sign In'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AmirFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
