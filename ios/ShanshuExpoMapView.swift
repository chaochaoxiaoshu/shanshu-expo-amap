import AMapFoundationKit
import AMapLocationKit
import AMapSearchKit
import ExpoModulesCore
import MAMapKit

class ShanshuExpoMapView: ExpoView {
    private let mapView = MAMapView()

    private var markerManager: MarkerManager!
    private var polylineManager: PolylineManager!

    private var userTrackingMode: MAUserTrackingMode = .none

    private let onLoad = EventDispatcher()
    private let onZoom = EventDispatcher()
    private let onRegionChanged = EventDispatcher()
    private let onSelectAnnotation = EventDispatcher()

    private let setCenterHandler = PromiseDelegateHandler<Void>()

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        clipsToBounds = true
        setupMapView()
        initMarkerManager()
        initPolylineManager()
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.showsScale = true

        // let coordinate = CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074)
        // let region = MACoordinateRegion(
        //   center: coordinate, span: MACoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        // mapView.setRegion(region, animated: false)

        addSubview(mapView)
    }

    private func initMarkerManager() {
        markerManager = MarkerManager(mapView: mapView)
    }

    private func initPolylineManager() {
        polylineManager = PolylineManager(mapView: mapView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        mapView.frame = bounds
    }

    // MARK: - 地图命令式方法

    func setCenter(latitude: Double?, longitude: Double?, promise: Promise) {
        setCenterHandler.begin(
            resolve: { promise.resolve(()) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )

        guard let latitude = latitude, let longitude = longitude else {
            setCenterHandler.finishFailure(code: "1", message: "无效的经纬度坐标")
            return
        }
        guard mapView.userTrackingMode == .none else {
            setCenterHandler.finishFailure(code: "1", message: "用户跟踪模式下无法设置中心点")
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.setCenter(coordinate, animated: true)
        setCenterHandler.finishSuccess(Void())
    }

    func setZoomLevel(_ zoomLevel: Int) {
        mapView.setZoomLevel(CGFloat(zoomLevel), animated: true)
    }

    func setMapType(_ mapType: Int) {
        mapView.mapType = MAMapType(rawValue: mapType) ?? .standard
    }

    func setShowUserLocation(_ showUserLocation: Bool) {
        mapView.showsUserLocation = showUserLocation
    }

    func setUserTrackingMode(_ userTrackingMode: Int) {
        if let userTrackingMode = MAUserTrackingMode(rawValue: userTrackingMode) {
            mapView.userTrackingMode = userTrackingMode
            self.userTrackingMode = userTrackingMode
        }
    }

    func setMarkers(_ markers: [Marker]) {
        markerManager.setMarkers(markers)
    }

    func setPolylines(_ polylines: [Polyline]) {
        polylineManager.setPolylines(polylines)
    }
}

// MARK: - MAMapViewDelegate
extension ShanshuExpoMapView: MAMapViewDelegate {
    // 请求位置权限回调
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager) {
        if CLLocationManager().authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        onLoad([
            "message": "Map loaded successfully",
            "timestamp": Date().timeIntervalSince1970,
        ])
    }
    
    func mapViewRegionChanged(_ mapView: MAMapView!) {
        onRegionChanged([
            "center": [
                "latitude": mapView.region.center.latitude,
                "longitude": mapView.region.center.longitude
            ],
            "span": [
                "latitudeDelta": mapView.region.span.latitudeDelta,
                "longitudeDelta": mapView.region.span.longitudeDelta
            ]
        ])
    }

    // 用户位置更新的回调
    func mapView(
        _ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool
    ) {
        if updatingLocation && userTrackingMode != .none {
            let coordinate = userLocation.coordinate
            mapView.setCenter(coordinate, animated: true)
        }
    }

    // 渲染标记的回调
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        guard let annotation = annotation as? SSAnnotation else { return nil }
        guard let marker = markerManager.getMarker(id: annotation.id) else { return nil }
        
        if let image = marker.image {
            let reuseId = "SSAnnotationView_\(annotation.id)"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? TextAnnotationView
            if view == nil {
                view = TextAnnotationView(annotation: annotation, reuseIdentifier: reuseId, textStyle: marker.textStyle, textOffset: CGPoint(x: marker.textOffset?.x ?? 0, y: marker.textOffset?.y ?? 0))
            } else {
                view?.annotation = annotation
            }
            view?.setText(marker.title ?? annotation.title)
            
            Task { [weak view] in
                let uiImage = await ImageLoader.from(image.url)
                DispatchQueue.main.async {
                    view?.image = uiImage?.resized(to: CGSize(width: image.size.width, height: image.size.height))
                    view?.setNeedsLayout()
                }
            }
            if let zIndex = marker.zIndex {
                view?.zIndex = zIndex
            }
            if let centerOffset = marker.centerOffset {
                view?.centerOffset = CGPoint(x: centerOffset.x, y: centerOffset.y)
            }
            if let calloutOffset = marker.calloutOffset {
                view?.calloutOffset = CGPoint(x: calloutOffset.x, y: calloutOffset.y)
            }
            if let enabled = marker.enabled {
                view?.isEnabled = enabled
            }
            if let highlighted = marker.highlighted {
                view?.isHighlighted = highlighted
            }
            if let canShowCallout = marker.canShowCallout {
                view?.canShowCallout = canShowCallout
            }
            if let draggable = marker.draggable {
                view?.isDraggable = draggable
            }
            if let canAdjustPosition = marker.canAdjustPosition {
                view?.canAdjustPositon = canAdjustPosition
            }
            
            return view
        } else {
            let reuseId = "PinAnnotation_\(annotation.id)"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if view == nil {
                view = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            } else {
                view?.annotation = annotation
            }
            
            if let zIndex = marker.zIndex {
                view?.zIndex = zIndex
            }
            if let centerOffset = marker.centerOffset {
                view?.centerOffset = CGPoint(x: centerOffset.x, y: centerOffset.y)
            }
            if let calloutOffset = marker.calloutOffset {
                view?.calloutOffset = CGPoint(x: calloutOffset.x, y: calloutOffset.y)
            }
            if let enabled = marker.enabled {
                view?.isEnabled = enabled
            }
            if let highlighted = marker.highlighted {
                view?.isHighlighted = highlighted
            }
            if let canShowCallout = marker.canShowCallout {
                view?.canShowCallout = canShowCallout
            }
            if let draggable = marker.draggable {
                view?.isDraggable = draggable
            }
            if let canAdjustPosition = marker.canAdjustPosition {
                view?.canAdjustPositon = canAdjustPosition
            }
            
            return view
        }
    }
    
    func mapView(_ mapView: MAMapView!, didAnnotationViewTapped view: MAAnnotationView!) {
        
    }
    
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        
    }

    // 渲染覆盖物的回调
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay is MAPolyline {
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            if let style = polylineManager.styleForPolyline(overlay as! MAPolyline) {
                if let fillColor = style.fillColor {
                    renderer.fillColor = UIColor(hex: fillColor)
                }
                if let strokeColor = style.strokeColor {
                    renderer.strokeColor = UIColor(hex: strokeColor)
                }
                if let lineWidth = style.lineWidth {
                    renderer.lineWidth = lineWidth
                }
                if let lineJoinType = style.lineJoinType {
                    renderer.lineJoinType = MALineJoinType(rawValue: UInt32(lineJoinType))
                }
                if let lineCapType = style.lineCapType {
                    renderer.lineCapType = MALineCapType(rawValue: UInt32(lineCapType))
                }
                if let miterLimit = style.miterLimit {
                    renderer.miterLimit = CGFloat(miterLimit)
                }
                if let lineDashType = style.lineDashType {
                    renderer.lineDashType = MALineDashType(rawValue: UInt32(lineDashType))
                }
                if let reducePoint = style.reducePoint {
                    renderer.reducePoint = reducePoint
                }
                if let is3DArrowLine = style.is3DArrowLine {
                    renderer.is3DArrowLine = is3DArrowLine
                }
                if let sideColor = style.sideColor {
                    renderer.sideColor = UIColor(hex: sideColor)
                }
                if let userInteractionEnabled = style.userInteractionEnabled {
                    renderer.userInteractionEnabled = userInteractionEnabled
                }
                if let hitTestInset = style.hitTestInset {
                    renderer.hitTestInset = CGFloat(hitTestInset)
                }
                if let showRangeEnabled = style.showRangeEnabled {
                    renderer.showRangeEnabled = showRangeEnabled
                }
                if let pathShowRange = style.pathShowRange {
                    renderer.showRange = MAPathShowRange(begin: Float(pathShowRange.begin), end: Float(pathShowRange.end))
                }
                if let textureImage = style.textureImage {
                    Task {
                        let image = await ImageLoader.from(textureImage)
                        renderer.strokeImage = image
                        mapView.setNeedsDisplay()
                    }
                }
            }
            print("画了一条线")
            return renderer
        }
        return nil
    }

    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        onZoom(["zoomLevel": mapView.zoomLevel])
    }
}
