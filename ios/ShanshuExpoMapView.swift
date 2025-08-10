import AMapFoundationKit
import AMapLocationKit
import AMapSearchKit
import ExpoModulesCore
import MAMapKit

class ShanshuExpoMapView: ExpoView {
  let mapView = MAMapView()
  let searchAPI: AMapSearchAPI = AMapSearchAPI()

  let onLoad = EventDispatcher()

  let drivingSearchHandler = PromiseDelegateHandler<[String: Any]>()
  let walkingSearchHandler = PromiseDelegateHandler<[String: Any]>()

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    clipsToBounds = true
    setupMapView()
    setupSearchAPI()
    onLoad([
      "message": "Map loaded successfully",
      "timestamp": Date().timeIntervalSince1970,
    ])
  }

  private func setupMapView() {
    mapView.delegate = self
    mapView.showsUserLocation = true
    mapView.userTrackingMode = MAUserTrackingMode.none
    mapView.showsCompass = true
    mapView.showsScale = true

    let coordinate = CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074)
    let region = MACoordinateRegion(
      center: coordinate, span: MACoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    mapView.setRegion(region, animated: false)

    addSubview(mapView)
  }

  private func setupSearchAPI() {
    searchAPI.delegate = self
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    mapView.frame = bounds
  }

  // MARK: - 地图命令式方法

  func setCenter(latitude: Double, longitude: Double) {
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    mapView.setCenter(coordinate, animated: false)
  }

  func setZoomLevel(_ zoomLevel: Int) {
    mapView.setZoomLevel(CGFloat(zoomLevel), animated: false)
  }

  func setMapType(_ mapType: Int) {
    mapView.mapType = MAMapType(rawValue: mapType) ?? .standard
  }

  func drawPolyline(_ coordinates: [[String: Double]]) {
    var polylineCoords = [CLLocationCoordinate2D]()

    for coord in coordinates {
      if let latitude = coord["latitude"], let longitude = coord["longitude"] {
        polylineCoords.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
      }
    }

    let polyline = MAPolyline(coordinates: &polylineCoords, count: UInt(polylineCoords.count))
    mapView.add(polyline)
  }

  func clearAllOverlays() {
    mapView.removeOverlays(mapView.overlays)
  }

  func searchDrivingRoute(
    promise: Promise, origin: [String: Double], destination: [String: Double],
    showFieldTypeString: String?
  ) {
    drivingSearchHandler.begin(
      resolve: { value in promise.resolve(value) },
      reject: { code, message, error in
        promise.reject(code, message)
      }
    )

    guard let originLat = origin["latitude"],
      let originLng = origin["longitude"],
      let destLat = destination["latitude"],
      let destLng = destination["longitude"]
    else {
      drivingSearchHandler.finishFailure(code: "1", message: "无效的起点或终点坐标")
      return
    }

    var showFieldType: AMapDrivingRouteShowFieldType? = nil
    if let showFieldTypeString = showFieldTypeString {
      switch showFieldTypeString {
      case "none":
        showFieldType = AMapDrivingRouteShowFieldType.none
      case "cost":
        showFieldType = AMapDrivingRouteShowFieldType.cost
      case "tmcs":
        showFieldType = AMapDrivingRouteShowFieldType.tmcs
      case "navi":
        showFieldType = AMapDrivingRouteShowFieldType.navi
      case "cities":
        showFieldType = AMapDrivingRouteShowFieldType.cities
      case "polyline":
        showFieldType = AMapDrivingRouteShowFieldType.polyline
      case "newEnergy":
        showFieldType = AMapDrivingRouteShowFieldType.newEnergy
      case "all":
        showFieldType = AMapDrivingRouteShowFieldType.all
      default:
        showFieldType = AMapDrivingRouteShowFieldType.none
      }
    }

    let request = AMapDrivingCalRouteSearchRequest()
    request.origin = AMapGeoPoint.location(
      withLatitude: CGFloat(originLat), longitude: CGFloat(originLng))
    request.destination = AMapGeoPoint.location(
      withLatitude: CGFloat(destLat), longitude: CGFloat(destLng))
    request.showFieldType = showFieldType ?? .none

    searchAPI.aMapDrivingV2RouteSearch(request)
  }

  func searchWalkingRoute(
    promise: Promise, origin: [String: Double], destination: [String: Double],
    showFieldTypeString: String?
  ) {
    walkingSearchHandler.begin(
      resolve: { value in promise.resolve(value) },
      reject: { code, message, error in
        promise.reject(code, message)
      }
    )

    guard let originLat = origin["latitude"],
      let originLng = origin["longitude"],
      let destLat = destination["latitude"],
      let destLng = destination["longitude"]
    else {
      walkingSearchHandler.finishFailure(code: "1", message: "无效的起点或终点坐标")
      return
    }

    var showFieldType: AMapWalkingRouteShowFieldType? = nil
    if let showFieldTypeString = showFieldTypeString {
      switch showFieldTypeString {
      case "none":
        showFieldType = AMapWalkingRouteShowFieldType.none
      case "cost":
        showFieldType = AMapWalkingRouteShowFieldType.cost
      case "navi":
        showFieldType = AMapWalkingRouteShowFieldType.navi
      case "polyline":
        showFieldType = AMapWalkingRouteShowFieldType.polyline
      case "all":
        showFieldType = AMapWalkingRouteShowFieldType.all
      default:
        showFieldType = AMapWalkingRouteShowFieldType.none
      }
    }

    let request = AMapWalkingRouteSearchRequest()
    request.origin = AMapGeoPoint.location(
      withLatitude: CGFloat(originLat), longitude: CGFloat(originLng))
    request.destination = AMapGeoPoint.location(
      withLatitude: CGFloat(destLat), longitude: CGFloat(destLng))
    request.showFieldsType = showFieldType ?? .none

    searchAPI.aMapWalkingRouteSearch(request)
  }
}

// MARK: - MAMapViewDelegate
extension ShanshuExpoMapView: MAMapViewDelegate {
  public func mapViewRequireLocationAuth(_ mapView: MAMapView!) {
    if CLLocationManager.authorizationStatus() == .notDetermined {
      let locationManager = CLLocationManager()
      locationManager.requestAlwaysAuthorization()
    }
  }

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
        let lat = Double(coord[1])
      {
        coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
      }
    }
    return coordinates
  }

  func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!)
  {
    guard let response = response,
      let route = response.route,
      let paths = route.paths,
      let path = paths.first
    else {
      if request is AMapDrivingCalRouteSearchRequest {
        drivingSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
      } else if request is AMapWalkingRouteSearchRequest {
        walkingSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
      }
      return
    }

    if request is AMapDrivingCalRouteSearchRequest {
      drivingSearchHandler.finishSuccess([
        "success": true,
        "count": response.count,
        "route": serializeRouteResponse(route),
      ])
    } else if request is AMapWalkingRouteSearchRequest {
      walkingSearchHandler.finishSuccess([
        "success": true,
        "count": response.count,
        "route": serializeRouteResponse(route),
      ])
    }

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
  }

  func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
    if request is AMapDrivingCalRouteSearchRequest {
      drivingSearchHandler.finishFailure(
        code: "1", message: "路线规划失败: \(error?.localizedDescription ?? "Unknown error")")
    } else if request is AMapWalkingRouteSearchRequest {
      walkingSearchHandler.finishFailure(
        code: "1", message: "路线规划失败: \(error?.localizedDescription ?? "Unknown error")")
    }
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
        "longitude": Double(origin.longitude),
      ]
    }

    // 序列化终点
    if let destination = route.destination {
      routeData["destination"] = [
        "latitude": Double(destination.latitude),
        "longitude": Double(destination.longitude),
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
          "polyline": path.polyline ?? "",
        ]
        pathsArray.append(pathData)
      }
      routeData["paths"] = pathsArray
    }

    // 序列化公交换乘方案列表 (AMapTransit 数组)
    if let transits = route.transits {
      var transitsArray: [[String: Any]] = []
      for transit in transits {
        let transitData: [String: Any] = [
          "cost": Double(transit.cost),
          "duration": Double(transit.duration),
          "nightflag": transit.nightflag,
          "walkingDistance": Double(transit.walkingDistance),
          "distance": Double(transit.distance),
        ]
        transitsArray.append(transitData)
      }
      routeData["transits"] = transitsArray
    }

    // 序列化详细导航动作指令
    if let transitNavi = route.transitNavi {
      routeData["transitNavi"] = [
        "action": transitNavi.action ?? "",
        "assistantAction": transitNavi.assistantAction ?? "",
      ]
    }

    return routeData
  }
}
