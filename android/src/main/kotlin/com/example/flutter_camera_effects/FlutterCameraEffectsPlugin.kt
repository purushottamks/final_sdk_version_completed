package com.example.flutter_camera_effects

import android.app.Activity
import android.content.Context
import android.graphics.SurfaceTexture
import android.hardware.camera2.CameraManager
import android.os.Handler
import android.os.Looper
import android.view.Surface
import androidx.annotation.NonNull
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.view.TextureRegistry
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import androidx.core.content.ContextCompat
import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry

/** FlutterCameraEffectsPlugin */
class FlutterCameraEffectsPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will communicate with Flutter
  private lateinit var methodChannel : MethodChannel
  
  /// The EventChannel that will send events to Flutter
  private lateinit var eventChannel: EventChannel
  
  /// The Flutter texture registry
  private lateinit var textureRegistry: TextureRegistry
  
  /// The application context
  private lateinit var context: Context
  
  /// The main activity
  private var activity: Activity? = null
  
  /// The camera controller
  private var cameraController: CameraController? = null
  
  /// The filter manager
  private var filterManager: FilterManager? = null
  
  /// The AR effect manager
  private var arEffectManager: AREffectManager? = null
  
  /// The executor for camera operations
  private val cameraExecutor: Executor = Executors.newSingleThreadExecutor()
  
  /// The main thread handler
  private val mainHandler = Handler(Looper.getMainLooper())

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.flutter_camera_effects/method")
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.example.flutter_camera_effects/event")
    
    textureRegistry = flutterPluginBinding.textureRegistry
    context = flutterPluginBinding.applicationContext
    
    methodChannel.setMethodCallHandler(this)
    eventChannel.setStreamHandler(EventStreamHandler())
    
    filterManager = FilterManager(context)
    arEffectManager = AREffectManager(context)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initialize" -> initialize(call, result)
      "startPreview" -> startPreview(result)
      "stopPreview" -> stopPreview(result)
      "switchCamera" -> switchCamera(call, result)
      "setFilter" -> setFilter(call, result)
      "setAREffect" -> setAREffect(call, result)
      "clearAREffect" -> clearAREffect(result)
      "setZoom" -> setZoom(call, result)
      "setFlashMode" -> setFlashMode(call, result)
      "takePhoto" -> takePhoto(call, result)
      "startRecording" -> startRecording(call, result)
      "stopRecording" -> stopRecording(call, result)
      "setFaceDetectionEnabled" -> setFaceDetectionEnabled(call, result)
      "dispose" -> dispose(result)
      else -> result.notImplemented()
    }
  }

  // Initialize the camera
  private fun initialize(call: MethodCall, result: Result) {
    if (activity == null) {
      result.error("activity_null", "Activity is null", null)
      return
    }
    
    try {
      // Parse options from method call
      val options = parseOptions(call)
      
      // Create camera controller if not already created
      if (cameraController == null) {
        val surfaceTexture = SurfaceTexture(0)
        val flutterTexture = textureRegistry.createSurfaceTexture()
        flutterTexture.surfaceTexture().setDefaultBufferSize(1280, 720)
        
        cameraController = CameraController(
            context = context,
            activity = activity!!,
            flutterTexture = flutterTexture,
            cameraExecutor = cameraExecutor,
            mainHandler = mainHandler,
            filterManager = filterManager!!,
            arEffectManager = arEffectManager!!
        )
      }
      
      // Initialize the camera with the given options
      cameraController!!.initialize(options) { textureId, previewWidth, previewHeight ->
        val resultMap = HashMap<String, Any>()
        resultMap["textureId"] = textureId
        resultMap["previewWidth"] = previewWidth.toDouble()
        resultMap["previewHeight"] = previewHeight.toDouble()
        
        mainHandler.post {
          result.success(resultMap)
        }
      }
    } catch (e: Exception) {
      result.error("initialize_error", "Failed to initialize camera: ${e.message}", null)
    }
  }

  // Start the camera preview
  private fun startPreview(result: Result) {
    if (cameraController == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      cameraController!!.startPreview {
        mainHandler.post {
          result.success(null)
        }
      }
    } catch (e: Exception) {
      result.error("preview_error", "Failed to start preview: ${e.message}", null)
    }
  }

  // Stop the camera preview
  private fun stopPreview(result: Result) {
    if (cameraController == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      cameraController!!.stopPreview {
        mainHandler.post {
          result.success(null)
        }
      }
    } catch (e: Exception) {
      result.error("preview_error", "Failed to stop preview: ${e.message}", null)
    }
  }

  // Switch between front and back cameras
  private fun switchCamera(call: MethodCall, result: Result) {
    if (cameraController == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      val lens = call.argument<Int>("lens") ?: 0
      cameraController!!.switchCamera(lens) {
        mainHandler.post {
          result.success(null)
        }
      }
    } catch (e: Exception) {
      result.error("switch_camera_error", "Failed to switch camera: ${e.message}", null)
    }
  }

  // Set a filter
  private fun setFilter(call: MethodCall, result: Result) {
    if (cameraController == null || filterManager == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      val filterId = call.argument<String>("filterId") ?: ""
      val filterType = call.argument<Int>("filterType") ?: 0
      val intensity = call.argument<Double>("intensity") ?: 1.0
      val params = call.argument<Map<String, Any>>("params")
      val lutPath = call.argument<String>("lutPath")
      val shaderCode = call.argument<String>("shaderCode")
      
      val filter = filterManager!!.createFilter(
          filterId = filterId,
          filterType = filterType,
          intensity = intensity,
          params = params,
          lutPath = lutPath,
          shaderCode = shaderCode
      )
      
      cameraController!!.setFilter(filter) {
        mainHandler.post {
          result.success(null)
        }
      }
    } catch (e: Exception) {
      result.error("filter_error", "Failed to set filter: ${e.message}", null)
    }
  }

  // Set an AR effect
  private fun setAREffect(call: MethodCall, result: Result) {
    if (cameraController == null || arEffectManager == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      val effectId = call.argument<String>("effectId") ?: ""
      val effectType = call.argument<Int>("effectType") ?: 0
      val intensity = call.argument<Double>("intensity") ?: 1.0
      val requiresFaceDetection = call.argument<Boolean>("requiresFaceDetection") ?: false
      val maskPath = call.argument<String>("maskPath")
      val trackFace = call.argument<Boolean>("trackFace")
      val smoothing = call.argument<Double>("smoothing")
      val whitening = call.argument<Double>("whitening")
      val eyeEnlarge = call.argument<Double>("eyeEnlarge")
      val faceSlim = call.argument<Double>("faceSlim")
      
      val effect = arEffectManager!!.createEffect(
          effectId = effectId,
          effectType = effectType,
          intensity = intensity,
          requiresFaceDetection = requiresFaceDetection,
          maskPath = maskPath,
          trackFace = trackFace,
          smoothing = smoothing,
          whitening = whitening,
          eyeEnlarge = eyeEnlarge,
          faceSlim = faceSlim
      )
      
      if (requiresFaceDetection) {
        cameraController!!.setFaceDetectionEnabled(true)
      }
      
      cameraController!!.setAREffect(effect) {
        mainHandler.post {
          result.success(null)
        }
      }
    } catch (e: Exception) {
      result.error("ar_effect_error", "Failed to set AR effect: ${e.message}", null)
    }
  }

  // Clear AR effect
  private fun clearAREffect(result: Result) {
    if (cameraController == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      cameraController!!.clearAREffect {
        mainHandler.post {
          result.success(null)
        }
      }
    } catch (e: Exception) {
      result.error("ar_effect_error", "Failed to clear AR effect: ${e.message}", null)
    }
  }

  // Set zoom level
  private fun setZoom(call: MethodCall, result: Result) {
    if (cameraController == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      val zoom = call.argument<Double>("zoom") ?: 1.0
      cameraController!!.setZoom(zoom) {
        mainHandler.post {
          result.success(null)
        }
      }
    } catch (e: Exception) {
      result.error("zoom_error", "Failed to set zoom: ${e.message}", null)
    }
  }

  // Set flash mode
  private fun setFlashMode(call: MethodCall, result: Result) {
    if (cameraController == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      val mode = call.argument<Int>("mode") ?: 0
      cameraController!!.setFlashMode(mode) {
        mainHandler.post {
          result.success(null)
        }
      }
    } catch (e: Exception) {
      result.error("flash_error", "Failed to set flash mode: ${e.message}", null)
    }
  }

  // Take a photo
  private fun takePhoto(call: MethodCall, result: Result) {
    if (cameraController == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      val applyFilter = call.argument<Boolean>("applyFilter") ?: true
      val applyAREffect = call.argument<Boolean>("applyAREffect") ?: true
      val saveToGallery = call.argument<Boolean>("saveToGallery") ?: false
      val path = call.argument<String>("path")
      
      cameraController!!.takePhoto(
          applyFilter = applyFilter,
          applyAREffect = applyAREffect,
          saveToGallery = saveToGallery,
          path = path
      ) { photoResult ->
        mainHandler.post {
          result.success(photoResult)
        }
      }
    } catch (e: Exception) {
      result.error("photo_error", "Failed to take photo: ${e.message}", null)
    }
  }

  // Start video recording
  private fun startRecording(call: MethodCall, result: Result) {
    if (cameraController == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      val applyFilter = call.argument<Boolean>("applyFilter") ?: true
      val applyAREffect = call.argument<Boolean>("applyAREffect") ?: true
      val maxDuration = call.argument<Int>("maxDuration")
      val path = call.argument<String>("path")
      
      cameraController!!.startRecording(
          applyFilter = applyFilter,
          applyAREffect = applyAREffect,
          maxDuration = maxDuration,
          path = path
      ) {
        mainHandler.post {
          result.success(null)
        }
      }
    } catch (e: Exception) {
      result.error("recording_error", "Failed to start recording: ${e.message}", null)
    }
  }

  // Stop video recording
  private fun stopRecording(call: MethodCall, result: Result) {
    if (cameraController == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      val saveToGallery = call.argument<Boolean>("saveToGallery") ?: false
      
      cameraController!!.stopRecording(saveToGallery) { videoResult ->
        mainHandler.post {
          result.success(videoResult)
        }
      }
    } catch (e: Exception) {
      result.error("recording_error", "Failed to stop recording: ${e.message}", null)
    }
  }

  // Enable or disable face detection
  private fun setFaceDetectionEnabled(call: MethodCall, result: Result) {
    if (cameraController == null) {
      result.error("camera_not_initialized", "Camera controller not initialized", null)
      return
    }
    
    try {
      val enabled = call.argument<Boolean>("enabled") ?: false
      cameraController!!.setFaceDetectionEnabled(enabled) {
        mainHandler.post {
          result.success(null)
        }
      }
    } catch (e: Exception) {
      result.error("face_detection_error", "Failed to set face detection: ${e.message}", null)
    }
  }

  // Dispose the camera
  private fun dispose(result: Result) {
    try {
      cameraController?.dispose()
      cameraController = null
      
      filterManager?.dispose()
      arEffectManager?.dispose()
      
      mainHandler.post {
        result.success(null)
      }
    } catch (e: Exception) {
      result.error("dispose_error", "Failed to dispose camera: ${e.message}", null)
    }
  }

  // Parse camera options from the method call
  private fun parseOptions(call: MethodCall): Map<String, Any> {
    val options = HashMap<String, Any>()
    
    options["resolution"] = call.argument<Int>("resolution") ?: 2 // High by default
    options["lens"] = call.argument<Int>("lens") ?: 1 // Back by default
    options["flashMode"] = call.argument<Int>("flashMode") ?: 0 // Off by default
    options["fps"] = call.argument<Int>("fps") ?: 30
    options["zoom"] = call.argument<Double>("zoom") ?: 1.0
    options["enableFaceDetection"] = call.argument<Boolean>("enableFaceDetection") ?: false
    options["enableAudio"] = call.argument<Boolean>("enableAudio") ?: true
    
    // Custom resolution if provided
    call.argument<Int>("customWidth")?.let { options["customWidth"] = it }
    call.argument<Int>("customHeight")?.let { options["customHeight"] = it }
    
    return options
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    
    cameraController?.dispose()
    //cameraExecutor.shutdown()
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

  // Event channel handler for sending events to Flutter
  inner class EventStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    
    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
      eventSink = sink
      cameraController?.setEventSink(sink)
    }
    
    override fun onCancel(arguments: Any?) {
      eventSink = null
      cameraController?.setEventSink(null)
    }
  }
}

// These classes would be implemented in separate files in a real implementation
// They are included here as stubs for the plugin

// Camera controller class
class CameraController(
    private val context: Context,
    private val activity: Activity,
    private val flutterTexture: TextureRegistry.SurfaceTextureEntry,
    private val cameraExecutor: Executor,
    private val mainHandler: Handler,
    private val filterManager: FilterManager,
    private val arEffectManager: AREffectManager
) {
    // Implementation would go here
    // This is a placeholder for the real implementation
    
    fun initialize(options: Map<String, Any>, callback: (Long, Int, Int) -> Unit) {
        // Placeholder implementation
        callback(flutterTexture.id(), 1280, 720)
    }
    
    fun startPreview(callback: () -> Unit) {
        callback()
    }
    
    fun stopPreview(callback: () -> Unit) {
        callback()
    }
    
    fun switchCamera(lens: Int, callback: () -> Unit) {
        callback()
    }
    
    fun setFilter(filter: Any, callback: () -> Unit) {
        callback()
    }
    
    fun setAREffect(effect: Any, callback: () -> Unit) {
        callback()
    }
    
    fun clearAREffect(callback: () -> Unit) {
        callback()
    }
    
    fun setZoom(zoom: Double, callback: () -> Unit) {
        callback()
    }
    
    fun setFlashMode(mode: Int, callback: () -> Unit) {
        callback()
    }
    
    fun takePhoto(
        applyFilter: Boolean,
        applyAREffect: Boolean,
        saveToGallery: Boolean,
        path: String?,
        callback: (Map<String, Any>) -> Unit
    ) {
        val result = HashMap<String, Any>()
        result["path"] = path ?: ""
        result["width"] = 1280
        result["height"] = 720
        result["bytes"] = ByteArray(0)
        
        callback(result)
    }
    
    fun startRecording(
        applyFilter: Boolean,
        applyAREffect: Boolean,
        maxDuration: Int?,
        path: String?,
        callback: () -> Unit
    ) {
        callback()
    }
    
    fun stopRecording(
        saveToGallery: Boolean,
        callback: (Map<String, Any>) -> Unit
    ) {
        val result = HashMap<String, Any>()
        result["path"] = ""
        result["durationMs"] = 0
        result["width"] = 1280
        result["height"] = 720
        result["fps"] = 30
        result["hasAudio"] = true
        
        callback(result)
    }
    
    fun setFaceDetectionEnabled(enabled: Boolean, callback: () -> Unit) {
        callback()
    }
    
    fun setEventSink(eventSink: EventChannel.EventSink?) {
        // Set event sink for sending events to Flutter
    }
    
    fun dispose() {
        // Release resources
    }
}

// Filter manager class
class FilterManager(private val context: Context) {
    fun createFilter(
        filterId: String,
        filterType: Int,
        intensity: Double,
        params: Map<String, Any>?,
        lutPath: String?,
        shaderCode: String?
    ): Any {
        // Create a filter instance based on the parameters
        return Any()
    }
    
    fun dispose() {
        // Release resources
    }
}

// AR effect manager class
class AREffectManager(private val context: Context) {
    fun createEffect(
        effectId: String,
        effectType: Int,
        intensity: Double,
        requiresFaceDetection: Boolean,
        maskPath: String?,
        trackFace: Boolean?,
        smoothing: Double?,
        whitening: Double?,
        eyeEnlarge: Double?,
        faceSlim: Double?
    ): Any {
        // Create an AR effect instance based on the parameters
        return Any()
    }
    
    fun dispose() {
        // Release resources
    }
} 