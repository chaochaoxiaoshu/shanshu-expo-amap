import AMapFoundationKit
import AMapLocationKit
import AMapSearchKit
import ExpoModulesCore
import MAMapKit

class ShanshuExpoMapView: ExpoView {
    private let mapView = MAMapView()

    private var annotationManager: AnnotationManager!
    private var polylineManager: PolylineManager!

    private var userTrackingMode: MAUserTrackingMode = .none

    private let onLoad = EventDispatcher()
    private let onZoom = EventDispatcher()
    private let onRegionChanged = EventDispatcher()

    private let setCenterHandler = PromiseDelegateHandler<Void>()

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        clipsToBounds = true
        setupMapView()
        initAnnotationManager()
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

    private func initAnnotationManager() {
        annotationManager = AnnotationManager(mapView: mapView)
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

    func setAnnotationStyles(_ styles: [[String: Any]]) {
        var stylesWithImages = styles.map { $0 }
        let imageSources = styles.map { $0["image"] }
        ImageLoader.loadMultiple(from: imageSources) { images in
            for (index, image) in images.enumerated() {
                stylesWithImages[index]["image"] = image
            }
            DispatchQueue.main.async {
                self.annotationManager.setStyles(stylesWithImages)
            }
        }
    }

    func setAnnotations(_ annotations: [[String: Any]]) {
        annotationManager.setAnnotations(annotations)
    }

    func setPolylineSegments(_ segments: [PolylineSegment]) {
        polylineManager.updateSegments(from: segments)
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
        if let annotation = annotation as? SSAnnotation {
            let reuseId = "SSAnnotationView_\(annotation.style.hashValue)"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if view == nil {
                view = SSAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            } else {
                view?.annotation = annotation
            }

            return view!
        }
        return nil
    }

    // 渲染覆盖物的回调
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay is MAPolyline {
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            if let style = polylineManager.styleForPolyline(overlay as! MAPolyline) {
                renderer.strokeColor = UIColor(hex: style.color)
                renderer.lineWidth = style.width
                renderer.lineDashType = style.lineDash ?? false ? kMALineDashTypeSquare : kMALineDashTypeNone
                renderer.is3DArrowLine = style.is3DArrowLine ?? false
            }
            return renderer
        }
        return nil
    }

    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        onZoom(["zoomLevel": mapView.zoomLevel])
    }
}
