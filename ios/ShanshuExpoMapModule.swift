import AMapFoundationKit
import AMapLocationKit
import ExpoModulesCore
import MAMapKit

public class ShanshuExpoMapModule: Module {
  var locationManager: AMapLocationManager?
  private var locationDelegate: LocationManagerDelegate?

  public func definition() -> ModuleDefinition {
    Name("ShanshuExpoMap")

    OnCreate {
      let apiKey = Bundle.main.object(forInfoDictionaryKey: "AMAP_API_KEY") as? String
      print("apiKey: \(apiKey ?? "")")
      AMapServices.shared().apiKey = apiKey
      MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
      MAMapView.updatePrivacyShow(
        AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
      AMapServices.shared().enableHTTPS = true

      locationManager = AMapLocationManager()
      locationDelegate = LocationManagerDelegate()
      locationManager?.delegate = locationDelegate
      locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
      locationManager?.locationTimeout = 2
      locationManager?.reGeocodeTimeout = 2
    }

    AsyncFunction("requestLocation") { (promise: Promise) -> Void in
      guard let locationManager = locationManager else {
        promise.reject("E_LOCATION_MANAGER_NOT_FOUND", "定位管理器未初始化")
        return
      }
      locationManager.requestLocation(withReGeocode: true) { location, regeocode, error in
        if error != nil {
          promise.reject("E_LOCATION_FAILED", "定位失败")
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

    View(ShanshuExpoMapView.self) {
      Events("onLoad")

      Prop("center") { (view, centerCoordinate: [String: Double]) in
        if let latitude = centerCoordinate["latitude"],
          let longitude = centerCoordinate["longitude"]
        {
          view.setCenter(latitude: latitude, longitude: longitude)
        }
      }

      Prop("zoomLevel") { (view, zoomLevel: Int) in
        view.setZoomLevel(zoomLevel)
      }

      Prop("mapType") { (view, mapType: Int) in
        view.setMapType(mapType)
      }

      AsyncFunction("drawPolyline") { (view: ShanshuExpoMapView, coordinates: [[String: Double]]) in
        view.drawPolyline(coordinates)
      }

      AsyncFunction("clearAllOverlays") { (view: ShanshuExpoMapView) in
        view.clearAllOverlays()
      }

      AsyncFunction("searchDrivingRoute") {
        (view: ShanshuExpoMapView, options: [String: Any], promise: Promise) -> Void in
        guard let originDict = options["origin"] as? [String: Double],
          let destinationDict = options["destination"] as? [String: Double]
        else {
          promise.reject("E_INVALID_COORDINATES", "无效的起点和终点坐标")
          return
        }

        view.searchDrivingRoute(
          promise: promise, origin: originDict, destination: destinationDict,
          showFieldTypeString: options["showFieldType"] as? String)
      }

      AsyncFunction("searchWalkingRoute") {
        (view: ShanshuExpoMapView, options: [String: Any], promise: Promise) -> Void in
        guard let originDict = options["origin"] as? [String: Double],
          let destinationDict = options["destination"] as? [String: Double]
        else {
          promise.reject("E_INVALID_COORDINATES", "无效的起点和终点坐标")
          return
        }

        view.searchWalkingRoute(
          promise: promise, origin: originDict, destination: destinationDict,
          showFieldTypeString: options["showFieldType"] as? String)
      }
    }
  }
}
