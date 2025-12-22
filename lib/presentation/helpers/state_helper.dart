// lib/presentation/helpers/state_helper.dart
import 'package:flutter/material.dart';
import '../../domain/patterns/states/account_state.dart';

class StateHelper {
  static Color getColorForState(AccountState state) {
    return getColorForStateName(state.name);
  }

  static Color getColorForStateName(String stateName) {
    switch (stateName) {
      case 'active':
        return Colors.teal;
      case 'frozen':
        return Colors.teal;
      case 'suspended':
        return Colors.teal;
      case 'closed':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  static IconData getIconForState(AccountState state) {
    return getIconForStateName(state.name);
  }

  static IconData getIconForStateName(String stateName) {
    switch (stateName) {
      case 'active':
        return Icons.check_circle;
      case 'frozen':
        return Icons.ac_unit;
      case 'suspended':
        return Icons.pause_circle;
      case 'closed':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}