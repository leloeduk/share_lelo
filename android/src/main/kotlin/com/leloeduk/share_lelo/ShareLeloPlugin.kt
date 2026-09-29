package com.leloeduk.share_lelo

import android.app.Activity
import android.content.ClipData
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.util.concurrent.Executors

/** ShareLeloPlugin: shares the full APK file of the installed app. */
class ShareLeloPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "share_lelo")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getApkInfo" -> inBackground(result) { apkInfo() }
            "prepareApk" -> inBackground(result) {
                prepareApk(call.argument("fileName")).map { it.absolutePath }
            }
            "shareApk" -> {
                // Copy in the background, open the share sheet on the UI thread.
                executor.execute {
                    val files = try {
                        prepareApk(call.argument("fileName"))
                    } catch (e: Exception) {
                        mainHandler.post { result.error("COPY_FAILED", e.message, e.toString()) }
                        return@execute
                    }
                    mainHandler.post {
                        try {
                            shareFiles(
                                files,
                                call.argument("chooserTitle"),
                                call.argument("text"),
                                call.argument("subject"),
                                call.argument("packageName"),
                            )
                            result.success(files.map { it.absolutePath })
                        } catch (e: Exception) {
                            result.error("SHARE_FAILED", e.message, e.toString())
                        }
                    }
                }
            }
            "clearCache" -> inBackground(result) {
                cacheDir().deleteRecursively()
                null
            }
            else -> result.notImplemented()
        }
    }

    /** An APK can weigh tens of MB: never copy it on the UI thread. */
    private fun inBackground(result: Result, block: () -> Any?) {
        executor.execute {
            try {
                val value = block()
                mainHandler.post { result.success(value) }
            } catch (e: Exception) {
                mainHandler.post { result.error("SHARE_LELO_ERROR", e.message, e.toString()) }
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun packageInfo(): PackageInfo =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.packageManager.getPackageInfo(context.packageName, PackageManager.PackageInfoFlags.of(0))
        } else {
            context.packageManager.getPackageInfo(context.packageName, 0)
        }

    private fun splitPaths(): List<String> = context.applicationInfo.splitSourceDirs?.toList() ?: emptyList()

    private fun apkInfo(): Map<String, Any?> {
        val info = context.applicationInfo
        val pkg = packageInfo()
        val base = File(info.sourceDir)
        val splits = splitPaths()
        @Suppress("DEPRECATION")
        val versionCode =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) pkg.longVersionCode else pkg.versionCode.toLong()
        return mapOf(
            "appName" to context.packageManager.getApplicationLabel(info).toString(),
            "packageName" to context.packageName,
            "versionName" to (pkg.versionName ?: ""),
            "versionCode" to versionCode,
            "apkPath" to base.absolutePath,
            "apkSize" to base.length(),
            "splitApkPaths" to splits,
            "totalSize" to base.length() + splits.sumOf { File(it).length() },
        )
    }

    private fun cacheDir(): File = File(context.cacheDir, "share_lelo")

    /**
     * Copies the installed APK into the cache (the system folder cannot be shared
     * directly). If the app was installed from an App Bundle (splits), every APK
     * is copied: they must be installed together.
     */
    private fun prepareApk(requestedName: String?): List<File> {
        val info = apkInfo()
        val dir = cacheDir()
        dir.deleteRecursively()
        dir.mkdirs()

        val baseName = sanitize(
            requestedName?.removeSuffix(".apk")?.takeIf { it.isNotBlank() }
                ?: "${info["appName"]}_v${info["versionName"]}"
        )

        val files = mutableListOf<File>()
        val base = File(dir, "$baseName.apk")
        File(info["apkPath"] as String).copyTo(base, overwrite = true)
        files.add(base)

        for (splitPath in splitPaths()) {
            val src = File(splitPath)
            val dest = File(dir, "${baseName}_${src.name}")
            src.copyTo(dest, overwrite = true)
            files.add(dest)
        }
        return files
    }

    private fun sanitize(name: String): String =
        name.replace(Regex("[^A-Za-z0-9._-]+"), "_").trim('_').ifBlank { "app" }

    private fun shareFiles(
        files: List<File>,
        chooserTitle: String?,
        text: String?,
        subject: String?,
        targetPackage: String?,
    ) {
        val authority = "${context.packageName}.share_lelo.fileprovider"
        val uris = ArrayList<Uri>(files.map { FileProvider.getUriForFile(context, authority, it) })

        val intent = if (uris.size == 1) {
            Intent(Intent.ACTION_SEND).putExtra(Intent.EXTRA_STREAM, uris[0])
        } else {
            Intent(Intent.ACTION_SEND_MULTIPLE).putParcelableArrayListExtra(Intent.EXTRA_STREAM, uris)
        }
        intent.type = APK_MIME
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        text?.let { intent.putExtra(Intent.EXTRA_TEXT, it) }
        subject?.let { intent.putExtra(Intent.EXTRA_SUBJECT, it) }

        // ClipData is required for the read permission to follow the intent (Android 10+).
        val clip = ClipData.newRawUri(null, uris[0])
        uris.drop(1).forEach { clip.addItem(ClipData.Item(it)) }
        intent.clipData = clip

        val target = if (!targetPackage.isNullOrBlank()) {
            intent.setPackage(targetPackage)
        } else {
            Intent.createChooser(intent, chooserTitle ?: "Share app")
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        val launcher = activity
        if (launcher != null) {
            launcher.startActivity(target)
        } else {
            context.startActivity(target.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        }
    }

    companion object {
        private const val APK_MIME = "application/vnd.android.package-archive"
    }
}
