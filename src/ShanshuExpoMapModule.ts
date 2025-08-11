import { NativeModule, requireNativeModule } from 'expo'

import {
  AMapDrivingRouteShowFieldType,
  AMapWalkingRouteShowFieldType,
  Coordinate,
  OnRouteSearchDoneResult,
  RequestLocationResult,
  ShanshuExpoMapModuleEvents
} from './ShanshuExpoMap.types'

declare class ShanshuExpoMapModule extends NativeModule<ShanshuExpoMapModuleEvents> {
  requestLocation: () => Promise<RequestLocationResult>
  /**
   * 规划驾车路线
   *
   * @param origin - 起点坐标
   * @param destination - 终点坐标
   * @param showFieldType - 显示字段配置，详见 {@link AMapDrivingRouteShowFieldType}
   * @returns 路线信息
   *
   * @example
   * ```tsx
   * try {
   *   const result = await mapViewRef.current?.searchDrivingRoute({
   *     origin: { latitude: 31.230545, longitude: 121.473724 },
   *     destination: { latitude: 39.900896, longitude: 116.401049 },
   *     showFieldType: 'polyline'
   *   })
   *   console.log('🚗 驾车路线规划结果:', result)
   * } catch (error) {
   *   console.log((error as Error).message)
   * }
   * ```
   */
  searchDrivingRoute: (options: {
    origin: Coordinate
    destination: Coordinate
    showFieldType?: AMapDrivingRouteShowFieldType
  }) => Promise<OnRouteSearchDoneResult> | undefined
  /**
   * 规划步行路线
   *
   * @param origin - 起点坐标
   * @param destination - 终点坐标
   * @param showFieldType - 显示字段配置，详见 {@link AMapWalkingRouteShowFieldType}
   * @returns 路线信息
   *
   * @example
   * ```tsx
   * try {
   *   const exampleOrigin = { latitude: 31.230545, longitude: 121.473724 }
   *   const exampleDestination = { latitude: 31.228051, longitude: 121.467568 }
   *   const result = await mapViewRef.current?.searchWalkingRoute({
   *     origin: exampleOrigin,
   *     destination: exampleDestination,
   *     showFieldType: 'polyline'
   *   })
   *   console.log('🚶 步行路线规划结果:', result)
   * } catch (error) {
   *   console.log((error as Error).message)
   * }
   * ```
   */
  searchWalkingRoute: (options: {
    origin: Coordinate
    destination: Coordinate
    showFieldType?: AMapWalkingRouteShowFieldType
  }) => Promise<OnRouteSearchDoneResult> | undefined
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ShanshuExpoMapModule>('ShanshuExpoMap')
