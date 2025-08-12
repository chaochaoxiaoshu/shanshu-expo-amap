import MAMapKit
import UIKit

/// 声明式绘制标记点的管理器
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

        var ssAnnotations: [SSAnnotation] = []

        for annotation in annotations {
            guard let style = styles.first(where: { $0.id == annotation.styleId }) else { continue }

            let ssAnnotation = SSAnnotation(
                coordinate: CLLocationCoordinate2D(
                    latitude: annotation.coordinate.latitude,
                    longitude: annotation.coordinate.longitude
                ),
                style: style
            )
            ssAnnotation.title = annotation.title
            ssAnnotations.append(ssAnnotation)
        }

        // 一次性添加
        mapView.addAnnotations(ssAnnotations)

        // 单独处理选中状态（可选）
        for (index, annotation) in annotations.enumerated() where annotation.selected {
            mapView.selectAnnotation(ssAnnotations[index], animated: true)
        }

        print("渲染完成： \(annotations.count) 个标记")
    }
}

func offsetFrom(_ value: [String: Double]?) -> CGPoint {
    guard let dict = value, let x = dict["x"], let y = dict["y"] else {
        return .zero
    }
    return CGPoint(x: x, y: y)
}

/// 字体样式
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
        if dictionary.isEmpty { return nil }

        let color = dictionary["color"] as? String ?? "#000000"
        let fontSize = dictionary["fontSize"] as? Double ?? 16
        let fontWeight = dictionary["fontWeight"] as? String ?? "medium"
        let fontFamily = dictionary["fontFamily"] as? String
        let lineHeight = dictionary["lineHeight"] as? Double ?? 16
        let numberOfLines = dictionary["numberOfLines"] as? Int
        let textAlign = dictionary["textAlign"] as? String ?? "center"
        let offsetDict = dictionary["offset"] as? [String: Double]

        return TextStyle(
            color: UIColor(hex: color),
            fontSize: CGFloat(fontSize),
            fontWeight: fontWeightFrom(fontWeight),
            fontFamily: fontFamily,
            lineHeight: CGFloat(lineHeight),
            numberOfLines: numberOfLines,
            textAlign: textAlignmentFrom(textAlign),
            offset: offsetFrom(offsetDict)
        )
    }

    static func fontWeightFrom(_ value: Any?) -> UIFont.Weight {
        guard let str = value as? String else { return .regular }
        switch str.lowercased() {
        case "normal": return .regular
        case "bold": return .bold
        case "100": return .ultraLight
        case "200": return .thin
        case "300": return .light
        case "400": return .regular
        case "500": return .medium
        case "600": return .semibold
        case "700": return .bold
        case "800": return .heavy
        case "900": return .black
        default: return .regular
        }
    }

    static func textAlignmentFrom(_ value: Any?) -> NSTextAlignment {
        guard let str = value as? String else { return .natural }
        switch str.lowercased() {
        case "left": return .left
        case "center": return .center
        case "right": return .right
        default: return .natural
        }
    }
}

/// 标记点样式
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
            let centerOffsetDict = dictionary["centerOffset"] as? [String: Double]?
        else {
            return nil
        }

        let zIndex = dictionary["zIndex"] as? Int ?? 0
        let enabled = dictionary["enabled"] as? Bool ?? true
        let centerOffset = offsetFrom(centerOffsetDict)
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

/// 标记点数据
struct Annotation {
    var key: String
    var coordinate: CoordinatePlain
    var title: String?
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

        return Annotation(
            key: key,
            coordinate: coordinate,
            title: title,
            styleId: styleId,
            selected: selected
        )
    }
}

/// 继承自 MAAnnotation 的标记点数据，用于配置 AMapView
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

/// 继承自 MAAnnotationView 的标记点视图，显示一个自定义的图片 + 标题视图
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

/// 图片 + 标题视图
class OverlayView: UIView {
    private let contentView = UIView()
    let imageView = UIImageView()
    let label = UILabel()

    var contentOffset: CGPoint = .zero {
        didSet { updateContentOffsetConstraints() }
    }

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
        print("contentOffset", contentOffset)
        print("textOffset", textOffset)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(label)

        contentCenterXConstraint = contentView.centerXAnchor.constraint(
            equalTo: centerXAnchor, constant: contentOffset.x)
        contentCenterYConstraint = contentView.centerYAnchor.constraint(
            equalTo: centerYAnchor, constant: contentOffset.y)

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

        updateContentOffsetConstraints()
        updateLabelOffsetConstraints()
    }

    private func updateContentOffsetConstraints() {
        contentCenterXConstraint.constant = contentOffset.x
        contentCenterYConstraint.constant = contentOffset.y
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func updateLabelOffsetConstraints() {
        labelCenterXConstraint.constant = textOffset.x
        labelCenterYConstraint.constant = textOffset.y
        setNeedsLayout()
        layoutIfNeeded()
    }
}
