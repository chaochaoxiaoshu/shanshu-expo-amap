import ExpoModulesCore
import UIKit

enum ImageSource {
  case localName(String)  // 本地资源名，如 "marker"
  case remoteURL(URL)  // 网络图片 URL
  case base64(String)  // base64 编码
  case asset(Int)  // require 结果（由 Expo Asset 提供）
}

class ImageLoader {
  static func from(_ value: Any?, completion: @escaping (UIImage?) -> Void) {
    guard let value = value else {
      completion(nil)
      return
    }

    // // 数字 -> require(assetId)
    // if let number = value as? NSNumber {
    //   // 用 Expo Asset API 获取路径
    //   if let asset = Asset.fromModule(assetId: number.intValue) {
    //     completion(UIImage(contentsOfFile: asset.localUri.path))
    //   } else {
    //     completion(nil)
    //   }
    //   return
    // }

    // 字符串类型
    if let str = value as? String {
      // 1. data URI / base64
      if str.hasPrefix("data:image") {
        if let data = Data(base64Encoded: str.components(separatedBy: ",").last ?? "") {
          completion(UIImage(data: data))
          return
        }
      }

      // 2. http/https URL
      if str.hasPrefix("http://") || str.hasPrefix("https://") {
        if let url = URL(string: str) {
          URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
              completion(UIImage(data: data))
            } else {
              completion(nil)
            }
          }.resume()
          return
        }
      }

      // 3. 本地 bundle 资源
      if let image = UIImage(named: str) {
        completion(image)
        return
      }

      // 4. 文件路径
      if FileManager.default.fileExists(atPath: str) {
        completion(UIImage(contentsOfFile: str))
        return
      }
    }

    completion(nil)
  }

  static func loadMultiple(from values: [Any?], completion: @escaping ([UIImage?]) -> Void) {
    let group = DispatchGroup()
    var results = [UIImage?](repeating: nil, count: values.count)

    for (index, value) in values.enumerated() {
      group.enter()
      from(value) { image in
        results[index] = image
        group.leave()
      }
    }

    group.notify(queue: .main) {
      completion(results)
    }
  }
}
