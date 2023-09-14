import { NativeModules, NativeEventEmitter } from 'react-native';
import type {
  IRequestGET,
  IRequestPOST,
  IResponseSuccess,
  IResponseError,
} from './types';
import { NativeEvents } from './types';

class NativeRequest {
  private static _instance: NativeRequest | null = null;
  private _module;
  private _emitter;
  private _listeners: any = {};

  static getInstance() {
    if (this._instance === null) {
      this._instance = new NativeRequest();
    }
    return this._instance;
  }

  private constructor() {
    this._module = NativeModules.NativeUriRequest;
    this._emitter = new NativeEventEmitter(this._module);
    this._emitter.addListener('ERROR_EVENT', this._errorEvent.bind(this));
    this._emitter.addListener(
      'MAGNETOMETER_EVENT',
      this._magnetometerEvent.bind(this)
    );
    this._emitter.addListener('MOTION_EVENT', this._motionEvent.bind(this));
  }

  getMagneticField() {
    return this._module.getMagneticField();
  }

  async makeRequest(
    params: IRequestGET | IRequestPOST
  ): Promise<IResponseSuccess | IResponseError> {
    return new Promise((resolve, reject) => {
      this._module.makeRequest(
        params,
        (success: IResponseSuccess, error: IResponseError) => {
          if (success) {
            resolve(success);
          } else {
            reject(error);
          }
        }
      );
    });
  }

  on(event: NativeEvents, handler: Function) {
    if (!handler || !(handler instanceof Function)) {
      console.warn(`Module: on: handler is not a Function`);
      return;
    }
    if (Object.values(NativeEvents).indexOf(event) === -1) {
      console.warn(`Module: on: NativeEvents does not contain ${event} event`);
      return;
    }
    if (!this._listeners[event]) {
      this._listeners[event] = new Set();
    }
    this._listeners[event].add(handler);
  }

  off(event: NativeEvents, handler: Function) {
    if (!this._listeners[event]) {
      return;
    }
    if (Object.values(NativeEvents).indexOf(event) === -1) {
      console.warn(`Module: off: NativeEvents does not contain ${event} event`);
      return;
    }
    if (handler && handler instanceof Function) {
      this._listeners[event].delete(handler);
    } else {
      this._listeners[event] = new Set();
    }
  }

  private _emit(event: string, ...args: any) {
    const handlers = this._listeners[event];
    if (handlers) {
      for (const handler of handlers) {
        console.log(`Module: emit event ${event}`);
        handler(...args);
      }
    } else {
      console.log(`Module: emit: no handlers for event: ${event}`);
    }
  }

  private _errorEvent(event: any) {
    this._emit(NativeEvents.ERROR_EVENT, event);
  }

  private _magnetometerEvent(event: any) {
    this._emit(NativeEvents.MAGNETOMETER_EVENT, event);
  }

  private _motionEvent(event: any) {
    this._emit(NativeEvents.MOTION_EVENT, event);
  }
}

export default NativeRequest;
