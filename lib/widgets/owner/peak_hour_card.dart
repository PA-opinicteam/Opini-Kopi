import 'package:flutter/material.dart';

class PeakHourCard extends StatelessWidget {
  final String peakHour;
  final List<int> data;

  const PeakHourCard({super.key, required this.peakHour, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<String> hourLabels = ['06', '09', '12', '15', '18', '21', '00'];
    final maxVal = data.isEmpty ? 0 : data.reduce((a, b) => a > b ? a : b);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 700;
    final cardPadding = isCompact ? 20.0 : 24.0;
    final chartHeight = isCompact ? 72.0 : 90.0;
    final maxBarHeight = isCompact ? 48.0 : 65.0;
    final barWidth = isCompact ? 22.0 : 28.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF4E342E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time_filled,
                  color: Color(0xFF4E342E),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Jam Ramai',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isCompact ? 16 : 18,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 16 : 24),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isCompact ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Puncak Kunjungan (Peak Hour)',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text(
                  peakHour,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 24 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isCompact ? 14 : 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "DISTRIBUSI PENGUNJUNG",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 10 : 16),

          SizedBox(
            height: chartHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                final val = data[i];
                final heightFactor = maxVal == 0 ? 0.1 : (val / maxVal);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: barWidth,
                      height: maxBarHeight * heightFactor.clamp(0.1, 1.0),
                      decoration: BoxDecoration(
                        color: (val == maxVal && val > 0)
                            ? Colors.white
                            : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hourLabels[i],
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
