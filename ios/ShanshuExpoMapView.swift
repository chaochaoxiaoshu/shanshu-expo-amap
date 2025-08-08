import ExpoModulesCore
import AMapFoundationKit
import MAMapKit
import AMapSearchKit
import AMapLocationKit

class ShanshuExpoMapView: ExpoView {

  var mapView: MAMapView?
  var search: AMapSearchAPI?

  let onLoad = EventDispatcher()
  let onRouteSearchDone = EventDispatcher()

  // 存储待设置的属性（当 mapView 还未初始化时）
  var pendingCenter: CLLocationCoordinate2D?
  var pendingZoomLevel: CGFloat?

  var apiKey: String? {
    // apiKey 发生变化时，重新初始化 SDK 并重新创建地图视图（一般不会变）
    didSet {
      if let apiKey = apiKey, apiKey != oldValue {
        initializeSDK(with: apiKey)
        initializeSearch(with: apiKey)
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

  private var sdkInitialized = false
  private var currentApiKey: String?

  // 根据 apiKey 初始化 SDK
  private func initializeSDK(with apiKey: String) {
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

  private func initializeSearch(with apiKey: String) {
    if search != nil {
      return
    }

    search = AMapSearchAPI()
    
    guard let search = search else { return }

    search.delegate = self
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

  func searchDrivingRoute(origin: [String: Double], destination: [String: Double], showFieldTypeString: String?) -> Bool {
    guard let search = search else { return false }
    
    guard let originLat = origin["latitude"],
          let originLng = origin["longitude"],
          let destLat = destination["latitude"],
          let destLng = destination["longitude"] else {
      return false
    }

    var showFieldType: AMapDrivingRouteShowFieldType? = nil
    if let showFieldTypeString = showFieldTypeString {
      switch showFieldTypeString {
      case "none":
        showFieldType = .none
      case "cost":
        showFieldType = .cost
      case "tmcs":
        showFieldType = .tmcs
      case "navi":
        showFieldType = .navi
      case "cities":
        showFieldType = .cities
      case "polyline":
        showFieldType = .polyline
      case "newEnergy":
        showFieldType = .newEnergy
      case "all":
        showFieldType = .all
      default:
        showFieldType = .none
      }
    }
    
    let request = AMapDrivingCalRouteSearchRequest()
    request.origin = AMapGeoPoint.location(withLatitude: CGFloat(originLat), longitude: CGFloat(originLng))
    request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destLat), longitude: CGFloat(destLng))
    request.showFieldType = showFieldType ?? .none
    
    search.aMapDrivingV2RouteSearch(request)
    return true
  }
}

// MARK: - MAMapViewDelegate
extension ShanshuExpoMapView: MAMapViewDelegate {
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

// MARK: - AMapSearchDelegate
extension ShanshuExpoMapView: AMapSearchDelegate {
  private func parsePolyline(_ polyline: String) -> [CLLocationCoordinate2D] {
    var coordinates: [CLLocationCoordinate2D] = []
    let pointStrings = polyline.split(separator: ";")
    
    for pointStr in pointStrings {
        let coord = pointStr.split(separator: ",")
        if coord.count == 2,
           let lon = Double(coord[0]),
           let lat = Double(coord[1]) {
            coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
    }
    return coordinates
  }

  func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
    guard let response = response,
          let route = response.route,
          let paths = route.paths,
          let path = paths.first,
          let polyline = path.polyline else {
      onRouteSearchDone([
        "success": false,
        "count": 0,
        "route": [:]
      ])
      return
    }
    guard let mapView = mapView else { return }

    onRouteSearchDone([
      "success": true,
      "count": response.count,
      "route": serializeRouteResponse(route)
    ])
    
    _ = clearAllOverlays()

    var coordinates = [CLLocationCoordinate2D]()
    if let polyline = path.polyline, !polyline.isEmpty {
      let coords = parsePolyline(polyline)
      coordinates.append(contentsOf: coords)
    }
    
    if !coordinates.isEmpty {
        var coordsArray = coordinates
        let polyline = MAPolyline(coordinates: &coordsArray, count: UInt(coordsArray.count))
        mapView.add(polyline)
    }
    print("Route planning completed successfully")
  }

  func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
    print("Route search failed with error: \(error?.localizedDescription ?? "Unknown error")")
  }
}

// MARK: - Utils
extension ShanshuExpoMapView {

  private func serializeRouteResponse(_ route: AMapRoute) -> [String: Any] {
    var routeData: [String: Any] = [:]
    
    // 序列化起点
    if let origin = route.origin {
      routeData["origin"] = [
        "latitude": Double(origin.latitude),
        "longitude": Double(origin.longitude)
      ]
    }
    
    // 序列化终点
    if let destination = route.destination {
      routeData["destination"] = [
        "latitude": Double(destination.latitude),
        "longitude": Double(destination.longitude)
      ]
    }
    
    // 出租车费用
    routeData["taxiCost"] = Double(route.taxiCost)
    
    // 分路段坐标点串
    routeData["polyline"] = route.polyline ?? ""
    
    // 序列化路径列表 (AMapPath 数组)
    if let paths = route.paths {
      var pathsArray: [[String: Any]] = []
      for path in paths {
        let pathData: [String: Any] = [
          "distance": Double(path.distance),
          "duration": Double(path.duration),
          "stepCount": path.steps.count,
          "polyline": path.polyline ?? ""
        ]
        pathsArray.append(pathData)
      }
      routeData["paths"] = pathsArray
    }
    
    // 序列化公交换乘方案列表 (AMapTransit 数组)
    if let transits = route.transits {
      var transitsArray: [[String: Any]] = []
      for transit in transits {
        var transitData: [String: Any] = [
          "cost": Double(transit.cost),
          "duration": Double(transit.duration),
          "nightflag": transit.nightflag,
          "walkingDistance": Double(transit.walkingDistance),
          "distance": Double(transit.distance)
        ]
        transitsArray.append(transitData)
      }
      routeData["transits"] = transitsArray
    }
    
    // 序列化详细导航动作指令
    if let transitNavi = route.transitNavi {
      routeData["transitNavi"] = [
        "action": transitNavi.action ?? "",
        "assistantAction": transitNavi.assistantAction ?? ""
      ]
    }
    
    return routeData
  }
}