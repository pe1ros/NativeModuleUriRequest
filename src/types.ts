import type { RequestType, ResponseType } from './enums';

type BodyType = Record<string, string | number | boolean>;
type HeadersType = Record<string, string>;

export interface IRequestGET {
  uri: string;
  type: RequestType.GET;
  headers: HeadersType;
}
export interface IRequestPOST {
  uri: string;
  type: RequestType.POST;
  headers: HeadersType;
  body: BodyType;
}

export interface IResponseSuccess {
  type: ResponseType.SUCCESS;
  statusCode: number;
  data: string;
}

export interface IResponseError {
  type: ResponseType.ERROR;
  statusCode: number;
  error: string;
}

export enum NativeEvents {
  ERROR_EVENT = 'ERROR_EVENT',
  MAGNETOMETER_EVENT = 'MAGNETOMETER_EVENT',
  MOTION_EVENT = 'MOTION_EVENT',
}
