import {
  AndroidConfig,
  ConfigPlugin,
  withAndroidManifest,
  withInfoPlist
} from 'expo/config-plugins'

const withAMapConfig: ConfigPlugin<{ apiKey: string }> = (
  config,
  { apiKey }
) => {
  config = withInfoPlist(config, (config) => {
    const plist = config.modResults

    // 写入 apiKey
    plist['AMAP_API_KEY'] = apiKey

    // 添加 NSAppTransportSecurity 节点
    if (!plist.NSAppTransportSecurity) {
      plist.NSAppTransportSecurity = {
        NSAllowsArbitraryLoads: false,
        NSAllowsLocalNetworking: true
      }
    }

    // 添加定位权限描述
    if (!plist.NSLocationAlwaysAndWhenInUseUsageDescription) {
      plist.NSLocationAlwaysAndWhenInUseUsageDescription =
        '应用需要访问您的位置，以提供地图相关功能。'
    }
    if (!plist.NSLocationWhenInUseUsageDescription) {
      plist.NSLocationWhenInUseUsageDescription =
        '应用需要访问您的位置，以提供地图相关功能。'
    }

    return config
  })

  config = withAndroidManifest(config, (config) => {
    const mainApplication = AndroidConfig.Manifest.getMainApplicationOrThrow(
      config.modResults
    )

    AndroidConfig.Manifest.addMetaDataItemToMainApplication(
      mainApplication,
      'AMAP_API_KEY',
      apiKey
    )
    return config
  })

  return config
}

export default withAMapConfig
