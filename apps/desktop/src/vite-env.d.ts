import type { PhoenixApi } from '../electron/preload';

export type DesktopPhoenixApi = PhoenixApi;

declare global {
  interface Window {
    phoenix: DesktopPhoenixApi;
  }
}

export {};
