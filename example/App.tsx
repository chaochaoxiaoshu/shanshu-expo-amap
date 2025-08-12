import { useEffect, useRef, useState } from 'react'
import { View, Button } from 'react-native'
import ShanshuExpoMapModule, {
  Annotation,
  ShanshuExpoMapView,
  type ShanshuExpoMapViewRef
} from 'shanshu-expo-map'

const exampleAnnotationStyles = [
  {
    id: 'style1',
    image: {
      url: 'https://qiniu.zdjt.com/shop/2025-07-24/e84b870f7c916a381afe91c974243cb5.jpg',
      size: {
        width: 100,
        height: 30
      }
    },
    textStyle: {
      color: '#FF0000',
      fontSize: 20
    },
    centerOffset: { x: -50, y: -30 }
  },
  {
    id: 'style2',
    image: {
      url: 'https://qiniu.zdjt.com/shop/2025-07-11/561658b79acbc0b3c8350c75b4d3eba0.png',
      size: {
        width: 30,
        height: 30
      }
    },
    textStyle: {
      color: '#00FF00',
      fontSize: 20
    },
    centerOffset: { x: -15, y: -30 }
  }
]

const exampleAnnotations: Annotation[] = [
  {
    id: 'annotation1',
    coordinate: { latitude: 31.230545, longitude: 121.473724 },
    title: '起点',
    styleId: 'style1'
  },
  {
    id: 'annotation2',
    coordinate: { latitude: 31.223257, longitude: 121.471266 },
    title: '终点',
    styleId: 'style2'
  }
]

const examplePolylineSegments = [
  {
    coordinates: [
      { latitude: 31.230545, longitude: 121.473724 },
      { latitude: 31.228051, longitude: 121.467568 }
    ],
    style: {
      color: '#FF0000',
      width: 4,
      lineDash: false,
      is3DArrowLine: false
    }
  },
  {
    coordinates: [
      { latitude: 31.228051, longitude: 121.467568 },
      { latitude: 31.223257, longitude: 121.471266 }
    ],
    style: {
      color: '#00FF00',
      width: 6,
      lineDash: false,
      is3DArrowLine: false
    }
  },
  {
    coordinates: [
      { latitude: 31.223257, longitude: 121.471266 },
      { latitude: 31.227265, longitude: 121.479399 }
    ],
    style: {
      color: '#00FF00',
      width: 6,
      lineDash: true,
      is3DArrowLine: false
    }
  }
]

async function getLocation() {
  const location = await ShanshuExpoMapModule.requestLocation()
  console.log('location', location)
}

async function handleSearchGeocode() {
  try {
    const result = await ShanshuExpoMapModule.searchGeocode({
      address: '上海市浦东新区世纪大道 2000 号'
    })
    console.log('geocode result', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchReGeocode() {
  try {
    const result = await ShanshuExpoMapModule.searchReGeocode({
      location: '31.230545,121.473724',
      radius: 1000,
      poitype: 'bank',
      mode: 'all'
    })
    console.log('regeocode result', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchInputTips() {
  try {
    const result = await ShanshuExpoMapModule.searchInputTips({
      keywords: '方圆大厦',
      city: '024'
    })
    console.log('input tips result', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchDrivingRoute() {
  try {
    const result = await ShanshuExpoMapModule.searchDrivingRoute({
      origin: { latitude: 31.230545, longitude: 121.473724 },
      destination: { latitude: 39.900896, longitude: 116.401049 },
      showFieldType: 'polyline'
    })
    console.log('🚗 驾车路线规划结果:', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchWalkingRoute() {
  try {
    const result = await ShanshuExpoMapModule.searchWalkingRoute({
      origin: { latitude: 31.230545, longitude: 121.473724 },
      destination: { latitude: 31.223257, longitude: 121.471266 },
      showFieldType: 'polyline'
    })
    console.log('🚶 步行路线规划结果:', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchRidingRoute() {
  try {
    const result = await ShanshuExpoMapModule.searchRidingRoute({
      origin: { latitude: 31.230545, longitude: 121.473724 },
      destination: { latitude: 31.223257, longitude: 121.471266 },
      showFieldType: 'polyline'
    })
    console.log('🚲 骑行路线规划结果:', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchTransitRoute() {
  try {
    const result = await ShanshuExpoMapModule.searchTransitRoute({
      origin: { latitude: 31.230545, longitude: 121.473724 },
      destination: { latitude: 31.223257, longitude: 121.471266 },
      strategy: 0,
      city: '021',
      destinationCity: '021',
      showFieldType: 'polyline'
    })
    console.log('🚌 公交路线规划结果:', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

export default function App() {
  const mapViewRef = useRef<ShanshuExpoMapViewRef>(null)

  const [annotations, setAnnotations] = useState(exampleAnnotations)
  const [selectedAnnotationId, setSelectedAnnotationId] = useState<string>()

  return (
    <View style={{ position: 'relative', flex: 1 }}>
      <ShanshuExpoMapView
        ref={mapViewRef}
        style={{ flex: 1 }}
        mapType={0}
        showUserLocation={true}
        userTrackingMode={0}
        annotationStyles={exampleAnnotationStyles}
        annotations={annotations}
        polylineSegments={examplePolylineSegments}
        selectedAnnotationId={selectedAnnotationId}
        onLoad={(event) => {
          console.log('🗺️ 地图加载成功:', event.nativeEvent)
        }}
        onZoom={(event) => {
          console.log('🗺️ 地图缩放:', event.nativeEvent)
        }}
        onRegionChanged={(event) => {
          console.log('🗺️ 地图区域变化:', event.nativeEvent)
        }}
        onSelectAnnotation={(event) => {
          console.log('🗺️ 选中标记点:', event.nativeEvent)
          setSelectedAnnotationId(event.nativeEvent.id)
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
        <Button title='地理编码' onPress={handleSearchGeocode} />
        <Button title='逆地理编码' onPress={handleSearchReGeocode} />
        <Button title='关键字搜索' onPress={handleSearchInputTips} />
        <Button title='规划驾车路线' onPress={handleSearchDrivingRoute} />
        <Button title='规划步行路线' onPress={handleSearchWalkingRoute} />
        <Button title='规划骑行路线' onPress={handleSearchRidingRoute} />
        <Button title='规划公交路线' onPress={handleSearchTransitRoute} />
      </View>
    </View>
  )
}
