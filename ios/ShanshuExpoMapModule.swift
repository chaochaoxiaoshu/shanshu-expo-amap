import AMapFoundationKit
import AMapLocationKit
import AMapSearchKit
import ExpoModulesCore
import MAMapKit

public class ShanshuExpoMapModule: Module {
  private var locationManager: AMapLocationManager?
  private var locationDelegate: LocationManagerDelegate?

  private var search: AMapSearchAPI?
  private var searchDelegate: SearchDelegate?

  public func definition() -> ModuleDefinition {
    Name("ShanshuExpoMap")

    OnCreate {
      let apiKey = Bundle.main.object(forInfoDictionaryKey: "AMAP_API_KEY") as? String
      AMapServices.shared().apiKey = apiKey
      AMapServices.shared().enableHTTPS = true

      MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
      MAMapView.updatePrivacyShow(
        AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)

      locationManager = AMapLocationManager()
      locationDelegate = LocationManagerDelegate()
      locationManager?.delegate = locationDelegate
      locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
      locationManager?.locationTimeout = 2
      locationManager?.reGeocodeTimeout = 2

      search = AMapSearchAPI()
      searchDelegate = SearchDelegate()
      search?.delegate = searchDelegate
    }

    AsyncFunction("requestLocation") { (promise: Promise) -> Void in
      guard let locationManager = locationManager else {
        promise.reject("E_LOCATION_MANAGER_NOT_FOUND", "定位管理器未初始化")
        return
      }
      locationManager.requestLocation(withReGeocode: true) { location, regeocode, error in
        if let error = error {
          let errorMessage = error.localizedDescription
          promise.reject("E_LOCATION_FAILED", "定位失败: \(errorMessage)")
          return
        }
        guard let location = location, let regeocode = regeocode else {
          promise.reject("E_LOCATION_FAILED", "定位失败")
          return
        }

        promise.resolve([
          "latitude": location.coordinate.latitude,
          "longitude": location.coordinate.longitude,
          "regeocode": [
            "formattedAddress": regeocode.formattedAddress,
            "country": regeocode.country,
            "province": regeocode.province,
            "city": regeocode.city,
            "district": regeocode.district,
            "citycode": regeocode.citycode,
            "adcode": regeocode.adcode,
            "street": regeocode.street,
            "number": regeocode.number,
            "poiName": regeocode.poiName,
            "aoiName": regeocode.aoiName,
          ],
        ])
      }
    }

    AsyncFunction("searchDrivingRoute") {
      (options: [String: Any], promise: Promise) -> Void in
      guard let search = search, let searchDelegate = searchDelegate else {
        promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
        return
      }

      searchDelegate.drivingSearchHandler.begin(
        resolve: { value in promise.resolve(value) },
        reject: { code, message, error in
          promise.reject(code, message)
        }
      )

      guard let originDict = options["origin"] as? [String: Double],
        let destinationDict = options["destination"] as? [String: Double],
        let originLat = originDict["latitude"],
        let originLng = originDict["longitude"],
        let destLat = destinationDict["latitude"],
        let destLng = destinationDict["longitude"]
      else {
        searchDelegate.drivingSearchHandler.finishFailure(code: "1", message: "无效的起点或终点坐标")
        return
      }

      var showFieldType: AMapDrivingRouteShowFieldType? = nil
      if let showFieldTypeString = options["showFieldType"] as? String {
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

      search.aMapDrivingV2RouteSearch(request)
    }

    AsyncFunction("searchWalkingRoute") {
      (options: [String: Any], promise: Promise) -> Void in
      guard let search = search, let searchDelegate = searchDelegate else {
        promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
        return
      }

      searchDelegate.walkingSearchHandler.begin(
        resolve: { value in promise.resolve(value) },
        reject: { code, message, error in
          promise.reject(code, message)
        }
      )

      guard let originDict = options["origin"] as? [String: Double],
        let destinationDict = options["destination"] as? [String: Double],
        let originLat = originDict["latitude"],
        let originLng = originDict["longitude"],
        let destLat = destinationDict["latitude"],
        let destLng = destinationDict["longitude"]
      else {
        searchDelegate.walkingSearchHandler.finishFailure(code: "1", message: "无效的起点或终点坐标")
        return
      }

      var showFieldType: AMapWalkingRouteShowFieldType? = nil
      if let showFieldTypeString = options["showFieldType"] as? String {
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

      search.aMapWalkingRouteSearch(request)
    }

    View(ShanshuExpoMapView.self) {
      Events("onLoad", "onZoom")

      Prop("mapType") { (view, mapType: Int) in
        view.setMapType(mapType)
      }

      Prop("showUserLocation") { (view, showUserLocation: Bool) in
        view.setShowUserLocation(showUserLocation)
      }

      Prop("userTrackingMode") { (view, userTrackingMode: Int) in
        view.setUserTrackingMode(userTrackingMode)
      }

      Prop("annotationStyles") { (view, styles: [[String: Any]]) in
        view.setAnnotationStyles(styles)
      }

      Prop("annotations") { (view, annotations: [[String: Any]]) in
        view.setAnnotations(annotations)
      }

      Prop("polylineSegments") { (view, segments: [PolylineSegment]) in
        view.setPolylineSegments(segments)
      }

      AsyncFunction("setCenter") {
        (view: ShanshuExpoMapView, centerCoordinate: [String: Double], promise: Promise) in
        view.setCenter(
          latitude: centerCoordinate["latitude"], longitude: centerCoordinate["longitude"],
          promise: promise)
      }

      AsyncFunction("setZoomLevel") { (view: ShanshuExpoMapView, zoomLevel: Int) in
        view.setZoomLevel(zoomLevel)
      }
    }
  }
}
