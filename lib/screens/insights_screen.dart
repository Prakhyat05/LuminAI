import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDthhpAKoH78TSOWx54_2-xGXJ5q2dB58dRn6iyglhJvPfgBs0lf3jnIFUqEPBP8I_BxIT4JKWKOSCk7crEAEIaWJTIiM_5mL581MZ9wWvlav-xBdbvV1I-_i1Uwm6jxFRsnBBmkT_HpGKFA7XUDWkNLSO9otBzUVK6uFlD9-8HKh74WYRiYvL_dUDD26dKvFkO4qf2kV-_98f6efQakptEZ1fcODaUqHQS6Zkl9rvG6o2LeZWu2dkHjBLN4y2FFNISYJaQ7S-Hxe0'),
            ),
            const SizedBox(width: 12),
            Text(
              'LuminAI',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.colorScheme.surfaceContainer,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Text(
              'Health Insights',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Your daily biometric summary',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // AI Summary Card (Hero)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.surfaceContainer),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primaryContainer.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome,
                        color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI COACH SUMMARY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your recovery is peaking—perfect time for a high-intensity session. Resting heart rate is down 4bpm from your weekly average, indicating optimal readiness.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bento Grid Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recovery & Sleep Ring Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border:
                          Border.all(color: theme.colorScheme.surfaceContainer),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SLEEP QUALITY',
                                    style: theme.textTheme.labelSmall),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text('85',
                                        style: theme.textTheme.displayLarge),
                                    Text('%',
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant)),
                                  ],
                                ),
                              ],
                            ),
                            Icon(Icons.bedtime,
                                color: theme.colorScheme.onSurfaceVariant),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: 0.85,
                              strokeWidth: 8,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Deep Sleep',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant)),
                            Text('2h 15m', style: theme.textTheme.titleLarge),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.6,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Weekly Activity Bar Chart Card
                Expanded(
                  child: Container(
                    height: 334, // Approximate to match the left card
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border:
                          Border.all(color: theme.colorScheme.surfaceContainer),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('WEEKLY ACTIVITY',
                                    style: theme.textTheme.labelSmall),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text('4.2',
                                        style: theme.textTheme.displayLarge),
                                    Text('hrs',
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant)),
                                  ],
                                ),
                              ],
                            ),
                            Icon(Icons.show_chart,
                                color: theme.colorScheme.onSurfaceVariant),
                          ],
                        ),
                        const Spacer(),
                        // Minimal Bar Chart
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar(context, 'M', 0.3, false),
                            _buildBar(context, 'T', 0.6, false),
                            _buildBar(context, 'W', 0.45, false),
                            _buildBar(context, 'T', 0.85, true, label: '85m'),
                            _buildBar(context, 'F', 0.2, false),
                            _buildBar(context, 'S', 0.05, false),
                            _buildBar(context, 'S', 0.1, false),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Metrics List
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.surfaceContainer),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildMetricListItem(
                    context,
                    icon: Icons.favorite,
                    title: 'Resting Heart Rate',
                    subtitle: 'BEATS PER MINUTE',
                    value: '52',
                    unit: 'bpm',
                    showBorder: true,
                  ),
                  _buildMetricListItem(
                    context,
                    icon: Icons.local_fire_department,
                    title: 'Active Calories',
                    subtitle: 'DAILY BURN',
                    value: '640',
                    unit: 'kcal',
                    showBorder: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(
      BuildContext context, String day, double heightFraction, bool isActive,
      {String? label}) {
    final theme = Theme.of(context);
    const double maxBarHeight = 120.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 10,
              ),
            ),
          ),
        Container(
          width: 24,
          height: maxBarHeight * heightFraction,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required String unit,
    required bool showBorder,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(color: theme.colorScheme.surfaceContainer))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.labelSmall),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: theme.textTheme.headlineMedium),
              const SizedBox(width: 4),
              Text(unit,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
