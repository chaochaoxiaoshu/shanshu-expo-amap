import MAMapKit
import UIKit

class AnnotationManager {
  private weak var mapView: MAMapView?
  private var annotations: [Annotation] = []
  private var styles: [AnnotationStyle] = []

  private var isStylesReady = false
  private var isAnnotationsReady = false

  init(mapView: MAMapView) {
    self.mapView = mapView
  }

  func setStyles(_ styles: [[String: Any]]) {
    self.styles = styles.compactMap { AnnotationStyle.from(dictionary: $0) }
    isStylesReady = true
    tryRenderAnnotations()
  }

  func setAnnotations(_ annotations: [[String: Any]]) {
    self.annotations = annotations.compactMap { Annotation.from(dictionary: $0) }
    isAnnotationsReady = true
    tryRenderAnnotations()
  }

  private func tryRenderAnnotations() {
    guard isStylesReady && isAnnotationsReady, let mapView = mapView else { return }

    mapView.removeAnnotations(mapView.annotations)

    for annotation in annotations {
      guard let style = styles.first(where: { $0.id == annotation.styleId }) else { continue }

      let ssAnnotation = SSAnnotation(
        coordinate: CLLocationCoordinate2D(
          latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude),
        style: style)
      ssAnnotation.title = annotation.title

      mapView.addAnnotation(ssAnnotation)
      if annotation.selected {
        mapView.selectAnnotation(ssAnnotation, animated: true)
      }
    }

    print("渲染完成： \(annotations.count) 个标记")
  }
}

struct TextStyle: Hashable {
  var color: UIColor
  var fontSize: CGFloat
  var fontWeight: UIFont.Weight
  var fontFamily: String?
  var lineHeight: CGFloat?
  var numberOfLines: Int?
  var textAlign: NSTextAlignment?
  var offset: CGPoint?

  static func from(dictionary: [String: Any]) -> TextStyle? {
    guard let color = dictionary["color"] as? UIColor,
      let fontSize = dictionary["fontSize"] as? CGFloat,
      let fontWeight = dictionary["fontWeight"] as? UIFont.Weight,
      let fontFamily = dictionary["fontFamily"] as? String,
      let lineHeight = dictionary["lineHeight"] as? CGFloat,
      let numberOfLines = dictionary["numberOfLines"] as? Int,
      let textAlign = dictionary["textAlign"] as? NSTextAlignment,
      let offset = dictionary["offset"] as? CGPoint
    else {
      return nil
    }

    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      lineHeight: lineHeight,
      numberOfLines: numberOfLines,
      textAlign: textAlign,
      offset: offset)
  }
}

struct AnnotationStyle: Hashable {
  var id: String
  var zIndex: Int
  var image: UIImage
  var imageSize: CGSize
  var centerOffset: CGPoint
  var enabled: Bool
  var textStyle: TextStyle?

  static func from(dictionary: [String: Any]) -> AnnotationStyle? {
    guard let id = dictionary["id"] as? String,
      let image = dictionary["image"] as? UIImage,
      let imageSizeDict = dictionary["imageSize"] as? [String: Any],
      let centerOffsetDict = dictionary["centerOffset"] as? [String: Any]
    else {
      return nil
    }

    let zIndex = dictionary["zIndex"] as? Int ?? 0
    let enabled = dictionary["enabled"] as? Bool ?? true
    let centerOffset = CGPoint(
      x: centerOffsetDict["x"] as? CGFloat ?? 0,
      y: centerOffsetDict["y"] as? CGFloat ?? 0)
    let textStyleDict = dictionary["textStyle"] as? [String: Any]
    let textStyle = TextStyle.from(dictionary: textStyleDict ?? [:])

    return AnnotationStyle(
      id: id,
      zIndex: zIndex,
      image: image,
      imageSize: CGSize(
        width: imageSizeDict["width"] as? CGFloat ?? 0,
        height: imageSizeDict["height"] as? CGFloat ?? 0),
      centerOffset: centerOffset,
      enabled: enabled,
      textStyle: textStyle)
  }
}

struct Annotation {
  var key: String
  var coordinate: CoordinatePlain
  var title: String?
  var subtitle: String?
  var styleId: String
  var selected: Bool

  static func from(dictionary: [String: Any]) -> Annotation? {
    guard
      let coordinateDict = dictionary["coordinate"] as? [String: Any],
      let latitude = coordinateDict["latitude"] as? Double,
      let longitude = coordinateDict["longitude"] as? Double,
      let styleId = dictionary["styleId"] as? String
    else {
      return nil
    }

    let coordinate = CoordinatePlain(latitude: latitude, longitude: longitude)
    let key = dictionary["key"] as? String ?? UUID().uuidString
    let selected = dictionary["selected"] as? Bool ?? false
    let title = dictionary["title"] as? String
    let subtitle = dictionary["subtitle"] as? String

    return Annotation(
      key: key,
      coordinate: coordinate,
      title: title,
      subtitle: subtitle,
      styleId: styleId,
      selected: selected
    )
  }
}

class SSAnnotation: NSObject, MAAnnotation {
  var style: AnnotationStyle
  var coordinate: CLLocationCoordinate2D
  var title: String?
  var subtitle: String?

  init(coordinate: CLLocationCoordinate2D, style: AnnotationStyle) {
    self.coordinate = coordinate
    self.style = style
    super.init()
  }
}

class SSAnnotationView: MAAnnotationView {

  override init(annotation: MAAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

    guard let annotation = annotation as? SSAnnotation else {
      return
    }

    let overlayView = OverlayView(
      frame: CGRect(
        x: 0, y: 0,
        width: annotation.style.imageSize.width,
        height: annotation.style.imageSize.height))

    overlayView.imageView.image = annotation.style.image.resized(to: annotation.style.imageSize)
    overlayView.label.text = annotation.title ?? ""
    overlayView.contentOffset = annotation.style.centerOffset
    overlayView.textOffset = annotation.style.textStyle?.offset ?? .zero

    overlayView.label.textColor = annotation.style.textStyle?.color ?? .black
    overlayView.label.font = UIFont.systemFont(
      ofSize: annotation.style.textStyle?.fontSize ?? 16,
      weight: annotation.style.textStyle?.fontWeight ?? .medium)
    overlayView.label.numberOfLines = annotation.style.textStyle?.numberOfLines ?? 1
    overlayView.label.textAlignment = annotation.style.textStyle?.textAlign ?? .center

    self.addSubview(overlayView)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class OverlayView: UIView {
  private let contentView = UIView()
  let imageView = UIImageView()
  let label = UILabel()

  // 整体移动偏移（图片和文字整体移动）
  var contentOffset: CGPoint = .zero {
    didSet { updateContentOffsetConstraints() }
  }

  // 文字相对于图片中心的微调偏移
  var textOffset: CGPoint = .zero {
    didSet { updateLabelOffsetConstraints() }
  }

  private var contentCenterXConstraint: NSLayoutConstraint!
  private var contentCenterYConstraint: NSLayoutConstraint!

  private var labelCenterXConstraint: NSLayoutConstraint!
  private var labelCenterYConstraint: NSLayoutConstraint!

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    label.translatesAutoresizingMaskIntoConstraints = false

    addSubview(contentView)
    contentView.addSubview(imageView)
    contentView.addSubview(label)

    // contentView 居中 OverlayView，并加 contentOffset
    contentCenterXConstraint = contentView.centerXAnchor.constraint(
      equalTo: centerXAnchor, constant: contentOffset.x)
    contentCenterYConstraint = contentView.centerYAnchor.constraint(
      equalTo: centerYAnchor, constant: contentOffset.y)

    // label 居中 contentView，再加 textOffset
    labelCenterXConstraint = label.centerXAnchor.constraint(
      equalTo: contentView.centerXAnchor, constant: textOffset.x)
    labelCenterYConstraint = label.centerYAnchor.constraint(
      equalTo: contentView.centerYAnchor, constant: textOffset.y)

    NSLayoutConstraint.activate([
      contentCenterXConstraint,
      contentCenterYConstraint,

      contentView.widthAnchor.constraint(equalTo: imageView.widthAnchor),
      contentView.heightAnchor.constraint(equalTo: imageView.heightAnchor),

      imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

      labelCenterXConstraint,
      labelCenterYConstraint,
    ])

    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
  }

  private func updateContentOffsetConstraints() {
    contentCenterXConstraint.constant = contentOffset.x
    contentCenterYConstraint.constant = contentOffset.y
    setNeedsLayout()
  }

  private func updateLabelOffsetConstraints() {
    labelCenterXConstraint.constant = textOffset.x
    labelCenterYConstraint.constant = textOffset.y
    setNeedsLayout()
  }
}
