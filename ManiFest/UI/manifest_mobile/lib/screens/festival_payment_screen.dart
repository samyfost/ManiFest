import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:manifest_mobile/model/festival.dart';
import 'package:manifest_mobile/model/ticket_type.dart';
import 'package:manifest_mobile/providers/ticket_type_provider.dart';
import 'package:manifest_mobile/screens/stripe_payment_screen.dart';

class FestivalPaymentScreen extends StatefulWidget {
  final Festival festival;

  const FestivalPaymentScreen({super.key, required this.festival});

  @override
  State<FestivalPaymentScreen> createState() => _FestivalPaymentScreenState();
}

class _FestivalPaymentScreenState extends State<FestivalPaymentScreen> {
  late TicketTypeProvider _ticketTypeProvider;
  List<TicketType> _ticketTypes = [];
  TicketType? _selectedTicketType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTicketTypes();
  }

  Future<void> _loadTicketTypes() async {
    setState(() => _isLoading = true);
    try {
      _ticketTypeProvider = TicketTypeProvider();
      final result = await _ticketTypeProvider.get();
      setState(() {
        _ticketTypes = result.items ?? [];
        if (_ticketTypes.isNotEmpty) {
          _selectedTicketType = _ticketTypes.first;
        }
      });
    } catch (e) {
      // Handle error silently for now
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get _finalPrice {
    if (_selectedTicketType == null) return widget.festival.basePrice;
    return widget.festival.basePrice * _selectedTicketType!.priceMultiplier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFestivalInfo(),
                      const SizedBox(height: 24),
                      _buildTicketTypeSelector(),
                      const SizedBox(height: 24),
                      _buildPriceSummary(),
                      const SizedBox(height: 32),
                      _buildProceedButton(),
                    ],
                  ),
                ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D1B69)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Buy Tickets',
          style: TextStyle(
            color: const Color(0xFF2D1B69),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildFestivalInfo() {
    final festival = widget.festival;
    final imageBytes = (festival.logo != null && festival.logo!.isNotEmpty)
        ? base64Decode(festival.logo!)
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Festival logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageBytes != null
                  ? Image.memory(imageBytes, fit: BoxFit.cover)
                  : const Icon(
                      Icons.festival,
                      size: 40,
                      color: Color(0xFF6A1B9A),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Festival details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  festival.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1B69),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  festival.dateRange,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${festival.cityName}, ${festival.countryName}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Ticket Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D1B69),
          ),
        ),
        const SizedBox(height: 16),
        ...(_ticketTypes.map((ticketType) => _buildTicketTypeCard(ticketType))),
      ],
    );
  }

  Widget _buildTicketTypeCard(TicketType ticketType) {
    final isSelected = _selectedTicketType?.id == ticketType.id;
    final finalPrice = widget.festival.basePrice * ticketType.priceMultiplier;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF6A1B9A)
              : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF6A1B9A).withOpacity(0.15)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _selectedTicketType = ticketType;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Selection indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6A1B9A)
                          : Colors.grey.withOpacity(0.5),
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFF6A1B9A)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                // Ticket type details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticketType.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D1B69),
                        ),
                      ),
                      if (ticketType.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          ticketType.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Base Price: \$${widget.festival.basePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '× ${ticketType.priceMultiplier.toStringAsFixed(1)}x',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF6A1B9A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Final price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${finalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    if (ticketType.priceMultiplier != 1.0)
                      Text(
                        '${ticketType.priceMultiplier > 1 ? '+' : ''}${((ticketType.priceMultiplier - 1) * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: ticketType.priceMultiplier > 1
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600,
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
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base Price',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              Text(
                '\$${widget.festival.basePrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
          if (_selectedTicketType != null &&
              _selectedTicketType!.priceMultiplier != 1.0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedTicketType!.name} Multiplier',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Text(
                  '× ${_selectedTicketType!.priceMultiplier.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF6A1B9A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B69),
                ),
              ),
              Text(
                '\$${_finalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedTicketType == null
            ? null
            : () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => StripePaymentScreen(
                    festival: widget.festival,
                    ticketType: _selectedTicketType!,
                    finalPrice: _finalPrice,
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Proceed to Payment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
