package com.kadircevy.alarmburst

import android.app.Activity
import android.app.ActivityManager
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val CHANNEL = "alarmburst/native"
private const val REQUEST_PICK_RINGTONE = 7301

class MainActivity : FlutterActivity() {

    private var pendingResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Alarm çaldığında telefon kilitliyse: ekranı aç ve kilit ekranının
        // üstünde görün. Bunlar olmadan alarm bildirimi gelir ama tam ekran
        // alarm arayüzü kilit ekranının arkasında kalır.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pick" -> openRingtonePicker(call.argument<String>("current"), result)
                    "canPinWidget" -> result.success(canPinWidget())
                    "isWidgetAdded" -> result.success(isWidgetAdded())
                    "requestPinWidget" -> result.success(requestPinWidget())
                    "isAlarmRinging" -> result.success(isAlarmRinging())
                    else -> result.notImplemented()
                }
            }
    }

    /// Sistemin zil sesi seçicisini açar; kendi ses listemizi paketlemek
    /// yerine kullanıcının telefonundaki sesleri gösteriyoruz.
    private fun openRingtonePicker(current: String?, result: MethodChannel.Result) {
        pendingResult?.success(null)
        pendingResult = result

        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
            putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Alarm sesi")
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
            putExtra(
                RingtoneManager.EXTRA_RINGTONE_DEFAULT_URI,
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            )
            putExtra(
                RingtoneManager.EXTRA_RINGTONE_EXISTING_URI,
                if (current.isNullOrEmpty()) null else Uri.parse(current)
            )
        }

        try {
            startActivityForResult(intent, REQUEST_PICK_RINGTONE)
        } catch (error: Throwable) {
            pendingResult = null
            result.error("NO_PICKER", "Zil sesi seçici açılamadı", null)
        }
    }

    /**
     * Alarm su anda gercekten caliyor mu?
     *
     * Eklentinin alarm kaydi susturulana kadar "triggered" kaliyor; bu kayda
     * bakmak, sesi coktan susmus bir alarm icin de ekran acilmasina yol
     * aciyordu. Calma servisinin ayakta olup olmadigi kesin olcut.
     *
     * Android 8+'da getRunningServices yalnizca uygulamanin kendi
     * servislerini donduruyor, ki burada istenen tam olarak bu.
     */
    private fun isAlarmRinging(): Boolean {
        return try {
            val am = getSystemService(ACTIVITY_SERVICE) as ActivityManager
            @Suppress("DEPRECATION")
            am.getRunningServices(Int.MAX_VALUE).any {
                it.service.className.contains("AlarmRingingService")
            }
        } catch (error: Throwable) {
            // Okuyamiyorsak alarm ekranini engellememek icin caliyor sayiyoruz.
            true
        }
    }

    private fun widgetManager() = AppWidgetManager.getInstance(this)

    private fun widgetComponent() =
        ComponentName(this, AlarmWidgetProvider::class.java)

    /** Baslatici widget sabitleme diyalogunu destekliyor mu? */
    private fun canPinWidget(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            widgetManager().isRequestPinAppWidgetSupported
    }

    private fun isWidgetAdded(): Boolean =
        widgetManager().getAppWidgetIds(widgetComponent()).isNotEmpty()

    /**
     * Ana ekrana widget eklenmesini ister.
     *
     * Android uygulamalarin ana ekrana kendiliginden widget koymasina izin
     * vermiyor; yapilabilecek tek sey bu sistem diyalogunu acmak ve
     * kullanicinin onaylamasini beklemek.
     */
    private fun requestPinWidget(): Boolean {
        if (!canPinWidget()) return false
        return try {
            widgetManager().requestPinAppWidget(widgetComponent(), null, null)
        } catch (error: Throwable) {
            false
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQUEST_PICK_RINGTONE) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }

        val result = pendingResult
        pendingResult = null

        if (resultCode != Activity.RESULT_OK || result == null) {
            result?.success(null)
            return
        }

        val uri: Uri? = data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
        val title = if (uri == null) {
            "Telefonun alarm sesi"
        } else {
            RingtoneManager.getRingtone(this, uri)?.getTitle(this)
                ?: "Seçilen ses"
        }

        result.success(mapOf("uri" to (uri?.toString() ?: ""), "title" to title))
    }
}
