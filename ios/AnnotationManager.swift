import MAMapKit
import UIKit

/// 声明式绘制标记点的管理器
class AnnotationManager {
    private weak var mapView: MAMapView?
    
    private var selectedAnnotationId: String? = nil
    
    private var annotations: [Annotation] = []
    private var styles: [AnnotationStyle] = []
    private var uiImages: [String: UIImage] = [:]

    private var isStylesReady = false
    private var isAnnotationsReady = false

    init(mapView: MAMapView) {
        self.mapView = mapView
    }

    func setStyles(_ styles: [AnnotationStyle]) {
        self.styles = styles
        let imageSources = styles.map { $0.image.url }
        Task { [weak self] in
            guard let self = self else { return }
            
            let images = await ImageLoader.loadMultiple(from: imageSources)
            for (index, image) in images.enumerated() {
                let id = styles[index].id
                self.uiImages[id] = image
            }
            
            await MainActor.run {
                self.isStylesReady = true
                self.tryRenderAnnotations()
            }
        }
    }

    func setAnnotations(_ annotations: [Annotation]) {
        self.annotations = annotations
        isAnnotationsReady = true
        tryRenderAnnotations()
    }
    
    func setSelectedAnnotationId(_ id: String) {
        selectedAnnotationId = id
        trySelectAnnotation()
    }

    private func tryRenderAnnotations() {
        guard isStylesReady && isAnnotationsReady, let mapView = mapView else { return }

        mapView.removeAnnotations(mapView.annotations)

        var ssAnnotations: [SSAnnotation] = []

        for annotation in annotations {
            guard let style = styles.first(where: { $0.id == annotation.styleId }),
                  let image = uiImages[style.id] else { continue }

            let ssAnnotation = SSAnnotation(id: annotation.id, coordinate: CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude),
                style: style,
                image: image
            )
            ssAnnotation.title = annotation.title
            ssAnnotations.append(ssAnnotation)
        }

        mapView.addAnnotations(ssAnnotations)

        trySelectAnnotation()
    }
    
    private func trySelectAnnotation() {
        guard
            isStylesReady && isAnnotationsReady,
            let mapView = mapView,
            let ssAnnotations = mapView.annotations as? [SSAnnotation],
            let selectedAnnotationId = selectedAnnotationId,
            let selectedAnnotation = ssAnnotations.first(where: { $0.id == selectedAnnotationId })
        else { return }
        
        mapView.selectAnnotation(selectedAnnotation, animated: true)
    }
}

/// 继承自 MAAnnotation 的标记点数据，用于配置 AMapView
class SSAnnotation: NSObject, MAAnnotation {
    var id: String
    var coordinate: CLLocationCoordinate2D
    var style: AnnotationStyle
    var image: UIImage
    var title: String?

    init(id: String, coordinate: CLLocationCoordinate2D, style: AnnotationStyle, image: UIImage) {
        self.id = id
        self.coordinate = coordinate
        self.style = style
        self.image = image
        super.init()
    }
}

/// 继承自 MAAnnotationView 的标记点视图，显示一个自定义的图片 + 标题视图
class SSAnnotationView: MAAnnotationView {

    override init(annotation: MAAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.isEnabled = true
        self.canShowCallout = false
        self.isUserInteractionEnabled = true

        guard let annotation = annotation as? SSAnnotation else {
            return
        }
        
        self.frame = CGRect(
            origin: CGPoint.zero, size: CGSize(width: annotation.style.image.size.width, height: annotation.style.image.size.height)
        )

        let overlayView = OverlayView(
            frame: self.bounds)

        overlayView.imageView.image = annotation.image.resized(to: CGSize(width: annotation.style.image.size.width, height: annotation.style.image.size.height))
        overlayView.label.text = annotation.title ?? ""
        overlayView.contentOffset = CGPoint(x: annotation.style.centerOffset?.x ?? 0, y: annotation.style.centerOffset?.y ?? 0)
        overlayView.textOffset = CGPoint(x: annotation.style.textStyle?.offset?.x ?? 0, y: annotation.style.textStyle?.offset?.y ?? 0)

        let textStyle = annotation.style.textStyle
        
        if let textColorString = textStyle?.color {
            overlayView.label.textColor = UIColor(hex: textColorString)
        }
        overlayView.label.font = UIFont.systemFont(ofSize: textStyle?.fontSize ?? 16, weight: UIFont.Weight(string: textStyle?.fontWeight ?? "") ?? .medium)
        overlayView.label.numberOfLines = textStyle?.numberOfLines ?? 1
        overlayView.label.textAlignment = NSTextAlignment(string: textStyle?.textAlign ?? "") ?? .center

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
        self.isUserInteractionEnabled = false
        self.imageView.isUserInteractionEnabled = false
        self.label.isUserInteractionEnabled = false

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
