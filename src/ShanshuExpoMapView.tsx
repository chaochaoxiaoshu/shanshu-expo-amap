import { requireNativeView } from 'expo'
import { forwardRef, useImperativeHandle, useRef } from 'react'
import {
  ShanshuExpoMapViewProps,
  ShanshuExpoMapViewRef
} from './ShanshuExpoMap.types'

const NativeView = requireNativeView('ShanshuExpoMap') as React.ComponentType<
  ShanshuExpoMapViewProps & { ref?: React.Ref<ShanshuExpoMapViewRef> }
>

export default forwardRef<ShanshuExpoMapViewRef, ShanshuExpoMapViewProps>(
  function ShanshuExpoMapView(props, ref) {
    const nativeRef = useRef<ShanshuExpoMapViewRef>(null)

    useImperativeHandle(
      ref,
      () => ({
        drawPolyline: (coordinates) => {
          return nativeRef.current?.drawPolyline(coordinates)
        },
        clearAllOverlays: () => {
          return nativeRef.current?.clearAllOverlays()
        }
      }),
      []
    )

    return <NativeView ref={nativeRef} {...props} />
  }
)
