import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../enums/dummy_order_status.dart';
import '../l10n/app_localizations.dart';

class OrderStatusHelper {
  OrderStatusHelper._();

  // ── String-based status helpers (used by OrderPreviewTile) ──

  static String normalizeStatus(String status) => status.toLowerCase().trim();

  static double progressValue(String status) {
    switch (normalizeStatus(status)) {
      case 'pending':
        return 0;
      case 'processing':
        return 1;
      case 'shipped':
        return 2;
      case 'delivery':
      case 'completed':
        return 3;
      case 'cancelled':
        return 3;
      default:
        return 0;
    }
  }

  static Color colorFromStatus(String status) {
    switch (normalizeStatus(status)) {
      case 'pending':
        return const Color(0xFF4044AA);
      case 'processing':
        return const Color(0xFF41A954);
      case 'shipped':
        return const Color(0xFFE19603);
      case 'delivery':
      case 'completed':
        return const Color(0xFF41AA55);
      case 'cancelled':
        return const Color(0xFFFF1F1F);
      default:
        return AppColors.primary;
    }
  }

  static String labelFromStatus(String status, AppLocalizations l10n) {
    switch (normalizeStatus(status)) {
      case 'pending':
        return l10n.orderStatusPending;
      case 'processing':
        return l10n.orderStatusProcessing;
      case 'shipped':
        return l10n.orderStatusShipped;
      case 'delivery':
        return l10n.orderStatusDelivery;
      case 'completed':
        return l10n.orderStatusCompleted;
      case 'cancelled':
        return l10n.orderStatusCancelled;
      default:
        return status;
    }
  }

  // ── Enum-based status helpers (used by OrderStatusRow) ──

  static Color colorFromEnum(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return const Color(0xFF45AF2A);
      case OrderStatus.processing:
        return const Color(0xFFEDC125);
      case OrderStatus.shipped:
        return const Color(0xFF2652ED);
      case OrderStatus.delivery:
        return const Color(0xFF30DFB8);
      case OrderStatus.cancelled:
        return const Color(0xFFFF1F1F);
    }
  }

  static String labelFromEnum(OrderStatus status, AppLocalizations l10n) {
    switch (status) {
      case OrderStatus.confirmed:
        return l10n.orderStatusPending;
      case OrderStatus.processing:
        return l10n.orderStatusProcessing;
      case OrderStatus.shipped:
        return l10n.orderStatusShipped;
      case OrderStatus.delivery:
        return l10n.orderStatusDelivery;
      case OrderStatus.cancelled:
        return l10n.orderStatusCancelled;
    }
  }

  static String iconFromEnum(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return AppIcons.orderConfirmed;
      case OrderStatus.processing:
        return AppIcons.orderProcessing;
      case OrderStatus.shipped:
        return AppIcons.orderShipped;
      case OrderStatus.delivery:
        return AppIcons.orderDelivered;
      case OrderStatus.cancelled:
        return AppIcons.delete;
    }
  }
}
