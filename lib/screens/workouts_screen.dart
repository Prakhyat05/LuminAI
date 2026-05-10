import 'package:flutter/material.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: theme.colorScheme.onSurfaceVariant),
          onPressed: () {},
        ),
        title: Text(
          'LuminAI',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Center(
              child: Text(
                '00:45',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOWER BODY POWER',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Barbell Squats',
                      style: theme.textTheme.headlineLarge,
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3), // surface-container-low
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: theme.colorScheme.surfaceContainerHighest),
                  ),
                  child: Text(
                    'SET 2 OF 4',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.5,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),

            const SizedBox(height: 40),

            // Metric Dashboard
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    context,
                    label: 'Target Reps',
                    value: '10',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricBox(
                    context,
                    label: 'Weight (lbs)',
                    value: '225',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rest Timer Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'REST TIMER',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '00:45',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Main Visual
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: theme.colorScheme.surfaceContainerHighest),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAHP6WN0b8QaFo9OYJXBAhJ_fco1HBHeInljjt0xFNXJJtoexr-fWHqPlod3ZgUaf1vSHSXZp6EVMe08KMsu0hcwozHFUTpS-33lIMJ4i_tkZbXEKK7Krp-HRgyRrb2IKyMNJGDpxQtIcCoLxwS1q-JBCk6nFdknHqrHIWnfA_O0W65qBSYX_791ql0vvyUs70H0nQ2S1XtbFk-LY03mlS6-MGHQwLxY342ZsDOy_QnnDphnmQ005bF5JB1UawAKEcmOq6CLLX8VsA'),
                  fit: BoxFit.cover,
                  colorFilter:
                      ColorFilter.mode(Colors.black38, BlendMode.darken),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_fill, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Watch form tutorial',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // AI Coach Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: theme.colorScheme.surfaceContainerHighest),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('AI Coach Tips',
                          style: theme.textTheme.headlineMedium),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildTipRow(context, Icons.check_circle,
                      'Keep your chest up and core braced.',
                      isPositive: true),
                  const SizedBox(height: 12),
                  _buildTipRow(context, Icons.check_circle,
                      'Drive through your heels on the ascent.',
                      isPositive: true),
                  const SizedBox(height: 12),
                  _buildTipRow(context, Icons.info_outline,
                      'Previous set showed slight forward lean. Focus on vertical bar path.',
                      isPositive: false),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Controls
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause Session'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check),
                    label: const Text('Finish Set'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(BuildContext context,
      {required String label, required String value}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.surfaceContainerHighest),
      ),
      child: Column(
        children: [
          Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.displayLarge),
        ],
      ),
    );
  }

  Widget _buildTipRow(BuildContext context, IconData icon, String text,
      {required bool isPositive}) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 20,
            color: isPositive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isPositive
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
