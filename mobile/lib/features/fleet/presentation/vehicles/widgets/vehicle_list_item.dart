import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart';
import 'package:mobile/shared/widgets/badge.dart';


class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;

  const VehicleListItem({
    Key? key,
    required this.vehicle,
    this.onTap,
  }) : super(key: key);

  BadgeType _getBadgeType(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.working:
        return BadgeType.working;
      case VehicleStatus.service:
        return BadgeType.service;
      case VehicleStatus.noDriver:
        return BadgeType.noDriver;
      case VehicleStatus.preparation:
        return BadgeType.preparation;
      case VehicleStatus.other:
      case VehicleStatus.notWorking:
      default:
        return BadgeType.preparation;
    }
  }

  String _getStatusText(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.working:
        return 'Работает';
      case VehicleStatus.service:
        return 'Сервис';
      case VehicleStatus.noDriver:
        return 'Нет водителя';
      case VehicleStatus.preparation:
        return 'Подготовка';
      case VehicleStatus.other:
        return 'Другое';
      case VehicleStatus.notWorking:
        return 'Не работает';
      default:
        return 'Неизвестно';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Аватар или иконка
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                image: vehicle.imageUrl != null
                    ? DecorationImage(
                        image: AssetImage(vehicle.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: vehicle.imageUrl == null
                  ? Center(
                      child: Text(
                        vehicle.model.length >= 2
                            ? vehicle.model.substring(0, 2).toUpperCase()
                            : vehicle.model.toUpperCase(),
                        style: AppTheme.avatarText,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12),
            // Информация о машине
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${vehicle.plateNumber} ',
                                style: AppTheme.listTitle,
                              ),
                              TextSpan(
                                text: vehicle.model,
                                style: AppTheme.listSubtitle,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      CustomBadge(
                        type: _getBadgeType(vehicle.status),
                        text: _getStatusText(vehicle.status),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${vehicle.mileage}',
                        style: AppTheme.caption,
                      ),
                      if (vehicle.driverName != null) ...[
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vehicle.driverName!,
                            style: AppTheme.captionSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Стрелка
            Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
