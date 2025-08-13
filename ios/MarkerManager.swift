import MAMapKit
import UIKit

/// 声明式绘制标记点的管理器
class MarkerManager {
    private weak var mapView: MAMapView?
    
    private var markers: [Marker] = []

    init(mapView: MAMapView) {
        self.mapView = mapView
    }
    
    func setMarkers(_ markers: [Marker]) {
        guard let mapView = mapView else { return }
        
        let annotationsToRemove = mapView.annotations.filter { $0 is SSAnnotation }
        mapView.removeAnnotations(annotationsToRemove)
        
        self.markers = markers
        var annotations: [SSAnnotation] = []
        
        for marker in markers {
            let annotation = SSAnnotation(id: marker.id, coordinate: CLLocationCoordinate2D(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude), title: marker.title, subtitle: marker.subtitle)

            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    func getMarker(id: String) -> Marker? {
        markers.first { marker in
            marker.id == id
        }
    }
    
//    func setSelectedAnnotationId(_ id: String) {
//        selectedAnnotationId = id
//        trySelectAnnotation()
//    }
//
//    private func tryRenderAnnotations() {
//        guard isStylesReady && isAnnotationsReady, let mapView = mapView else { return }
//
//        mapView.removeAnnotations(mapView.annotations)
//
//        var ssAnnotations: [SSAnnotation] = []
//
//        for annotation in annotations {
//            guard let style = styles.first(where: { $0.id == annotation.styleId }),
//                  let image = uiImages[style.id] else { continue }
//
//            let ssAnnotation = SSAnnotation(id: annotation.id, coordinate: CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude),
//                style: style,
//                image: image
//            )
//            ssAnnotation.title = annotation.title
//            ssAnnotations.append(ssAnnotation)
//        }
//
//        mapView.addAnnotations(ssAnnotations)
//
//        trySelectAnnotation()
//    }
//    
//    private func trySelectAnnotation() {
//        guard
//            isStylesReady && isAnnotationsReady,
//            let mapView = mapView,
//            let ssAnnotations = mapView.annotations as? [SSAnnotation],
//            let selectedAnnotationId = selectedAnnotationId,
//            let selectedAnnotation = ssAnnotations.first(where: { $0.id == selectedAnnotationId })
//        else { return }
//        
//        mapView.selectAnnotation(selectedAnnotation, animated: true)
//    }
}

class SSAnnotation: NSObject, MAAnnotation {
    var id: String
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(id: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class TextAnnotationView: MAAnnotationView {

    private let textLabel = UILabel()
    private let textStyle: TextStyle?
    private let textOffset: CGPoint

    init(annotation: MAAnnotation?, reuseIdentifier: String?, textStyle: TextStyle?, textOffset: CGPoint = .zero) {
        self.textStyle = textStyle
        self.textOffset = textOffset
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupTextLabel()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupTextLabel() {
        textLabel.textAlignment = .center
        if let textStyle = textStyle {
            if let hex = textStyle.color { textLabel.textColor = UIColor(hex: hex) }
            textLabel.font = UIFont.systemFont(ofSize: textStyle.fontSize ?? 17,
                                               weight: UIFont.Weight(string: textStyle.fontWeight ?? "") ?? .regular)
            textLabel.numberOfLines = textStyle.numberOfLines ?? 1
        } else {
            textLabel.font = .systemFont(ofSize: 14, weight: .medium)
            textLabel.textColor = .white
        }

        addSubview(textLabel)
        bringSubviewToFront(textLabel)
    }

    func setText(_ text: String?) {
        textLabel.text = text
        textLabel.sizeToFit()
        positionLabel()
        bringSubviewToFront(textLabel)
    }

    private func positionLabel() {
        textLabel.center = CGPoint(
            x: bounds.width / 2 + textOffset.x,
            y: bounds.height / 2 + textOffset.y
        )
    }

    override var image: UIImage? {
        didSet { setNeedsLayout() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        positionLabel()
        bringSubviewToFront(textLabel)
    }
}
