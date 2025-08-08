import ExpoModulesCore

public class ShanshuExpoMapModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ShanshuExpoMap")

    Constants([
      "PI": Double.pi
    ])

    Events("onChange")

    Function("hello") {
      return "Hello world! 👋"
    }

    AsyncFunction("setValueAsync") { (value: String) in
      self.sendEvent("onChange", [
        "value": value
      ])
    }

    View(ShanshuExpoMapView.self) {
      Events("onLoad")
      Events("onRouteSearchDone")

      Prop("apiKey") { (view, apiKey: String) in
        if (view.apiKey != apiKey) {
          view.apiKey = apiKey
        }
      }

      Prop("center") { (view, centerCoordinate: [String: Double]) in
        if let latitude = centerCoordinate["latitude"], 
           let longitude = centerCoordinate["longitude"] {
          let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
          if let mapView = view.mapView {
            mapView.setCenter(coordinate, animated: true)
          } else {
            // 如果 mapView 还没初始化，先存储坐标，等初始化后再设置
            view.pendingCenter = coordinate
          }
        }
      }

      Prop("zoomLevel") { (view, zoomLevel: Int) in
        if let mapView = view.mapView {
          mapView.setZoomLevel(CGFloat(zoomLevel), animated: true)
        } else {
          // 如果 mapView 还没初始化，先存储缩放级别，等初始化后再设置
          view.pendingZoomLevel = CGFloat(zoomLevel)
        }
      }

      AsyncFunction("drawPolyline") { (view: ShanshuExpoMapView, coordinates: [[String: Double]]) -> Bool in
        return view.drawPolyline(coordinates)
      }

      AsyncFunction("clearAllOverlays") { (view: ShanshuExpoMapView) -> Bool in
        return view.clearAllOverlays()
      }

      AsyncFunction("searchDrivingRoute") { (view: ShanshuExpoMapView, options: [String: Any]) -> Bool in
        guard let originDict = options["origin"] as? [String: Double],
              let destinationDict = options["destination"] as? [String: Double] else {
          return false
        }
        
        return view.searchDrivingRoute(origin: originDict, destination: destinationDict, showFieldTypeString: options["showFieldType"] as? String)
      }
    }
  }
}
