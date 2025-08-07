import { requireNativeView } from 'expo';
import * as React from 'react';

import { ShanshuExpoMapViewProps } from './ShanshuExpoMap.types';

const NativeView: React.ComponentType<ShanshuExpoMapViewProps> =
  requireNativeView('ShanshuExpoMap');

export default function ShanshuExpoMapView(props: ShanshuExpoMapViewProps) {
  return <NativeView {...props} />;
}
