import 'package:flutter/material.dart';
import 'package:profitara/models/stock.dart';

import '../stock_details_page.dart';

class StockTile extends StatelessWidget {
  final Stock stock;

  const StockTile({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final (qtyDisplay, qtyUnit) = stock.getDisplayQuantity();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
      child: Card(
        child: ListTile(
          title: Text(stock.name),
          subtitle: Text(
            'Qty: ${qtyDisplay.toStringAsFixed(qtyDisplay.truncateToDouble() == qtyDisplay ? 0 : 2)} $qtyUnit',
          ),
          trailing: stock.isLowStock
              ? const Icon(Icons.warning, color: Colors.red)
              : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StockDetailsPage(stockId: stock.id),
              ),
            );
          },
        ),
      ),
    );
  }
}
