// lib/features/suppliers/presentation/widgets/list/agreement_filters.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

class AgreementFilters extends ConsumerStatefulWidget {
  const AgreementFilters({super.key});

  @override
  ConsumerState<AgreementFilters> createState() => _AgreementFiltersState();
}

class _AgreementFiltersState extends ConsumerState<AgreementFilters> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedStatus = ref.watch(statusFilterProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث عن مورد أو تفاصيل اتفاقية...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: selectedStatus == null,
                  onSelected: (_) => ref.read(statusFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('قيد التسليم'),
                  selected: selectedStatus == 'pending_delivery',
                  onSelected: (_) => ref.read(statusFilterProvider.notifier).state = 'pending_delivery',
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  selectedColor: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('مكتمل'),
                  selected: selectedStatus == 'completed',
                  onSelected: (_) => ref.read(statusFilterProvider.notifier).state = 'completed',
                  backgroundColor: Colors.green.withOpacity(0.1),
                  selectedColor: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('ملغي'),
                  selected: selectedStatus == 'cancelled',
                  onSelected: (_) => ref.read(statusFilterProvider.notifier).state = 'cancelled',
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  selectedColor: Colors.grey.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
