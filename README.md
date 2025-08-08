# shanshu-expo-amap

用于 Expo 应用的高德地图 React Native 模块，支持 iOS 和 Android。

## 功能特性

- 🗺️ 高德地图集成
- 📱 支持 iOS、Android
- ⚡ 基于 Expo 模块架构
- 🎯 TypeScript 支持

## 安装

```bash
pnpm add shanshu-expo-amap
# 或
yarn add shanshu-expo-amap
# 或
npm install shanshu-expo-amap
```

## 使用方法

### 基础用法

```tsx
import React from 'react';
import { View } from 'react-native';
import { ShanshuExpoMapView } from 'shanshu-expo-amap';

export default function App() {
  return (
    <View style={{ flex: 1 }}>
      <ShanshuExpoMapView
        style={{ flex: 1 }}
        onLoad={() => console.log('地图加载完成')}
      />
    </View>
  );
}
```

## 开发

### 环境要求

- Node.js >= 20
- Expo CLI
- React Native 开发环境

### 本地开发

```bash
# 克隆仓库
git clone https://github.com/chaochaoxiaoshu/shanshu-expo-amap.git
cd shanshu-expo-amap

# 安装依赖
pnpm install

# 构建模块
pnpm run build

# 运行示例
cd example
pnpm install
pnpx expo run:ios
pnpx expo run:android
```

## 许可证

MIT © [zhang.xin1@outlook.com](mailto:zhang.xin1@outlook.com)

## 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开 Pull Request

## 链接

- [GitHub 仓库](https://github.com/chaochaoxiaoshu/shanshu-expo-amap)
- [问题反馈](https://github.com/chaochaoxiaoshu/shanshu-expo-amap/issues)
- [高德地图开放平台](https://lbs.amap.com/)

---

如果这个项目对你有帮助，请给个 ⭐ Star！