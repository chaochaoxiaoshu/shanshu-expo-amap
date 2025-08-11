# shanshu-expo-amap

> ⚠️ 目前仅支持 iOS

`shanshu-expo-amap` 是一个 Expo 模块，允许你的 app 使用高德地图 iOS 与 Android SDK，集成了 `AMapFoundation`, `AMap3DMap`, `AMapSearch` 与 `AMapLocation`。

# 安装

```bash
npx expo install shanshu-expo-amap
```

# 配置

在你的 `app.json` 或 `app.config.(ts/js)` 中添加以下配置：

```json
{
  "expo": {
    "plugins": [
      [
        "shanshu-expo-amap",
        {
          "apiKey": {
            "ios": "YOUR_AMAP_API_KEY",
            "android": "YOUR_AMAP_API_KEY"
          }
        }
      ]
    ]
  }
}
```

然后执行 `npx expo prebuild` 生成原生项目。

# 使用方法

如果你正在使用 iOS 模拟器或 Android 模拟器，请确保 [已启用位置功能](https://docs.expo.dev/versions/latest/sdk/location/#enable-emulator-location)。

```tsx
import { useEffect, useRef } from 'react'
import { View, Button } from 'react-native'
import ShanshuExpoMapModule, {
  ShanshuExpoMapView,
  type ShanshuExpoMapViewRef
} from 'shanshu-expo-map'

export default function App() {
  const mapViewRef = useRef<ShanshuExpoMapViewRef>(null)

  useEffect(() => {
    try {
      mapViewRef.current?.setZoomLevel(16)
    } catch (error) {
      console.log((error as Error).message)
    }
  }, [])

  return (
    <View style={{ position: 'relative', flex: 1 }}>
      <ShanshuExpoMapView
        ref={mapViewRef}
        style={{ flex: 1 }}
        mapType={0}
        showUserLocation={true}
        userTrackingMode={0}
        annotationStyles={exampleAnnotationStyles}
        annotations={exampleAnnotations}
        polylineSegments={examplePolylineSegments}
        onLoad={(event) => {
          console.log('🗺️ 地图加载成功:', event.nativeEvent)
        }}
        onZoom={(event) => {
          console.log('🗺️ 地图缩放:', event.nativeEvent)
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
        <Button title='规划驾车路线' onPress={handleSearchDrivingRoute} />
        <Button title='规划步行路线' onPress={handleSearchWalkingRoute} />
      </View>
    </View>
  )
}
```