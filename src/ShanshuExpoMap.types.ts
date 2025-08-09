import { ViewProps } from 'react-native'

/**
 * 经纬度坐标
 */
export interface Coordinate {
  /**
   * 纬度
   */
  latitude: number
  /**
   * 经度
   */
  longitude: number
}

/**
 * 地图的缩放级别的范围从3到19级，共17个级别
 */
export type ZoomLevel =
  | 3
  | 4
  | 5
  | 6
  | 7
  | 8
  | 9
  | 10
  | 11
  | 12
  | 13
  | 14
  | 15
  | 16
  | 17
  | 18
  | 19

/**
 * 地图类型
 *
 * - 0: 普通地图
 * - 1: 卫星地图
 * - 2: 夜间视图
 * - 3: 导航视图
 * - 4: 公交视图
 * - 5: 导航夜间视图
 */
export type MapType = 0 | 1 | 2 | 3 | 4 | 5

/**
 * 显示字段配置，默认为 none
 *
 * - none: 不返回扩展信息
 * - cost: 返回方案所需时间及费用成本
 * - tmcs: 返回分段路况详情
 * - navi: 返回详细导航动作指令
 * - cities: 返回分段途径城市信息
 * - polyline: 返回分段路坐标点串，两点间用“,”分隔
 * - newEnergy: 返回分段路坐标点串，两点间用“,”分隔
 * - all: 返回所有扩展信息
 */
export type AMapDrivingRouteShowFieldType =
  | 'none'
  | 'cost'
  | 'tmcs'
  | 'navi'
  | 'cities'
  | 'polyline'
  | 'newEnergy'
  | 'all'

export type AMapWalkingRouteShowFieldType =
  | 'none'
  | 'cost'
  | 'navi'
  | 'polyline'
  | 'all'

export interface AMapPath {
  distance: number
  duration: number
  stepCount: number
  polyline?: string
}

/**
 * 公交换乘信息
 */
export interface AMapTransit {
  /**
   * 此公交方案价格（单位：元）
   */
  cost: number
  /**
   * 此换乘方案预期时间（单位：秒）
   */
  duration: number
  /**
   * 是否是夜班车
   */
  nightflag: boolean
  /**
   * 此方案总步行距离（单位：米）
   */
  walkingDistance: number
  // /**
  //  * 换乘路段 AMapSegment 数组
  //  */
  // segments: any[]
  /**
   * 当前方案的总距离
   */
  distance: number
}

/**
 * 导航动作
 */
export interface AMapTransitNavi {
  action: string
  assistantAction: string
}

/**
 * 路径规划信息
 */
export interface AMapSearchObject {
  /**
   * 起点坐标
   */
  origin?: Coordinate
  /**
   * 终点坐标
   */
  destination?: Coordinate
  /**
   * 出租车费用（单位：元）
   */
  taxiCost: number
  /**
   * 步行、骑行、驾车方案列表 AMapPath 数组
   */
  paths?: AMapPath[]
  /**
   * 公交换乘方案列表 AMapTransit 数组
   */
  transits?: AMapTransit[]
  /**
   * 详细导航动作指令
   */
  transitNavi?: AMapTransitNavi
  /**
   * 分路段坐标点串，两点间用“,”分隔
   */
  polyline?: string
}

export interface OnLoadEventPayload {
  message: string
  target: number
  timestamp: number
}

export interface OnRouteSearchDoneResult {
  success: boolean
  /**
   * 路径规划信息数目
   */
  count: number
  /**
   * 路径规划信息
   */
  route: AMapSearchObject
}

export type ShanshuExpoMapModuleEvents = {
  onChange: (params: ChangeEventPayload) => void
}

export interface ChangeEventPayload {
  value: string
}

export interface ShanshuExpoMapViewRef {
  /**
   * 绘制折线
   *
   * @param coordinates - 折线坐标数组
   *
   * @example
   * ```tsx
   * const exampleCoordates = [
   *   { latitude: 31.230545, longitude: 121.473724 },
   *   { latitude: 31.228051, longitude: 121.467568 },
   *   { latitude: 31.223257, longitude: 121.471266 },
   *   { latitude: 31.227265, longitude: 121.479399 }
   * ]
   * mapViewRef.current?.drawPolyline(exampleCoordates)
   * ```
   */
  drawPolyline: (coordinates: Coordinate[]) => Promise<void> | undefined
  /**
   * 清除所有覆盖物
   *
   * @example
   * ```tsx
   * mapViewRef.current?.clearAllOverlays()
   * ```
   */
  clearAllOverlays: () => Promise<void> | undefined
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

export interface ShanshuExpoMapViewProps extends ViewProps {
  ref?: React.Ref<ShanshuExpoMapViewRef>
  /**
   * 高德地图 apiKey
   */
  apiKey: string
  /**
   * 地图平移时，缩放级别不变，可通过改变地图的中心点来移动地图
   */
  center?: Coordinate
  /**
   * 地图的缩放级别的范围从3到19级，共17个级别
   */
  zoomLevel?: ZoomLevel
  /**
   * 地图类型
   *
   * - 0: 普通地图
   * - 1: 卫星地图
   * - 2: 夜间视图
   * - 3: 导航视图
   * - 4: 公交视图
   * - 5: 导航夜间视图
   */
  mapType?: MapType
  /**
   * 地图加载成功事件
   */
  onLoad?: (event: { nativeEvent: OnLoadEventPayload }) => void
}
