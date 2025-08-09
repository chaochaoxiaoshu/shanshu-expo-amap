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
      self.sendEvent(
        "onChange",
        [
          "value": value
        ])
    }

    View(ShanshuExpoMapView.self) {
      Events("onLoad")

      Prop("apiKey") { (view, apiKey: String) in
        if view.apiKey != apiKey {
          view.apiKey = apiKey
        }
      }

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
          promise.reject("E_INVALID_COORDINATES", "Invalid origin or destination coordinates")
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
          promise.reject("E_INVALID_COORDINATES", "Invalid origin or destination coordinates")
          return
        }

        view.searchWalkingRoute(
          promise: promise, origin: originDict, destination: destinationDict,
          showFieldTypeString: options["showFieldType"] as? String)
      }
    }
  }
}
