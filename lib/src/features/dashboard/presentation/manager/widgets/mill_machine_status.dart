import 'package:flutter/material.dart';

class MillMachineStatus extends StatelessWidget {
  const MillMachineStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Machine Status Monitor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50]!,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'All Systems Operational',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMachineCard(
            name: 'Sterilizer',
            status: 'Waiting Sensor',
            statusColor: Colors.orange,
            temperature: '0°C',
            pressure: '0 Bar',
            efficiency: 0,
            icon: Icons.local_fire_department,
          ),
          const SizedBox(height: 12),
          _buildMachineCard(
            name: 'Digester',
            status: 'Waiting Sensor',
            statusColor: Colors.orange,
            temperature: '0°C',
            pressure: '0 Bar',
            efficiency: 0,
            icon: Icons.blender,
          ),
          const SizedBox(height: 12),
          _buildMachineCard(
            name: 'Screw Press',
            status: 'Waiting Sensor',
            statusColor: Colors.orange,
            temperature: '0°C',
            pressure: '0 Bar',
            efficiency: 0,
            icon: Icons.compress,
          ),
          const SizedBox(height: 12),
          _buildMachineCard(
            name: 'Clarifier Tank',
            status: 'Waiting Sensor',
            statusColor: Colors.orange,
            temperature: '0°C',
            pressure: '0 Bar',
            efficiency: 0,
            icon: Icons.water,
          ),
        ],
      ),
    );
  }

  Widget _buildMachineCard({
    required String name,
    required String status,
    required Color statusColor,
    required String temperature,
    required String pressure,
    required int efficiency,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50]!,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMetricBadge(
                        Icons.thermostat, temperature, Colors.red),
                    const SizedBox(width: 12),
                    _buildMetricBadge(Icons.speed, pressure, Colors.blue),
                    const Spacer(),
                    if (efficiency > 0)
                      Row(
                        children: [
                          Text(
                            'Efficiency: ',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 11),
                          ),
                          Text(
                            '$efficiency%',
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
              color: Colors.grey[700],
              fontSize: 11,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
