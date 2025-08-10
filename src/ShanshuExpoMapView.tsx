import { requireNativeView } from 'expo'
import { forwardRef, useImperativeHandle, useRef } from 'react'
import {
  ShanshuExpoMapViewProps,
  ShanshuExpoMapViewRef
} from './ShanshuExpoMap.types'

const NativeView = requireNativeView<ShanshuExpoMapViewProps>('ShanshuExpoMap')

export default forwardRef<ShanshuExpoMapViewRef, ShanshuExpoMapViewProps>(
  function ShanshuExpoMapView(props, ref) {
    const nativeRef = useRef<ShanshuExpoMapViewRef>(null)

    useImperativeHandle(
      ref,
      () => ({
        drawPolyline: (coordinates) => {
          return nativeRef.current?.drawPolyline(coordinates)
        },
        drawPolylineSegments: (segments) => {
          return nativeRef.current?.drawPolylineSegments(segments)
        },
        clearAllOverlays: () => {
          return nativeRef.current?.clearAllOverlays()
        },
        searchDrivingRoute: (options) => {
          return nativeRef.current?.searchDrivingRoute(options)
        },
        searchWalkingRoute: (options) => {
          return nativeRef.current?.searchWalkingRoute(options)
        }
      }),
      []
    )

    return <NativeView ref={nativeRef} {...props} />
  }
)
