import { ViewProps } from 'react-native'
import { Coordinate } from './base'

/**
 * 地图的缩放级别的范围从 3 到 20 ，共 18 个级别
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
  | 20

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
 * 折线线段样式
 */
export interface PolylineStyle {
  /**
   * 填充颜色，仅支持 hex 颜色值
   */
  fillColor?: string
  /**
   * 笔触颜色，仅支持 hex 颜色值
   */
  strokeColor?: string
  /**
   * 笔触宽度
   */
  lineWidth?: number
  /**
   * - 0: 斜面连接点
   * - 1: 斜接连接点
   * - 2: 圆角连接点
   */
  lineJoinType?: number
  /**
   * - 0: 普通头
   * - 1: 扩展头
   * - 2: 箭头
   * - 3: 圆形头
   */
  lineCapType?: number
  miterLimit?: number
  /**
   * - 0: 不画虚线
   * - 1: 方块样式
   * - 2: 圆点样式
   */
  lineDashType?: number
  /**
   * 是否抽稀，默认为YES
   */
  reducePoint?: boolean
  /**
   * 是否启用 3d 箭头样式，默认为 false
   */
  is3DArrowLine?: boolean
  /**
   * 设置为立体3d箭头的侧边颜色（当is3DArrowLine为YES时有效)顶部颜色使用strokeColor
   */
  sideColor?: string
  /**
   * 是否开启点击选中功能，默认为 false
   */
  userInteractionEnabled?: boolean
  /**
   * 用于调整点击选中热区大小，默认为0. 负值增大热区，正值减小热区
   */
  hitTestInset?: number
  /**
   * 是否启用显示范围，YES启用，不启用时展示全路径，默认为 false
   */
  showRangeEnabled?: boolean
  /**
   * 显示范围
   */
  pathShowRange?: {
    begin: number
    end: number
  }
  /**
   * 纹理图片，尺寸 64*64
   */
  textureImage?: string
}

/**
 * 折线线段
 */
export interface PolylineData {
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
  numberOfLines?: number // 限制行数，超出显示省略号
  offset?: { x: number; y: number } // 文字相对图片中心的偏移
}

/**
 * 标记点数据
 */
export interface MarkerData {
  /**
   * 用于引用此 Marker 的唯一标识
   */
  id: string
  /**
   * 标记点坐标
   */
  coordinate: Coordinate
  /**
   * 标题
   */
  title?: string
  /**
   * 副标题
   */
  subtitle?: string
  /**
   * zIndex，默认为 0
   */
  zIndex?: number
  /**
   * 标记点图像
   */
  image?: {
    url: string
    size: { width: number; height: number }
  }
  /**
   * 中心偏移量
   */
  centerOffset?: { x: number; y: number }
  /**
   * callout 偏移量
   */
  calloutOffset?: { x: number; y: number }
  /**
   * 文本偏移
   */
  textOffset?: { x: number; y: number }
  /**
   * 是否启用触摸事件
   */
  enabled?: boolean
  /**
   * 是否高亮
   */
  highlighted?: boolean
  /**
   * 是否允许弹出callout
   */
  canShowCallout?: boolean
  /**
   * 是否支持拖动
   */
  draggable?: boolean
  /**
   * 弹出默认弹出框时，是否允许地图调整到合适位置来显示弹出框，默认为 true
   */
  canAdjustPosition?: boolean
  textStyle?: TextStyle
}

export interface OnLoadEventPayload {
  message: string
  target: number
  timestamp: number
}

export interface OnZoomEventPayload {
  zoomLevel: number
}

export interface OnRegionChangedEventPayload {
  center: Coordinate
  span: {
    latitudeDelta: number
    longitudeDelta: number
  }
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

export interface ShanshuExpoMapViewProps extends ViewProps {
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
  markers?: MarkerData[]
  selectedMarkerId?: string
  polylines?: PolylineData[]
  /**
   * 地图加载成功事件
   */
  onLoad?: (event: { nativeEvent: OnLoadEventPayload }) => void
  onZoom?: (event: { nativeEvent: OnZoomEventPayload }) => void
  onRegionChanged?: (event: {
    nativeEvent: OnRegionChangedEventPayload
  }) => void
}
