import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'package:manifest_mobile/model/festival.dart';
import 'package:manifest_mobile/model/ticket_type.dart';
import 'package:manifest_mobile/providers/ticket_provider.dart';
import 'package:manifest_mobile/providers/user_provider.dart';

class StripePaymentScreen extends StatefulWidget {
  final Festival festival;
  final TicketType ticketType;
  final double finalPrice;

  const StripePaymentScreen({
    super.key,
    required this.festival,
    required this.ticketType,
    required this.finalPrice,
  });

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = true;
  bool _paymentCompleted = false;

  double amountInUsd = 0.0;
  final double bamToUsdRate = 0.55; // Approximate BAM to USD rate

  final commonDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
    ),
  );

  @override
  void initState() {
    super.initState();
    amountInUsd = widget.finalPrice * bamToUsdRate;
    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> processPayment(Map<String, dynamic> formData) async {
    // Simulate payment processing
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6A1B9A).withOpacity(0.1),
              const Color(0xFF6A1B9A).withOpacity(0.05),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)))
                : _paymentCompleted
                ? buildPaymentSuccessScreen()
                : buildPaymentForm(context),
          ),
        ),
      ),
    );
  }

  Widget buildPaymentSuccessScreen() {
    return Center(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: const Color(0xFF6A1B9A)),
              SizedBox(height: 20),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  color: const Color(0xFF6A1B9A),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Your ticket has been purchased successfully.',
                style: TextStyle(color: Colors.black54, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B9A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6A1B9A).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.festival, color: const Color(0xFF6A1B9A), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ticket Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF6A1B9A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Amount: ${widget.finalPrice.toStringAsFixed(2)} KM',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Festival: ${widget.festival.title}',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ticket Type: ${widget.ticketType.name}',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPaymentForm(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAmountField(),
          const SizedBox(height: 16),
          buildTextField('name', 'Full Name', 
              initialValue: _getUserFullName(),
              placeholder: "John Doe"),
          const SizedBox(height: 10),
          buildTextField('address', 'Address', placeholder: "Street No. 1"),
          const SizedBox(height: 10),
          buildCityAndStateFields(),
          const SizedBox(height: 10),
          buildCountryAndPincodeFields(),
          const SizedBox(height: 20),
          buildQuickFillButtons(),
          const SizedBox(height: 30),
          buildSubmitButton(context),
        ],
      ),
    );
  }

  String _getUserFullName() {
    final user = UserProvider.currentUser;
    if (user != null) {
      return '${user.firstName} ${user.lastName}';
    }
    return '';
  }

  Widget buildAmountField() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6A1B9A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6A1B9A).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.festival, color: const Color(0xFF6A1B9A), size: 20),
              SizedBox(width: 8),
              Text(
                'Payment Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${widget.finalPrice.toStringAsFixed(2)} KM',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            '≈ ${amountInUsd.toStringAsFixed(2)} USD',
            style: TextStyle(color: Colors.black54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildCityAndStateFields() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: buildTextField('city', 'City', placeholder: "Sarajevo"),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: buildTextField('state', 'State/Province', placeholder: "FBiH"),
        ),
      ],
    );
  }

  Widget buildCountryAndPincodeFields() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: buildTextField('country', 'Country', placeholder: "BA"),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: buildTextField(
            'pincode',
            'Postal Code',
            keyboardType: TextInputType.number,
            isNumeric: true,
            placeholder: "71000",
          ),
        ),
      ],
    );
  }

  Widget buildTextField(
    String name,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    bool isNumeric = false,
    String? placeholder,
    String? initialValue,
  }) {
    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      decoration: commonDecoration.copyWith(
        labelText: labelText,
        hintText: placeholder,
      ),
      validator: isNumeric
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'This field is required.',
              ),
              FormBuilderValidators.numeric(
                errorText: 'This field must be numeric',
              ),
            ])
          : FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'This field is required.',
              ),
            ]),
      keyboardType: keyboardType,
    );
  }

  Widget buildQuickFillButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Fill Options',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: const Color(0xFF6A1B9A),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _fillWithPlaceholderData(),
                icon: Icon(Icons.auto_fix_high, color: Colors.white, size: 18),
                label: Text(
                  'Fill Demo Data',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _clearAllFields(),
                icon: Icon(Icons.clear, color: Colors.white, size: 18),
                label: Text(
                  'Clear All',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _fillWithPlaceholderData() {
    final currentState = formKey.currentState;
    if (currentState != null) {
      currentState.patchValue({
        'name': _getUserFullName(),
        'address': 'Ferhadija 12',
        'city': 'Sarajevo',
        'state': 'FBiH',
        'country': 'BA',
        'pincode': '71000',
      });
    }
  }

  void _clearAllFields() {
    final currentState = formKey.currentState;
    if (currentState != null) {
      currentState.reset();
      // Re-set the name field with user's name
      currentState.patchValue({
        'name': _getUserFullName(),
      });
    }
  }

  Widget buildSubmitButton(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A)),
        child: const Text(
          "Proceed to Payment",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        onPressed: () async {
          if (formKey.currentState?.saveAndValidate() ?? false) {
            final formData = formKey.currentState?.value;
            
            try {
              await _processStripePayment(formData!);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment failed: $e'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  // Stripe Payment Methods
  Future<void> initPaymentSheet(Map<String, dynamic> formData) async {
    try {
      // Create a real payment intent
      final data = await createPaymentIntent(
        amount: (amountInUsd * 100).round().toString(),
        currency: 'USD',
        name: formData['name'],
        address: formData['address'],
        pin: formData['pincode'],
        city: formData['city'],
        state: formData['state'],
        country: formData['country'],
      );

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'ManiFest',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    required String name,
    required String address,
    required String pin,
    required String city,
    required String state,
    required String country,
  }) async {
    try {
      // First, create a customer
      final customerResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization':
              'Bearer sk_test_51Q39sMBeXPnhF0hOvSAgJz8QSD5CxoTfQCfAEpMT7QJwYW0LfpgrsSLe2W7H4SnlKRDY6HPnqX2t8pXVDBtzPcW200okymr8j7',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name,
          'email': 'test@example.com',
          'metadata[address]': address,
          'metadata[city]': city,
          'metadata[state]': state,
          'metadata[country]': country,
        },
      );

      if (customerResponse.statusCode != 200) {
        throw Exception('Failed to create customer: ${customerResponse.body}');
      }

      final customerData = jsonDecode(customerResponse.body);
      final customerId = customerData['id'];

      // Create ephemeral key
      final ephemeralKeyResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/ephemeral_keys'),
        headers: {
          'Authorization':
              'Bearer sk_test_51Q39sMBeXPnhF0hOvSAgJz8QSD5CxoTfQCfAEpMT7QJwYW0LfpgrsSLe2W7H4SnlKRDY6HPnqX2t8pXVDBtzPcW200okymr8j7',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Stripe-Version': '2023-10-16',
        },
        body: {'customer': customerId},
      );

      if (ephemeralKeyResponse.statusCode != 200) {
        throw Exception(
          'Failed to create ephemeral key: ${ephemeralKeyResponse.body}',
        );
      }

      final ephemeralKeyData = jsonDecode(ephemeralKeyResponse.body);

      // Create payment intent
      final paymentIntentResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51Q39sMBeXPnhF0hOvSAgJz8QSD5CxoTfQCfAEpMT7QJwYW0LfpgrsSLe2W7H4SnlKRDY6HPnqX2t8pXVDBtzPcW200okymr8j7',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency.toLowerCase(),
          'customer': customerId,
          'payment_method_types[]': 'card',
          'description': 'ManiFest Ticket Payment for ${widget.festival.title}',
          'metadata[name]': name,
          'metadata[address]': address,
          'metadata[city]': city,
          'metadata[state]': state,
          'metadata[country]': country,
          'metadata[festival]': widget.festival.title,
          'metadata[ticketType]': widget.ticketType.name,
        },
      );

      if (paymentIntentResponse.statusCode == 200) {
        final paymentIntentData = jsonDecode(paymentIntentResponse.body);
        return {
          'client_secret': paymentIntentData['client_secret'],
          'ephemeralKey': ephemeralKeyData['secret'],
          'id': customerId,
          'amount': amount,
          'currency': currency,
        };
      } else {
        throw Exception(
          'Failed to create payment intent: ${paymentIntentResponse.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  Future<void> _processStripePayment(Map<String, dynamic> formData) async {
    try {
      await initPaymentSheet(formData);

      await stripe.Stripe.instance.presentPaymentSheet();

      // Create ticket in backend
      await _createTicket();

      setState(() {
        _paymentCompleted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _createTicket() async {
    try {
      final user = UserProvider.currentUser;
      if (user == null) throw Exception('User not found');

      final ticketData = {
        'userId': user.id,
        'festivalId': widget.festival.id,
        'ticketTypeId': widget.ticketType.id,
        'finalPrice': widget.finalPrice,
        'purchaseDate': DateTime.now().toIso8601String(),
      };

      final ticketProvider = TicketProvider();
      await ticketProvider.insert(ticketData);
    } catch (e) {
      throw Exception('Failed to create ticket: $e');
    }
  }
}
