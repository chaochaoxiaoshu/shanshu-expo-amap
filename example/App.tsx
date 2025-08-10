import { useRef } from 'react'
import { View, Button } from 'react-native'
import ShanshuExpoMapModule, {
  ShanshuExpoMapView,
  type ShanshuExpoMapViewRef
} from 'shanshu-expo-map'

const exampleCoordates = [
  { latitude: 31.230545, longitude: 121.473724 },
  { latitude: 31.228051, longitude: 121.467568 },
  { latitude: 31.223257, longitude: 121.471266 },
  { latitude: 31.227265, longitude: 121.479399 }
]

async function getLocation() {
  const location = await ShanshuExpoMapModule.requestLocation()
  console.log('location', location)
}

export default function App() {
  const mapViewRef = useRef<ShanshuExpoMapViewRef>(null)

  const handleDrawPolyline = () => {
    mapViewRef.current?.drawPolyline(exampleCoordates)
  }

  const handleSearchDrivingRoute = async () => {
    mapViewRef.current?.clearAllOverlays()
    try {
      const result = await mapViewRef.current?.searchDrivingRoute({
        origin: { latitude: 31.230545, longitude: 121.473724 },
        destination: { latitude: 39.900896, longitude: 116.401049 },
        showFieldType: 'polyline'
      })
      console.log('🚗 驾车路线规划结果:', result)
    } catch (error) {
      console.log((error as Error).message)
    }
  }

  const handleSearchWalkingRoute = async () => {
    mapViewRef.current?.clearAllOverlays()
    try {
      const result = await mapViewRef.current?.searchWalkingRoute({
        origin: { latitude: 31.230545, longitude: 121.473724 },
        destination: { latitude: 31.223257, longitude: 121.471266 },
        showFieldType: 'polyline'
      })
      console.log('🚶 步行路线规划结果:', result)
    } catch (error) {
      console.log((error as Error).message)
    }
  }

  const handleClearAllOverlays = () => {
    mapViewRef.current?.clearAllOverlays()
  }

  return (
    <View
      style={{ position: 'relative', width: '100%', height: '100%', flex: 1 }}
    >
      <ShanshuExpoMapView
        ref={mapViewRef}
        style={{ width: '100%', height: '100%', flex: 1 }}
        center={{
          latitude: 31.230545,
          longitude: 121.473724
        }}
        zoomLevel={16}
        mapType={0}
        onLoad={(event) => {
          console.log('🗺️ 地图加载成功:', event.nativeEvent)
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
        <Button title='获取定位' onPress={getLocation} />
        <Button title='绘制折线' onPress={handleDrawPolyline} />
        <Button title='规划驾车路线' onPress={handleSearchDrivingRoute} />
        <Button title='规划步行路线' onPress={handleSearchWalkingRoute} />
        <Button title='清除覆盖物' onPress={handleClearAllOverlays} />
      </View>
    </View>
  )
}
