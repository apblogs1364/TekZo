import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:tekzo/config/keys.dart';
import 'package:tekzo/screens/ConfirmOrderScreen.dart';

class PaymentService {
  PaymentService() {
    // Register Razorpay listeners once when the service is created.
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final Razorpay _razorpay;

  BuildContext? _context;
  String? _userId;
  String? _userEmail;
  String? _userPhone;
  List<Map<String, dynamic>> _cartItems = [];
  double _subTotal = 0;
  double _discountAmount = 0;
  double _shippingCost = 0;
  double _totalAmount = 0;

  Future<void> openCheckout({
    required BuildContext context,
    required int amount,
    required String userId,
    required String userEmail,
    required String userPhone,
    required List cartItems,
    double? subTotal,
    double? discountAmount,
    double shippingCost = 0,
    double? totalAmount,
  }) async {
    _context = context;
    _userId = userId;
    _userEmail = userEmail;
    _userPhone = userPhone;
    _cartItems = cartItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    _subTotal = subTotal ?? _inferSubTotal(_cartItems);
    _discountAmount = discountAmount ?? _inferDiscountAmount(_cartItems);
    _shippingCost = shippingCost;
    _totalAmount = totalAmount ?? (_subTotal - _discountAmount + _shippingCost);

    // Razorpay accepts the amount in paise, so convert from rupees here.
    final options = <String, dynamic>{
      'key': razorpayKey,
      'amount': amount * 100,
      'name': 'TekZo',
      'description': 'Order Payment',
      'prefill': {'contact': userPhone, 'email': userEmail},
      'theme': {'color': '#5D70F5'},
    };

    try {
      _razorpay.open(options);
    } catch (error) {
      _showSnackBar('Unable to open payment: $error');
    }
  }

  void dispose() {
    // Clear listeners when the service is no longer needed.
    _razorpay.clear();
  }

  double _inferSubTotal(List<Map<String, dynamic>> items) {
    return items.fold<double>(0, (sum, item) {
      final quantity = (item['quantity'] as num?)?.toDouble() ?? 1;
      final originalPrice = _originalUnitPrice(item);
      return sum + (originalPrice * quantity);
    });
  }

  double _inferDiscountAmount(List<Map<String, dynamic>> items) {
    return items.fold<double>(0, (sum, item) {
      final quantity = (item['quantity'] as num?)?.toDouble() ?? 1;
      final originalPrice = _originalUnitPrice(item);
      final discountedPrice = _discountedUnitPrice(item);
      return sum + ((originalPrice - discountedPrice) * quantity);
    });
  }

  double _originalUnitPrice(Map<String, dynamic> item) {
    final originalPrice = item['originalPrice'];
    if (originalPrice is num) {
      return originalPrice.toDouble();
    }

    final discountedPrice = item['discountedPrice'] ?? item['price'] ?? 0;
    final double priceValue = discountedPrice is num
        ? discountedPrice.toDouble()
        : 0.0;
    return priceValue;
  }
  

  double _discountedUnitPrice(Map<String, dynamic> item) {
    final discountedPrice = item['discountedPrice'] ?? item['price'] ?? 0;
    return discountedPrice is num ? discountedPrice.toDouble() : 0;
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final context = _context;
    final userId = _userId;
    if (context == null || userId == null) {
      return;
    }

    try {
      // Store the paid order in Firestore.
      final paymentId = response.paymentId ?? '';
      final orderRef = _db.collection('orders').doc();

      await orderRef.set({
        'userId': userId,
        'items': _cartItems,
        'subTotal': _subTotal,
        'discountAmount': _discountAmount,
        'shippingCost': _shippingCost,
        'totalAmount': _totalAmount,
        'paymentMethod': 'razorpay',
        'paymentStatus': 'paid',
        'paymentId': paymentId,
        'orderStatus': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userEmail': _userEmail,
        'userPhone': _userPhone,
        'razorpayOrderId': response.orderId ?? '',
      });

      await _db.collection('users').doc(userId).collection('cart').get().then((
        snapshot,
      ) async {
        // Clear the user's cart after the order is created.
        final batch = _db.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment successful')));

      // Move directly to the confirmation screen after successful payment.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmOrderScreen(totalAmount: _totalAmount),
        ),
      );
    } catch (error) {
      _showSnackBar('Order save failed: $error');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackBar('Payment failed: ${response.message ?? 'Unknown error'}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar('External wallet selected: ${response.walletName}');
  }

  void _showSnackBar(String message) {
    final context = _context;
    if (context == null || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
