import * as React from 'react';

import { ShanshuExpoMapViewProps } from './ShanshuExpoMap.types';

export default function ShanshuExpoMapView(props: ShanshuExpoMapViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
