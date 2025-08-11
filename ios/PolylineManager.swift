import MAMapKit

class PolylineManager {
  private weak var mapView: MAMapView?
  private var polylines: [MAPolyline] = []
  private var styles: [String: PolylineStyle] = [:]  // key 用 polyline 的唯一 id

  init(mapView: MAMapView) {
    self.mapView = mapView
  }

  /// 更新折线段
  func updateSegments(from array: [PolylineSegment]) {
    guard let mapView = mapView else { return }

    // 清理旧的
    mapView.removeOverlays(polylines)
    polylines.removeAll()
    styles.removeAll()

    // 添加新的
    for (index, item) in array.enumerated() {
      var coordsArray = item.coordinates.map {
        CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
      }

      let polyline: MAPolyline = MAPolyline(
        coordinates: &coordsArray, count: UInt(coordsArray.count))
      let polylineId = "segment-\(index)"
      polyline.title = polylineId
      polylines.append(polyline)
      styles[polylineId] = item.style
      mapView.add(polyline)
    }
  }

  /// 获取样式
  func styleForPolyline(_ polyline: MAPolyline) -> PolylineStyle? {
    return styles[polyline.title ?? ""]
  }
}
