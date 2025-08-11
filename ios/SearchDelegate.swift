import AMapSearchKit
import Foundation

class SearchDelegate: NSObject, AMapSearchDelegate {
  let drivingSearchHandler = PromiseDelegateHandler<[String: Any]>()
  let walkingSearchHandler = PromiseDelegateHandler<[String: Any]>()

  // private func parsePolyline(_ polyline: String) -> [CLLocationCoordinate2D] {
  //   var coordinates: [CLLocationCoordinate2D] = []
  //   let pointStrings = polyline.split(separator: ";")

  //   for pointStr in pointStrings {
  //     let coord = pointStr.split(separator: ",")
  //     if coord.count == 2,
  //       let lon = Double(coord[0]),
  //       let lat = Double(coord[1])
  //     {
  //       coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
  //     }
  //   }
  //   return coordinates
  // }

  // 路线搜索完成的回调
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
        "route": Utils.serializeRouteResponse(route),
      ])
    } else if request is AMapWalkingRouteSearchRequest {
      walkingSearchHandler.finishSuccess([
        "success": true,
        "count": response.count,
        "route": Utils.serializeRouteResponse(route),
      ])
    }

    // var coordinates = [CLLocationCoordinate2D]()
    // if let polyline = path.polyline, !polyline.isEmpty {
    //   let coords = parsePolyline(polyline)
    //   coordinates.append(contentsOf: coords)
    // }

    // if !coordinates.isEmpty {
    //   var coordsArray = coordinates
    //   let polyline = MAPolyline(coordinates: &coordsArray, count: UInt(coordsArray.count))
    //   mapView.add(polyline)
    // }
  }

  // 路线搜索失败的回调
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
