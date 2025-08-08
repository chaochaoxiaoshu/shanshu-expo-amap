import ExpoModulesCore
import MAMapKit

class ShanshuExpoMapView: ExpoView, MAMapViewDelegate {

  var mapView: MAMapView?

  let onLoad = EventDispatcher()

  // 存储待设置的属性（当 mapView 还未初始化时）
  var pendingCenter: CLLocationCoordinate2D?
  var pendingZoomLevel: CGFloat?

  var apiKey: String? {
    // apiKey 发生变化时，重新初始化 SDK 并重新创建地图视图（一般不会变）
    didSet {
      if let apiKey = apiKey, apiKey != oldValue {
        Self.initializeSDK(with: apiKey)
        recreateMapView()
      }
    }
  }
  
  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    clipsToBounds = true
  }

  private func recreateMapView() {
    // 如果有地图视图，从父视图中移除
    mapView?.removeFromSuperview()
    
    // 重新创建地图视图
    setupMapView()

    // 应用待设置的属性
    applyPendingProperties()

    // 通知布局需要重新计算
    setNeedsLayout()
    
    // 发送地图加载完成事件
    onLoad([
      "message": "Map loaded successfully",
      "timestamp": Date().timeIntervalSince1970
    ])
  }

  private static var sdkInitialized = false
  private static var currentApiKey: String?

  // 根据 apiKey 初始化 SDK
  private static func initializeSDK(with apiKey: String) {
    if sdkInitialized && currentApiKey == apiKey {
      return
    }

    AMapServices.shared().apiKey = apiKey
    MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
    MAMapView.updatePrivacyShow(AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
    AMapServices.shared().enableHTTPS = true
    
    sdkInitialized = true
    currentApiKey = apiKey
  }

  // 创建并配置地图视图
  private func setupMapView() {
    mapView = MAMapView()

    guard let mapView = mapView else { return }
    
    mapView.delegate = self
    mapView.mapType = MAMapType.standard
    mapView.showsUserLocation = true
    mapView.userTrackingMode = MAUserTrackingMode.none
    mapView.showsCompass = true
    mapView.showsScale = true

    let coordinate = CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074)
    let region = MACoordinateRegion(center: coordinate, span: MACoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    mapView.setRegion(region, animated: false)

    addSubview(mapView)
  }
  
  // 应用待设置的属性
  private func applyPendingProperties() {
    guard let mapView = mapView else { return }
    
    // 设置待设置的中心点
    if let pendingCenter = pendingCenter {
      mapView.setCenter(pendingCenter, animated: false)
      self.pendingCenter = nil
    }
    
    // 设置待设置的缩放级别
    if let pendingZoomLevel = pendingZoomLevel {
      mapView.setZoomLevel(pendingZoomLevel, animated: false)
      self.pendingZoomLevel = nil
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    mapView?.frame = bounds
  }

  // MARK: - 地图命令式方法

  func drawPolyline(_ coordinates: [[String: Double]]) -> Bool {
    guard let mapView = mapView else { return false }
    
    var polylineCoords = [CLLocationCoordinate2D]()
  
    for coord in coordinates {
      if let latitude = coord["latitude"], let longitude = coord["longitude"] {
        polylineCoords.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
      }
    }
    
    let polyline = MAPolyline(coordinates: &polylineCoords, count: UInt(polylineCoords.count))
    mapView.add(polyline)

    return true
  }

  func clearAllOverlays() -> Bool {
    guard let mapView = mapView else { return false }
    
    guard let overlays = mapView.overlays, !overlays.isEmpty else { 
      return true 
    }
    
    mapView.removeOverlays(overlays)
    
    return true
  }

  // MARK: - MAMapViewDelegate

  func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
    if overlay is MAPolyline {
        let renderer = MAPolylineRenderer(overlay: overlay)
        renderer?.strokeColor = UIColor.red
        renderer?.lineWidth = 4
        return renderer
    }
    return nil
  }
}
