import { NativeModule, requireNativeModule } from 'expo';

import { ShanshuExpoMapModuleEvents } from './ShanshuExpoMap.types';

declare class ShanshuExpoMapModule extends NativeModule<ShanshuExpoMapModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ShanshuExpoMapModule>('ShanshuExpoMap');
