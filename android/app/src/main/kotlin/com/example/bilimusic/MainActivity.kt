package com.example.bilimusic

import android.content.Context
import android.os.PowerManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * 播放期间持有 PARTIAL_WAKE_LOCK。
 *
 * media_kit / libmpv 自己不管 Android 的休眠，息屏后 CPU 一旦进入 suspend，
 * 音频就会卡住、通知也跟着消失。播放时由 Flutter 侧打开这把锁，暂停或退出时释放。
 */
class MainActivity : AudioServiceActivity() {
    private var playbackWakeLock: PowerManager.WakeLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "acquire" -> {
                        acquirePlaybackWakeLock()
                        result.success(null)
                    }

                    "release" -> {
                        releasePlaybackWakeLock()
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun acquirePlaybackWakeLock() {
        if (playbackWakeLock?.isHeld == true) {
            return
        }
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        val lock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "$packageName:playback",
        )
        lock.setReferenceCounted(false)
        lock.acquire()
        playbackWakeLock = lock
    }

    private fun releasePlaybackWakeLock() {
        val lock = playbackWakeLock ?: return
        if (lock.isHeld) {
            lock.release()
        }
        playbackWakeLock = null
    }

    override fun onDestroy() {
        releasePlaybackWakeLock()
        super.onDestroy()
    }

    private companion object {
        const val CHANNEL = "bilimusic/keep_awake"
    }
}
