import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';

class HomeWidgetHelper {
  static const String _androidWidgetName = 'HomeScreenWidgetProvider';
  static const String _iosWidgetName = 'HomeScreenWidget';

  static Future<void> updateWidget({
    required String title,
    required String description,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('title', title);
      await HomeWidget.saveWidgetData<String>('description', description);
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iosWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating home widget: $e');
    }
  }
}
