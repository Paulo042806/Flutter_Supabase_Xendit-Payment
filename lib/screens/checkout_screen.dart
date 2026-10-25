
import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const CheckoutScreen({
    super.key,
    required this.items,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();

  String _payment = 'gcash';
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final result = await PaymentService.checkout(
        widget.items,
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        notes: _notes.text.trim(),
        paymentMethod: _payment,
      );

      if (!mounted) return;

      final checkoutUrl = result['checkout_url']?.toString();
      final orderId = result['order_id']?.toString() ?? '';

      if (_payment == 'cod') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Order Placed!'),
            content: Text(
              'Your COD order has been saved.\nOrder ID: $orderId',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context, true);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      } else if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Order Created'),
            content: const Text(
              'Your order is saved. Open the secure Xendit page '
              'to complete payment using an available payment method.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Later'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context, checkoutUrl);
                },
                child: const Text('Continue to Payment'),
              ),
            ],
          ),
        );
      } else {
        throw Exception(
          result['error']?.toString() ?? 'Checkout URL not returned.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int lines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required.';
          }
          return null;
        },
      ),
    );
  }

  Widget _paymentOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      child: RadioListTile<String>(
        value: value,
        groupValue: _payment,
        onChanged: (value) {
          if (value != null) setState(() => _payment = value);
        },
        secondary: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Delivery Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _field(_name, 'Full Name'),
            _field(
              _phone,
              'Contact Number',
              keyboardType: TextInputType.phone,
            ),
            _field(_address, 'Complete Delivery Address', lines: 3),
            _field(_notes, 'Delivery Notes (Optional)'),
            const SizedBox(height: 8),
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _paymentOption(
              'gcash',
              'GCash / E-wallet',
              'Pay online through the available Xendit options',
              Icons.phone_android,
            ),
            _paymentOption(
              'card',
              'Credit / Debit Card',
              'Subject to available Xendit payment channels',
              Icons.credit_card,
            ),
            _paymentOption(
              'online_bank',
              'Online Banking',
              'Subject to available Xendit payment channels',
              Icons.account_balance,
            ),
            _paymentOption(
              'cod',
              'Cash on Delivery',
              'Pay when your order arrives',
              Icons.payments,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _placeOrder,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
