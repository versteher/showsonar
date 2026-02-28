package com.streamscout.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class HomeScreenWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val title = widgetData.getString("title", "Tonight's Pick")
                val description = widgetData.getString("description", "No recommendations yet.")
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_description, description)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
