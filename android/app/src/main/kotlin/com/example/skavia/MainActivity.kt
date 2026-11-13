package com.example.skavia

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.security.MessageDigest
import kotlin.math.max

class MainActivity : FlutterActivity() {
    private val mediaChannelName = "skavia/media_picker"
    private val installerChannelName = "skavia/app_installer"
    private val reqGalleryImage = 4101
    private val reqCameraImage = 4102
    private var pendingResult: MethodChannel.Result? = null
    private var pendingCameraFile: File? = null

    private fun getMediaPickerDir(): File {
        val dir = File(cacheDir, "media_picker")
        if (!dir.exists()) {
            dir.mkdirs()
        }
        return dir
    }

    private fun applyExifRotation(bitmap: Bitmap, filePath: String): Bitmap {
        return try {
            val exif = ExifInterface(filePath)
            val orientation = exif.getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_NORMAL
            )
            val degrees = when (orientation) {
                ExifInterface.ORIENTATION_ROTATE_90 -> 90f
                ExifInterface.ORIENTATION_ROTATE_180 -> 180f
                ExifInterface.ORIENTATION_ROTATE_270 -> 270f
                else -> 0f
            }
            if (degrees == 0f) return bitmap
            val matrix = Matrix().apply { postRotate(degrees) }
            val rotated = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
            if (rotated !== bitmap) bitmap.recycle()
            rotated
        } catch (_: Exception) {
            bitmap
        }
    }

    private fun compressBitmapFileToJpeg(sourcePath: String, dest: File, maxDimension: Int, quality: Int): Boolean {
        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(sourcePath, options)
        val origW = options.outWidth
        val origH = options.outHeight
        if (origW <= 0 || origH <= 0) return false
        var sampleSize = 1
        val largest = max(origW, origH)
        while (largest / sampleSize > maxDimension * 2) {
            sampleSize *= 2
        }
        val decodeOpts = BitmapFactory.Options().apply { inSampleSize = sampleSize }
        val decoded = BitmapFactory.decodeFile(sourcePath, decodeOpts) ?: return false
        val oriented = applyExifRotation(decoded, sourcePath)
        val scale = maxDimension.toFloat() / max(oriented.width, oriented.height).toFloat()
        val finalBmp = if (scale < 1f) {
            Bitmap.createScaledBitmap(
                oriented,
                (oriented.width * scale).toInt().coerceAtLeast(1),
                (oriented.height * scale).toInt().coerceAtLeast(1),
                true
            ).also { if (it !== oriented) oriented.recycle() }
        } else {
            oriented
        }
        FileOutputStream(dest).use { out ->
            finalBmp.compress(Bitmap.CompressFormat.JPEG, quality.coerceIn(50, 96), out)
        }
        finalBmp.recycle()
        return dest.exists()
    }

    private fun copyAndCompressUri(uri: Uri, dest: File, maxDimension: Int = 1440): Boolean {
        val rawTemp = File(getMediaPickerDir(), "skavia_raw_${System.currentTimeMillis()}.tmp")
        return try {
            contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(rawTemp).use { output ->
                    input.copyTo(output)
                }
            }
            if (!rawTemp.exists() || rawTemp.length() == 0L) return false
            val compressed = compressBitmapFileToJpeg(rawTemp.absolutePath, dest, maxDimension, 90)
            if (!compressed) {
                rawTemp.copyTo(dest, overwrite = true)
            }
            dest.exists()
        } finally {
            rawTemp.delete()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mediaChannelName)
            .setMethodCallHandler { call, result ->
                if (pendingResult != null) {
                    result.error("ALREADY_ACTIVE", "Another media picker request is active.", null)
                    return@setMethodCallHandler
                }
                when (call.method) {
                    "pickGalleryImage" -> {
                        pendingResult = result
                        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                            type = "image/*"
                            addCategory(Intent.CATEGORY_OPENABLE)
                        }
                        try {
                            @Suppress("DEPRECATION")
                            startActivityForResult(
                                Intent.createChooser(intent, "Select Image"),
                                reqGalleryImage
                            )
                        } catch (e: Exception) {
                            pendingResult = null
                            result.error("UNAVAILABLE", e.message, null)
                        }
                    }
                    "pickCameraImage" -> {
                        pendingResult = result
                        val cameraFile = File(getMediaPickerDir(), "skavia_camera_${System.currentTimeMillis()}.jpg")
                        pendingCameraFile = cameraFile
                        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
                            val photoUri = FileProvider.getUriForFile(
                                this@MainActivity,
                                "$packageName.fileprovider",
                                cameraFile
                            )
                            putExtra(MediaStore.EXTRA_OUTPUT, photoUri)
                            addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        try {
                            @Suppress("DEPRECATION")
                            startActivityForResult(intent, reqCameraImage)
                        } catch (e: Exception) {
                            pendingResult = null
                            pendingCameraFile = null
                            result.error("UNAVAILABLE", e.message, null)
                        }
                    }
                    "compressImageToJpeg" -> {
                        val inputPath = call.argument<String>("inputPath")
                        val maxDimension = call.argument<Int>("maxDimension") ?: 1280
                        val quality = call.argument<Int>("quality") ?: 88
                        if (inputPath.isNullOrBlank()) {
                            result.error("INVALID_ARGS", "Missing inputPath.", null)
                            return@setMethodCallHandler
                        }
                        Thread {
                            try {
                                val dest = File(getMediaPickerDir(), "skavia_cropped_${System.currentTimeMillis()}.jpg")
                                val ok = compressBitmapFileToJpeg(inputPath, dest, maxDimension, quality)
                                runOnUiThread {
                                    result.success(if (ok) dest.absolutePath else null)
                                }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("COMPRESS_FAILED", e.message, null) }
                            }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, installerChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getUpdateDirectories" -> {
                        val updatesDir = File(cacheDir, "apk_updates")
                        if (!updatesDir.exists()) {
                            updatesDir.mkdirs()
                        }
                        result.success(
                            mapOf(
                                "updatesDir" to updatesDir.absolutePath
                            )
                        )
                    }
                    "getAndroidSdkInt" -> {
                        result.success(Build.VERSION.SDK_INT)
                    }
                    "canRequestPackageInstalls" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            result.success(packageManager.canRequestPackageInstalls())
                        } else {
                            result.success(true)
                        }
                    }
                    "openUnknownAppSourcesSettings" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            try {
                                val settingsIntent = Intent(
                                    Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                                    Uri.parse("package:$packageName")
                                ).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(settingsIntent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("SETTINGS_UNAVAILABLE", e.message, null)
                            }
                        } else {
                            result.success(true)
                        }
                    }
                    "computeFileSha256" -> {
                        val filePath = call.argument<String>("filePath")
                        if (filePath.isNullOrBlank()) {
                            result.error("INVALID_ARGS", "Missing filePath.", null)
                            return@setMethodCallHandler
                        }
                        Thread {
                            try {
                                val file = File(filePath)
                                if (!file.exists() || !file.isFile) {
                                    runOnUiThread {
                                        result.error("FILE_NOT_FOUND", "APK file not found.", null)
                                    }
                                    return@Thread
                                }
                                val digest = MessageDigest.getInstance("SHA-256")
                                val buffer = ByteArray(64 * 1024)
                                FileInputStream(file).use { input ->
                                    while (true) {
                                        val read = input.read(buffer)
                                        if (read <= 0) break
                                        digest.update(buffer, 0, read)
                                    }
                                }
                                val hex = digest.digest().joinToString("") { "%02x".format(it) }
                                runOnUiThread { result.success(hex) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("HASH_FAILED", e.message, null) }
                            }
                        }.start()
                    }
                    "installApk" -> {
                        val filePath = call.argument<String>("filePath")
                        if (filePath.isNullOrBlank()) {
                            result.error("INVALID_ARGS", "Missing APK filePath.", null)
                            return@setMethodCallHandler
                        }
                        val updatesDir = File(cacheDir, "apk_updates")
                        val apkFile = File(filePath)
                        if (!apkFile.exists() || !apkFile.isFile) {
                            result.error("FILE_NOT_FOUND", "Downloaded APK file no longer exists.", null)
                            return@setMethodCallHandler
                        }
                        if (!apkFile.canonicalPath.startsWith(updatesDir.canonicalPath)) {
                            result.error("INVALID_PATH", "APK must reside inside internal apk_updates cache.", null)
                            return@setMethodCallHandler
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                            !packageManager.canRequestPackageInstalls()
                        ) {
                            result.error(
                                "INSTALL_PERMISSION_REQUIRED",
                                "Allow installing apps from this source in Android Settings first.",
                                null
                            )
                            return@setMethodCallHandler
                        }
                        try {
                            val contentUri = FileProvider.getUriForFile(
                                this,
                                "$packageName.fileprovider",
                                apkFile
                            )
                            val installIntent = Intent(Intent.ACTION_VIEW).apply {
                                setDataAndType(contentUri, "application/vnd.android.package-archive")
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(installIntent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("INSTALL_LAUNCH_FAILED", e.message, null)
                        }
                    }
                    "compressImageToJpeg" -> {
                        val inputPath = call.argument<String>("inputPath")
                        val maxDimension = call.argument<Int>("maxDimension") ?: 1280
                        val quality = call.argument<Int>("quality") ?: 88
                        if (inputPath.isNullOrBlank()) {
                            result.error("INVALID_ARGS", "Missing inputPath.", null)
                            return@setMethodCallHandler
                        }
                        Thread {
                            try {
                                val dest = File(getMediaPickerDir(), "skavia_cropped_${System.currentTimeMillis()}.jpg")
                                val ok = compressBitmapFileToJpeg(inputPath, dest, maxDimension, quality)
                                runOnUiThread {
                                    result.success(if (ok) dest.absolutePath else null)
                                }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("COMPRESS_FAILED", e.message, null) }
                            }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Handled for backwards-compatible gallery & camera selection")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val callback = pendingResult
        val cameraFile = pendingCameraFile
        if (requestCode != reqGalleryImage && requestCode != reqCameraImage) {
            return
        }
        pendingResult = null
        pendingCameraFile = null
        if (callback == null) return

        if (resultCode != Activity.RESULT_OK) {
            cameraFile?.delete()
            callback.success(null)
            return
        }

        Thread {
            try {
                if (requestCode == reqGalleryImage) {
                    val uri: Uri? = data?.data
                    if (uri == null) {
                        runOnUiThread { callback.success(null) }
                        return@Thread
                    }
                    val dest = File(getMediaPickerDir(), "skavia_gallery_${System.currentTimeMillis()}.jpg")
                    val ok = copyAndCompressUri(uri, dest)
                    runOnUiThread { callback.success(if (ok) dest.absolutePath else null) }
                } else {
                    if (cameraFile != null && cameraFile.exists() && cameraFile.length() > 0L) {
                        val compressed = File(getMediaPickerDir(), "skavia_camera_opt_${System.currentTimeMillis()}.jpg")
                        val uri = Uri.fromFile(cameraFile)
                        val ok = copyAndCompressUri(uri, compressed)
                        if (ok) {
                            cameraFile.delete()
                            runOnUiThread { callback.success(compressed.absolutePath) }
                        } else {
                            runOnUiThread { callback.success(cameraFile.absolutePath) }
                        }
                        return@Thread
                    }
                    @Suppress("DEPRECATION")
                    val bitmap = data?.extras?.get("data") as? Bitmap
                    if (bitmap != null) {
                        val dest = File(getMediaPickerDir(), "skavia_camera_${System.currentTimeMillis()}.jpg")
                        FileOutputStream(dest).use { out ->
                            bitmap.compress(Bitmap.CompressFormat.JPEG, 92, out)
                        }
                        runOnUiThread { callback.success(if (dest.exists()) dest.absolutePath else null) }
                    } else {
                        val uri: Uri? = data?.data
                        if (uri != null) {
                            val dest = File(getMediaPickerDir(), "skavia_camera_${System.currentTimeMillis()}.jpg")
                            val ok = copyAndCompressUri(uri, dest)
                            runOnUiThread { callback.success(if (ok) dest.absolutePath else null) }
                        } else {
                            runOnUiThread { callback.success(null) }
                        }
                    }
                }
            } catch (e: Exception) {
                runOnUiThread { callback.error("PICK_FAILED", e.message, null) }
            }
        }.start()
    }
}
