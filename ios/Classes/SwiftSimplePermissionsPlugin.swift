import Flutter
import UIKit
import Photos

public class SwiftSimplePermissionsPlugin: NSObject, FlutterPlugin {
    var whenInUse = false
    var result: FlutterResult? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "simple_permissions", binaryMessenger: registrar.messenger())
        let instance = SwiftSimplePermissionsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let dic = call.arguments as? [String: Any]
        
        switch(method) {
        case "checkPermission":
            if let permission = dic?["permission"] as? String {
                checkPermission(permission, result: result)
            } else {
                result(FlutterError(code: "permission missing", message: nil, details: nil))
            }
            
        case "getPermissionStatus":
            if let permission = dic?["permission"] as? String {
                getPermissionStatus(permission, result: result)
            } else {
                result(FlutterError(code: "permission missing", message: nil, details: nil))
            }
            
        case "requestPermission":
            if let permission = dic?["permission"] as? String {
                requestPermission(permission, result: result)
            } else {
                result(FlutterError(code: "permission missing", message: nil, details: nil))
            }
            
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            
        case "openSettings":
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        result(true)
                    } else {
                        // Fallback on earlier versions
                        result(FlutterMethodNotImplemented)
                    }
                }
            }
            
        default:
            result(FlutterMethodNotImplemented)
            
        }
        
    }
    
    // Request permission
    private func requestPermission(_ permission: String, result: @escaping FlutterResult) {
        switch(permission) {
        case "CAMERA":
            requestCameraPermission(result: result)
            
        case "PHOTO_LIBRARY":
            requestPhotoLibraryPermission(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Check permissions
    private func checkPermission(_ permission: String, result: @escaping FlutterResult) {
        switch(permission) {
        case "CAMERA":
            result(checkCameraPermission())
            
        case "PHOTO_LIBRARY":
            result(checkPhotoLibraryPermission())
            
        default:
            result(FlutterMethodNotImplemented)
            
        }
    }
    
    // Get permissions status
    private func getPermissionStatus (_ permission: String, result: @escaping FlutterResult) {
        switch(permission) {
        case "CAMERA":
            result(getCameraPermissionStatus().rawValue)
            
        case "PHOTO_LIBRARY":
            result(getPhotoLibraryPermissionStatus().rawValue)
            
        default:
            result(FlutterMethodNotImplemented)
            
        }
    }
    
    //-----------------------------------
    // Camera
    private func checkCameraPermission()-> Bool {
        return getCameraPermissionStatus() == .authorized
    }
    
    private func getCameraPermissionStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }
    
    
    private func requestCameraPermission(result: @escaping FlutterResult) -> Void {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            result(response)
        }
    }
    
    //-----------------------------------
    // Photo Library
    private func checkPhotoLibraryPermission()-> Bool {
        return getPhotoLibraryPermissionStatus() == .authorized
    }
    
    private func getPhotoLibraryPermissionStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    private func requestPhotoLibraryPermission(result: @escaping FlutterResult) {
        PHPhotoLibrary.requestAuthorization { (status) in
            result(status == PHAuthorizationStatus.authorized)
        }
    }
}
