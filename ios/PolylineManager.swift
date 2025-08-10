import MAMapKit

class PolylineManager {
  private weak var mapView: MAMapView?
  private var polylines: [MAPolyline] = []
  private var styles: [String: PolylineStyle] = [:]  // key 用 polyline 的唯一 id

  init(mapView: MAMapView) {
    self.mapView = mapView
  }

  /// 更新折线段
  func updateSegments(from array: [[String: Any]]) {
    guard let mapView = mapView else { return }

    // 清理旧的
    mapView.removeOverlays(polylines)
    polylines.removeAll()
    styles.removeAll()

    // 添加新的
    for (index, item) in array.enumerated() {
      if let segment = PolylineSegment.from(dictionary: item) {
        var coordsArray = segment.coordinates.map {
          CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }

        let polyline: MAPolyline = MAPolyline(
          coordinates: &coordsArray, count: UInt(coordsArray.count))
        let polylineId = "segment-\(index)"
        polyline.title = polylineId
        polylines.append(polyline)
        styles[polylineId] = segment.style
        mapView.add(polyline)
      }
    }
  }

  /// 获取样式
  func styleForPolyline(_ polyline: MAPolyline) -> PolylineStyle? {
    return styles[polyline.title ?? ""]
  }
}

// MARK: - 样式结构
struct PolylineStyle {
  var color: UIColor
  var width: CGFloat
  var lineDash: Bool
  var is3DArrowLine: Bool

  static func from(dictionary: [String: Any]) -> PolylineStyle? {
    guard let colorHex = dictionary["color"] as? String,
      let width = dictionary["width"] as? CGFloat,
      let lineDash = dictionary["lineDash"] as? Bool,
      let is3DArrowLine = dictionary["is3DArrowLine"] as? Bool
    else {
      return nil
    }
    return PolylineStyle(
      color: UIColor(hex: colorHex), width: width, lineDash: lineDash, is3DArrowLine: is3DArrowLine)
  }
}

// MARK: - 数据结构
struct PolylineSegment {
  var coordinates: [Coordinate]
  var style: PolylineStyle

  static func from(dictionary: [String: Any]) -> PolylineSegment? {
    guard let coordsArray = dictionary["coordinates"] as? [[String: Any]],
      let styleDict = dictionary["style"] as? [String: Any],
      let style = PolylineStyle.from(dictionary: styleDict)
    else {
      return nil
    }

    let coords = coordsArray.compactMap { Coordinate.from(dictionary: $0) }
    return PolylineSegment(coordinates: coords, style: style)
  }
}

struct Coordinate {
  var latitude: Double
  var longitude: Double

  static func from(dictionary: [String: Any]) -> Coordinate? {
    guard let lat = dictionary["latitude"] as? Double,
      let lon = dictionary["longitude"] as? Double
    else {
      return nil
    }
    return Coordinate(latitude: lat, longitude: lon)
  }
}

// MARK: - UIColor Hex 支持
extension UIColor {
  convenience init(hex: String) {
    var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if hexString.hasPrefix("#") { hexString.removeFirst() }

    var rgbValue: UInt64 = 0
    Scanner(string: hexString).scanHexInt64(&rgbValue)

    if hexString.count == 6 {
      self.init(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: 1.0
      )
    } else if hexString.count == 8 {
      self.init(
        red: CGFloat((rgbValue & 0xFF00_0000) >> 24) / 255.0,
        green: CGFloat((rgbValue & 0x00FF_0000) >> 16) / 255.0,
        blue: CGFloat((rgbValue & 0x0000_FF00) >> 8) / 255.0,
        alpha: CGFloat(rgbValue & 0x0000_00FF) / 255.0
      )
    } else {
      self.init(white: 0, alpha: 1)
    }
  }
}
