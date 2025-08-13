import { requireNativeView } from 'expo'
import {
  Children,
  forwardRef,
  ReactElement,
  useImperativeHandle,
  useRef
} from 'react'
import {
  Marker,
  Polyline,
  type MarkerProps,
  type PolylineProps
} from './components'
import {
  Coordinate,
  ShanshuExpoMapViewProps,
  ShanshuExpoMapViewRef,
  ZoomLevel
} from './types'

const NativeView = requireNativeView<ShanshuExpoMapViewProps>('ShanshuExpoMap')

type WrapperProps = Omit<ShanshuExpoMapViewProps, 'markers' | 'polylines'>

export default forwardRef<ShanshuExpoMapViewRef, WrapperProps>(
  function ShanshuExpoMapView(props, ref) {
    const { children, ...restProps } = props
    const markers = Children.toArray(children)
      .filter((child) => componentIs(child, Marker))
      .map((child) => child.props) as MarkerProps[]
    const polylines = Children.toArray(children)
      .filter((child) => componentIs(child, Polyline))
      .map((child) => child.props) as PolylineProps[]

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

    return (
      <NativeView
        ref={nativeRef}
        {...restProps}
        markers={markers}
        polylines={polylines}
      />
    )
  }
)

function componentIs(
  component: ReturnType<typeof Children.toArray>[number],
  type: ReactElement['type']
): component is ReactElement {
  return (
    typeof component === 'object' &&
    component !== null &&
    'type' in component &&
    component.type === type
  )
}
