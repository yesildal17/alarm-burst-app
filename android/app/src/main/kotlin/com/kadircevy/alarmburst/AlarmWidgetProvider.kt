package com.kadircevy.alarmburst

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Ana ekran widget'ı.
 *
 * Saat ve tarih TextClock ile gösteriliyor; sistem kendisi güncellediği için
 * uygulamanın çalışması gerekmiyor. Yalnızca "sıradaki alarm" satırı
 * uygulamadan besleniyor.
 */
class AlarmWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val nextAlarm = HomeWidgetPlugin.getData(context)
            .getString("next_alarm", null)

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.alarm_widget)

            views.setTextViewText(
                R.id.widget_next_alarm,
                if (nextAlarm.isNullOrBlank()) {
                    context.getString(R.string.widget_no_alarm)
                } else {
                    nextAlarm
                }
            )

            // Widget'a dokununca uygulama açılsın.
            val launch = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
                ?.apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
            if (launch != null) {
                views.setOnClickPendingIntent(
                    R.id.widget_clock,
                    PendingIntent.getActivity(
                        context,
                        0,
                        launch,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                )
            }

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
