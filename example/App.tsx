import { useRef } from 'react'
import { View, Button } from 'react-native'
import {
  ShanshuExpoMapView,
  type ShanshuExpoMapViewRef
} from 'shanshu-expo-map'

const exampleCoordates = [
  { latitude: 31.230545, longitude: 121.473724 },
  { latitude: 31.228051, longitude: 121.467568 },
  { latitude: 31.223257, longitude: 121.471266 },
  { latitude: 31.227265, longitude: 121.479399 }
]

export default function App() {
  const mapViewRef = useRef<ShanshuExpoMapViewRef>(null)

  return (
    <View
      style={{ position: 'relative', width: '100%', height: '100%', flex: 1 }}
    >
      <ShanshuExpoMapView
        ref={mapViewRef}
        style={{ width: '100%', height: '100%', flex: 1 }}
        apiKey={process.env.EXPO_PUBLIC_AMAP_API_KEY}
        center={{
          latitude: 31.230545,
          longitude: 121.473724
        }}
        zoomLevel={16}
        onLoad={(event) => {
          console.log('🗺️ 地图加载成功:', event.nativeEvent)
        }}
        onRouteSearchDone={(event) => {
          console.log('🗺️ 路线规划成功:', event.nativeEvent)
        }}
      />
      <View
        style={{
          position: 'absolute',
          width: '100%',
          bottom: 0,
          left: 0,
          right: 0,
          flexDirection: 'row',
          justifyContent: 'center',
          flexWrap: 'wrap',
          paddingVertical: 32,
          paddingHorizontal: 20,
          backgroundColor: 'rgba(255, 255, 255, 0.8)'
        }}
      >
        <Button
          title='绘制折线'
          onPress={() => mapViewRef.current?.drawPolyline(exampleCoordates)}
        />
        <Button
          title='规划驾车路线'
          onPress={() => {
            mapViewRef.current?.searchDrivingRoute({
              origin: { latitude: 31.230545, longitude: 121.473724 },
              destination: { latitude: 39.900896, longitude: 116.401049 },
              showFieldType: 'polyline'
            })
          }}
        />
        <Button
          title='清除覆盖物'
          onPress={() => mapViewRef.current?.clearAllOverlays()}
        />
      </View>
    </View>
  )
}
