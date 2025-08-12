// Reexport the native module. On web, it will be resolved to ShanshuExpoMapModule.web.ts
// and on native platforms to ShanshuExpoMapModule.ts
export { default } from './ShanshuExpoMapModule'
export { default as ShanshuExpoMapView } from './ShanshuExpoMapView'
export * from './ShanshuExpoMap.types'
