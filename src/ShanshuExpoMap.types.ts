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
 * - 0: 不追踪用户的location更新
 * - 1: 追踪用户的location更新
 * - 2: 追踪用户的location与heading更新
 */
export type UserTrackingMode = 0 | 1 | 2

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

/**
 * 折线线段样式
 */
export interface PolylineStyle {
  /**
   * 折线颜色，仅支持 hex 颜色值
   */
  color: string
  /**
   * 折线宽度
   */
  width: number
  /**
   * 是否虚线
   */
  lineDash: boolean
  /**
   * 是否启用 3d 箭头样式
   */
  is3DArrowLine: boolean
}

/**
 * 折线线段
 */
export interface PolylineSegment {
  /**
   * 折线坐标点数组
   */
  coordinates: Coordinate[]
  /**
   * 折线样式
   */
  style: PolylineStyle
}

export interface TextStyle {
  color?: string // 文字颜色，默认白色
  fontSize?: number // 字体大小，默认16
  fontWeight?:
    | 'normal'
    | 'bold'
    | '100'
    | '200'
    | '300'
    | '400'
    | '500'
    | '600'
    | '700'
    | '800'
    | '900'
  fontFamily?: string // 字体
  lineHeight?: number // 行高
  numberOfLines?: number // 限制行数，超出显示省略号
  textAlign?: 'left' | 'center' | 'right'
  offset?: { x: number; y: number } // 文字相对图片中心的偏移
}

/**
 * 标记点样式，在原生端会根据样式配置生成对应的 AnnotationView，必须是一个常量，不可以绑定状态
 */
export interface AnnotationStyle {
  /**
   * 样式的唯一标识，用于 annotation 配置引用该样式
   */
  id: string
  /**
   * zIndex 值，大值在上，默认为0
   */
  zIndex?: number
  /**
   * 标记点显示的图片，支持以下几种格式：
   *
   * - 网络资源 URL
   * - base64 编码
   */
  image: string
  /**
   * 图片的尺寸
   */
  imageSize: {
    width: number
    height: number
  }
  /**
   * annotationView 的中心默认位于 annotation 的坐标位置，可以设置centerOffset改变view的位置，正的偏移使view朝右下方移动，负的朝左上方，单位是屏幕坐标
   */
  centerOffset: { x: number; y: number }
  /**
   * 文本样式
   */
  textStyle?: TextStyle
  /**
   * 是否监听触摸事件，默认为 true
   */
  enabled?: boolean
}

/**
 * 标记点数据，使用标记点必须先配置 `annotationStyles`，然后使用 `styleId` 引用对应的样式配置
 */
export interface Annotation<S extends string = string> {
  /**
   * 标记点的唯一标识，用于标记点的引用
   */
  key?: string
  /**
   * 标记点的坐标
   */
  coordinate: Coordinate
  /**
   * 标记点的标题
   */
  title?: string
  /**
   * 标记点的样式标识，引用 `annotationStyles` 中的样式
   */
  styleId: S
  /**
   * 是否处于选中状态，默认为 false
   */
  selected?: boolean
}

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

export interface OnZoomEventPayload {
  zoomLevel: number
  center: Coordinate
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

export interface RequestLocationResult {
  /**
   * 纬度
   */
  latitude: number
  /**
   * 经度
   */
  longitude: number
  /**
   * 逆地理编码信息
   */
  regeocode: {
    /**
     * 逆地理编码地址
     */
    formattedAddress?: string
    /**
     * 国家
     */
    country?: string
    /**
     * 省份
     */
    province?: string
    /**
     * 城市
     */
    city?: string
    /**
     * 区县
     */
    district?: string
    /**
     * 城市编码
     */
    citycode?: string
    /**
     * 区县编码
     */
    adcode?: string
    /**
     * 街道
     */
    street?: string
    /**
     * 门牌号
     */
    number?: string
    /**
     * 兴趣点名称
     */
    poiName?: string
    /**
     * 兴趣点名称
     */
    aoiName?: string
  }
}

export type ShanshuExpoMapModuleEvents = {
  onChange: (params: ChangeEventPayload) => void
}

export interface ChangeEventPayload {
  value: string
}

export interface ShanshuExpoMapViewRef {
  /**
   * 设置地图中心点
   *
   * @param center - 中心点坐标
   *
   * @example
   * ```tsx
   * const exampleCenter = { latitude: 31.230545, longitude: 121.473724 }
   * mapViewRef.current?.setCenter(exampleCenter)
   * ```
   */
  setCenter: (center: Coordinate) => Promise<void> | undefined
  /**
   * 设置地图缩放级别
   *
   * @param zoomLevel - 缩放级别
   *
   * @example
   * ```tsx
   * mapViewRef.current?.setZoomLevel(15)
   * ```
   */
  setZoomLevel: (zoomLevel: ZoomLevel) => Promise<void> | undefined
}

export interface ShanshuExpoMapViewProps<
  Styles extends readonly AnnotationStyle[] = AnnotationStyle[]
> extends ViewProps {
  ref?: React.Ref<ShanshuExpoMapViewRef>
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
   * 是否显示用户位置
   */
  showUserLocation: boolean
  /**
   * 用户位置更新模式
   *
   * - 0: 不追踪用户的location更新
   * - 1: 追踪用户的location更新
   * - 2: 追踪用户的location与heading更新
   *
   * 如果设置了 center，则地图会忽略用户位置更新
   */
  userTrackingMode: UserTrackingMode
  annotationStyles?: Styles
  annotations?: Annotation<Styles[number]['id']>[]
  polylineSegments?: PolylineSegment[]
  /**
   * 地图加载成功事件
   */
  onLoad?: (event: { nativeEvent: OnLoadEventPayload }) => void
  onZoom?: (event: { nativeEvent: OnZoomEventPayload }) => void
}
