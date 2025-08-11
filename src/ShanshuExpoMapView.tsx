import { requireNativeView } from 'expo'
import { forwardRef, useImperativeHandle, useRef } from 'react'
import {
  Coordinate,
  ShanshuExpoMapViewProps,
  ShanshuExpoMapViewRef,
  ZoomLevel
} from './ShanshuExpoMap.types'

const NativeView = requireNativeView<ShanshuExpoMapViewProps>('ShanshuExpoMap')

export default forwardRef<ShanshuExpoMapViewRef, ShanshuExpoMapViewProps>(
  function ShanshuExpoMapView(props, ref) {
    const nativeRef = useRef<ShanshuExpoMapViewRef>(null)

    useImperativeHandle(
      ref,
      () => ({
        setCenter: (center: Coordinate) => {
          return nativeRef.current?.setCenter(center)
        },
        setZoomLevel: (zoomLevel: ZoomLevel) => {
          return nativeRef.current?.setZoomLevel(zoomLevel)
        }
      }),
      []
    )

    return <NativeView ref={nativeRef} {...props} />
  }
)
