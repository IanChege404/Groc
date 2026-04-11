import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_defaults.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/services/firestore_service.dart';
import 'components/new_card_row.dart';
import 'components/default_card.dart';
import 'components/payment_option_tile.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final _firestoreService = FirestoreService();
  bool _loading = true;
  List<Map<String, dynamic>> _methods = const [];

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _methods = const [];
      });
      return;
    }

    final methods = await _firestoreService.getPaymentMethods(user.uid);
    if (!mounted) return;
    setState(() {
      _methods = methods;
      _loading = false;
    });
  }

  Future<void> _deleteMethod(String methodId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestoreService.deletePaymentMethod(user.uid, methodId);
    if (!mounted) return;
    await _loadMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Payment Option'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMethods,
              child: ListView(
                children: [
                  const SizedBox(height: AppDefaults.padding),
                  const AddNewCardRow(),
                  if (_methods.isNotEmpty) const PaymentDefaultCard(),
                  Padding(
                    padding: const EdgeInsets.all(AppDefaults.padding),
                    child: Text(
                      'Saved Payment Methods',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (_methods.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppDefaults.padding),
                      child: Text('No saved payment methods yet'),
                    )
                  else
                    ..._methods.map(
                      (method) => PaymentOptionTile(
                        icon: (method['brand'] as String?) == 'mastercard'
                            ? 'https://i.imgur.com/7pI5714.png'
                            : 'https://i.imgur.com/lLUcMC1.png',
                        label: (method['label'] as String?) ?? 'Card',
                        accountName:
                            '•••• ${method['last4'] as String? ?? '0000'}',
                        onTap: () => _deleteMethod(method['id'] as String),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
