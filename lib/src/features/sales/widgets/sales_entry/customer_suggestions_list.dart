import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/customer_model.dart';

class CustomerSuggestionsList extends StatelessWidget {
  final List<CustomerModel> customers;
  final ValueChanged<CustomerModel> onSelected;

  const CustomerSuggestionsList({
    super.key,
    required this.customers,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        color: Theme.of(context).cardColor,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: customers.length,
        separatorBuilder: (ctx, idx) => const Divider(height: 1),
        itemBuilder: (ctx, idx) {
          final customer = customers[idx];
          return ListTile(
            dense: true,
            leading: const CircleAvatar(
              radius: 14,
              child: Icon(Icons.person, size: 14),
            ),
            title: Text(
              customer.name,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              customer.phoneNumber,
              style: GoogleFonts.outfit(fontSize: 11),
            ),
            onTap: () => onSelected(customer),
          );
        },
      ),
    );
  }
}
