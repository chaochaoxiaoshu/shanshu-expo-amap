import { ExpoConfig, ConfigContext } from 'expo/config'

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'shanshu-expo-map-example',
  slug: 'shanshu-expo-map-example',
  version: '1.0.0',
  orientation: 'portrait',
  icon: './assets/icon.png',
  userInterfaceStyle: 'light',
  newArchEnabled: true,
  splash: {
    image: './assets/splash-icon.png',
    resizeMode: 'contain',
    backgroundColor: '#ffffff'
  },
  ios: {
    supportsTablet: true,
    bundleIdentifier: 'expo.modules.shanshuexpomap.example'
  },
  android: {
    adaptiveIcon: {
      foregroundImage: './assets/adaptive-icon.png',
      backgroundColor: '#ffffff'
    },
    edgeToEdgeEnabled: true,
    package: 'expo.modules.shanshuexpomap.example'
  },
  web: {
    favicon: './assets/favicon.png'
  },
  plugins: [
    [
      '../app.plugin.js',
      {
        apiKey: {
          ios: process.env.EXPO_PUBLIC_AMAP_API_KEY
        }
      }
    ]
  ]
})
