import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class NoAdPaywall extends StatefulWidget {
  const NoAdPaywall({super.key});

  @override
  State<NoAdPaywall> createState() => _NoAdPaywallState();
}

class _NoAdPaywallState extends State<NoAdPaywall> {
  var products = Purchases.getProducts(['no_ads_lifetime'],productCategory: ProductCategory.nonSubscription);


  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}
