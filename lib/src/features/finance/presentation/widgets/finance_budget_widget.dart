import 'package:flutter/material.dart';
import 'package:nex_app/src/core/theme/app_theme.dart';

class FinanceBudgetWidget extends StatelessWidget {
  const FinanceBudgetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for Budget Control
    final categories = [
      {'name': 'Mill Operations', 'allocated': 120000, 'used': 85000},
      {'name': 'Estate Maintenance', 'allocated': 80000, 'used': 65000},
      {'name': 'Logistics & Transport', 'allocated': 50000, 'used': 48000},
      {'name': 'Human Resources', 'allocated': 30000, 'used': 15000},
      {'name': 'Marketing & Sales', 'allocated': 25000, 'used': 10000},
    ];

    double totalAllocated = 0;
    double totalUsed = 0;
    for (var c in categories) {
      totalAllocated += (c['allocated'] as int);
      totalUsed += (c['used'] as int);
    }
    final totalPercentage = totalUsed / totalAllocated;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Control',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Budget Summary Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Budget Overview',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${totalAllocated.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(totalPercentage * 100).toInt()}% Used',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalPercentage,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Used: \$${totalUsed.toInt()}',
                        style: const TextStyle(color: Colors.white70)),
                    Text('Remaining: \$${(totalAllocated - totalUsed).toInt()}',
                        style: const TextStyle(color: Colors.white70)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Text(
            'Budget Allocation by Department',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 16),

          // Department breakdown
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final alloc = cat['allocated'] as int;
              final used = cat['used'] as int;
              final pct = used / alloc;

              Color progressColor = Colors.green;
              if (pct > 0.85) progressColor = Colors.orange;
              if (pct > 0.95) progressColor = Colors.red;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cat['name'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '\$$used / \$$alloc',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
