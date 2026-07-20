import type { PhoenixApi } from '../electron/preload';

declare global {
  interface Window {
    phoenix: PhoenixApi;
  }
}

export {};
