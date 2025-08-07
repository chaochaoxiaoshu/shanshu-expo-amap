import { registerWebModule, NativeModule } from 'expo';

import { ShanshuExpoMapModuleEvents } from './ShanshuExpoMap.types';

class ShanshuExpoMapModule extends NativeModule<ShanshuExpoMapModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ShanshuExpoMapModule, 'ShanshuExpoMapModule');
