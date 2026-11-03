import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:torch_light/torch_light.dart';

class FlashHomePage extends StatefulWidget {
  const FlashHomePage({super.key});

  @override
  State<FlashHomePage> createState() => _FlashHomePageState();
}

class _FlashHomePageState extends State<FlashHomePage> {
  // Replace this with your Razorpay dashboard Key ID before going live.
  // Test key: https://dashboard.razorpay.com/app/keys (Test Mode)
  static const String _razorpayKeyId = 'rzp_test_TPXGipX4mAPX7m';

  late final Razorpay _razorpay;
  bool _isOn = false;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    if (_isOn) {
      TorchLight.disableTorch();
    }
    super.dispose();
  }

  Future<void> _turnOn() async {
    try {
      await TorchLight.enableTorch();
      if (!mounted) return;
      setState(() => _isOn = true);
    } catch (e) {
      _showSnack('Flash on aakan pattiyilla: torch illatha device aayirikkam.');
    }
  }

  Future<void> _turnOff() async {
    try {
      await TorchLight.disableTorch();
      if (!mounted) return;
      setState(() => _isOn = false);
    } catch (e) {
      _showSnack('Flash off aakan pattiyilla.');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openRazorpayCheckout() {
    setState(() => _isProcessingPayment = true);

    final options = {
      'key': _razorpayKeyId,
      'amount': 500, // amount in paise -> Rs 1.00
      'name': 'Flash Pay',
      'description': 'Turn OFF flashlight',
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#FFC107'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
      _showSnack('Razorpay open cheyyan pattiyilla: $e');
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    if (!mounted) return;
    setState(() => _isProcessingPayment = false);
    _showSnack('Payment successful (ID: ${response.paymentId})');
    _turnOff();
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isProcessingPayment = false);
    _showSnack('Payment failed: ${response.message ?? "Unknown error"}');
  } 

  void _onExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() => _isProcessingPayment = false);
    _showSnack('External wallet selected: ${response.walletName}');
  }

  Future<void> _requestPaymentToTurnOff() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Off aakanel pay cheyyanam',
              style: TextStyle(color: Colors.amber),
            ),
            content: const Text(
              'Flash off aakan Rs 1 pay cheyyanam.\nContinue cheyyano?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: const Text(
                  'Pay Rs 1',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      _openRazorpayCheckout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isOn ? Icons.flash_on : Icons.flash_off,
                size: 120,
                color: _isOn ? Colors.amber : Colors.white24,
              ),
              const SizedBox(height: 32),
              Text(
                _isOn ? 'FLASH ON' : 'FLASH OFF',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isOn ? Colors.amber : Colors.white38,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
              if (_isProcessingPayment)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Colors.amber),
                    SizedBox(height: 12),
                    Text(
                      'Payment processing...',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: () {
                    if (_isOn) {
                      _requestPaymentToTurnOff();
                    } else {
                      _turnOn();
                    }
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isOn ? Colors.amber : Colors.white10,
                      boxShadow:
                          _isOn
                              ? [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ]
                              : [],
                    ),
                    child: Icon(
                      Icons.power_settings_new,
                      size: 60,
                      color: _isOn ? Colors.black : Colors.white38,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                _isOn
                    ? 'Off '
                    : 'On ',
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
