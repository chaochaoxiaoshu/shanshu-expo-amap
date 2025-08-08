import { ViewProps } from 'react-native'

export type Coordinate = {
  latitude: number
  longitude: number
}

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

export type OnLoadEventPayload = {}

export type ShanshuExpoMapModuleEvents = {
  onChange: (params: ChangeEventPayload) => void
}

export type ChangeEventPayload = {
  value: string
}

export interface ShanshuExpoMapViewRef {
  /**
   * 绘制折线
   *
   * @param coordinates - 折线坐标数组
   * @returns - 绘制成功返回 true，否则返回 false
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
  drawPolyline: (coordinates: Coordinate[]) => Promise<boolean> | undefined
  /**
   * 清除所有覆盖物
   *
   * @returns - 清除成功返回 true，否则返回 false
   *
   * @example
   * ```tsx
   * mapViewRef.current?.clearAllOverlays()
   * ```
   */
  clearAllOverlays: () => Promise<boolean> | undefined
}

export type ShanshuExpoMapViewProps = {
  apiKey: string
  center?: Coordinate
  zoomLevel?: ZoomLevel
  onLoad?: (event: { nativeEvent: OnLoadEventPayload }) => void
} & ViewProps
