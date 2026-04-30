import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/data/models/sticker_pack_model.dart';

class PackInfo extends StatelessWidget {
  final StickerPackModel pack;

  const PackInfo({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(label: 'Nombre del paquete', value: pack.name),
        _InfoRow(label: 'Autor', value: pack.author),
        _InfoRow(
          label: 'Stickers agregados',
          value: '${pack.filledCount} de 30',
        ),
        _InfoRow(
          label: 'Portada',
          value: pack.hasCover ? 'Configurada ✓' : 'Sin portada',
          valueColor: pack.hasCover ? AppColors.accent : Colors.redAccent,
        ),
        _InfoRow(
          label: 'Estado',
          value: pack.isFull ? 'Completo ✓' : 'En progreso',
          valueColor: pack.isFull ? AppColors.accent : AppColors.textSecondary,
        ),
        _InfoRow(label: 'Creado', value: _formatDate(pack.createdAt)),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
