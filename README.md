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
import { useRef } from 'react'
import ShanshuExpoMapModule, {
  ShanshuExpoMapView,
  type ShanshuExpoMapViewRef
} from 'shanshu-expo-map'

function App() {
  const mapViewRef = useRef<ShanshuExpoMapViewRef>(null)

  return (
    <ShanshuExpoMapView
      ref={mapViewRef}
      style={{ flex: 1 }}
      zoomLevel={16}
      mapType={0}
      onLoad={(event) => {
        console.log('🗺️ 地图加载成功:', event.nativeEvent)
      }}
    />
  )
}
```