import { NativeModule, requireNativeModule } from 'expo'

import {
  RequestLocationResult,
  ShanshuExpoMapModuleEvents
} from './ShanshuExpoMap.types'

declare class ShanshuExpoMapModule extends NativeModule<ShanshuExpoMapModuleEvents> {
  requestLocation: () => Promise<RequestLocationResult>
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ShanshuExpoMapModule>('ShanshuExpoMap')
