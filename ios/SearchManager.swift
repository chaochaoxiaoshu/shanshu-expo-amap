import ExpoModulesCore
import AMapSearchKit
import Foundation

class SearchManager: NSObject {
    private weak var search: AMapSearchAPI?
    
    private let inputTipsSearchHandler = PromiseDelegateHandler<[String: Any]>()
    
    private let drivingSearchHandler = PromiseDelegateHandler<[String: Any]>()
    private let walkingSearchHandler = PromiseDelegateHandler<[String: Any]>()
    private let ridingSearchHandler = PromiseDelegateHandler<[String: Any]>()
    private let transitSearchHandler = PromiseDelegateHandler<[String: Any]>()
    
    init(search: AMapSearchAPI? = nil) {
        self.search = search
    }
    
    func searchInputTips(_ options: SearchInputTipsOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }
        
        inputTipsSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )
        
        let request = AMapInputTipsSearchRequest()
        request.keywords = options.keywords
        request.city = options.city
        request.cityLimit = options.cityLimit ?? false
        request.location = options.location
        request.types = options.types
        
        search.aMapInputTipsSearch(request)
    }
    
    func searchDrivingRoute(_ options: SearchDrivingRouteOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }

        drivingSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )

        var showFieldType: AMapDrivingRouteShowFieldType? = nil
        switch options.showFieldType {
        case .none:
            showFieldType = AMapDrivingRouteShowFieldType.none
        case .cost:
            showFieldType = .cost
        case .tmcs:
            showFieldType = .tmcs
        case .navi:
            showFieldType = .navi
        case .cities:
            showFieldType = .cities
        case .polyline:
            showFieldType = .polyline
        case .newEnergy:
            showFieldType = .newEnergy
        case .all:
            showFieldType = .all
        }

        let request = AMapDrivingCalRouteSearchRequest()
        request.origin = AMapGeoPoint.location(
            withLatitude: options.origin.latitude, longitude: options.origin.longitude)
        request.destination = AMapGeoPoint.location(
            withLatitude: options.destination.latitude, longitude: options.destination.longitude)
        request.showFieldType = showFieldType ?? .none

        search.aMapDrivingV2RouteSearch(request)
    }
    
    func searchWalkingRoute(_ options: SearchWalkingRouteOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }

        walkingSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )

        var showFieldType: AMapWalkingRouteShowFieldType? = nil
        switch options.showFieldType {
        case .none:
            showFieldType = AMapWalkingRouteShowFieldType.none
        case .cost:
            showFieldType = .cost
        case .navi:
            showFieldType = .navi
        case .polyline:
            showFieldType = .polyline
        case .all:
            showFieldType = .all
        }

        let request = AMapWalkingRouteSearchRequest()
        request.origin = AMapGeoPoint.location(
            withLatitude: options.origin.latitude, longitude: options.origin.longitude)
        request.destination = AMapGeoPoint.location(
            withLatitude: options.destination.latitude, longitude: options.destination.longitude)
        request.showFieldsType = showFieldType ?? .none

        search.aMapWalkingRouteSearch(request)
    }
    
    func searchRidingRoute(_ options: SearchRidingRouteOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }

        ridingSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )
        
        var showFieldType: AMapRidingRouteShowFieldsType? = nil
        switch options.showFieldType {
        case .none:
            showFieldType = AMapRidingRouteShowFieldsType.none
        case .cost:
            showFieldType = .cost
        case .navi:
            showFieldType = .navi
        case .polyline:
            showFieldType = .polyline
        case .all:
            showFieldType = .all
        }
        
        let request = AMapRidingRouteSearchRequest()
        request.origin = AMapGeoPoint.location(
            withLatitude: options.origin.latitude, longitude: options.origin.longitude)
        request.destination = AMapGeoPoint.location(
            withLatitude: options.destination.latitude, longitude: options.destination.longitude)
        request.showFieldsType = showFieldType ?? .none
        request.alternativeRoute = options.alternativeRoute
        
        search.aMapRidingRouteSearch(request)
    }
    
    func searchTransitRoute(_ options: SearchTransitRouteOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }
        
        transitSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )
        
        var showFieldType: AMapTransitRouteShowFieldsType? = nil
        switch options.showFieldType {
        case .none:
            showFieldType = AMapTransitRouteShowFieldsType.none
        case .cost:
            showFieldType = .cost
        case .navi:
            showFieldType = .navi
        case .polyline:
            showFieldType = .polyline
        case .all:
            showFieldType = .all
        }
        
        let request = AMapTransitRouteSearchRequest()
        request.origin = AMapGeoPoint.location(
            withLatitude: options.origin.latitude, longitude: options.origin.longitude)
        request.destination = AMapGeoPoint.location(
            withLatitude: options.destination.latitude, longitude: options.destination.longitude)
        request.strategy = options.strategy
        request.city = options.city
        request.destinationCity = options.destinationCity
        request.nightflag = options.nightflag
        request.originPOI = options.originPOI
        request.destinationPOI = options.destinationPOI
        request.adcode = options.adcode
        request.destinationAdcode = options.destinationAdcode
        request.alternativeRoute = options.alternativeRoute ?? 5
        request.multiExport = options.multiExport ?? false
        request.maxTrans = options.maxTrans ?? 4
        request.date = options.date
        request.time = options.time
        request.showFieldsType = showFieldType ?? .none
        
        search.aMapTransitRouteSearch(request)
    }
}

extension SearchManager: AMapSearchDelegate {
    
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        guard let response = response else {
            inputTipsSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
            return
        }
        
        inputTipsSearchHandler.finishSuccess([
            "tips": response.tips.compactMap({ tip in
                [
                    "uid": tip.uid,
                    "name": tip.name,
                    "address": tip.address,
                    "adcode": tip.adcode,
                    "district": tip.district,
                    "typecode": tip.typecode
                ]
            }),
            "count": response.count
        ])
    }

    // 路线搜索完成的回调
    func onRouteSearchDone(
        _ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!
    ) {
        guard let response = response, let route = response.route else {
            if request is AMapDrivingCalRouteSearchRequest {
                drivingSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
            } else if request is AMapWalkingRouteSearchRequest {
                walkingSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
            } else if request is AMapRidingRouteSearchRequest {
                ridingSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
            } else if request is AMapTransitRouteSearchRequest {
                transitSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
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
        } else if request is AMapRidingRouteSearchRequest {
            ridingSearchHandler.finishSuccess([
                "success": true,
                "count": response.count,
                "route": Utils.serializeRouteResponse(route),
            ])
        } else if request is AMapTransitRouteSearchRequest {
            transitSearchHandler.finishSuccess([
                "success": true,
                "count": response.count,
                "route": Utils.serializeRouteResponse(route),
            ])
        }
    }

    // 路线搜索失败的回调
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        if request is AMapDrivingCalRouteSearchRequest {
            drivingSearchHandler.finishFailure(code: "1", message: "路线规划失败: \(error?.localizedDescription ?? "Unknown error")")
        } else if request is AMapWalkingRouteSearchRequest {
            walkingSearchHandler.finishFailure(code: "1", message: "路线规划失败: \(error?.localizedDescription ?? "Unknown error")")
        } else if request is AMapRidingRouteSearchRequest {
            ridingSearchHandler.finishFailure(code: "1", message: "路线规划失败: \(error?.localizedDescription ?? "Unknown error")")
        } else if request is AMapTransitRouteSearchRequest {
            transitSearchHandler.finishFailure(code: "1", message: "路线规划失败: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}
