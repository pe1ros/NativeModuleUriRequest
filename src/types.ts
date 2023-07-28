import type { RequestType, ResponseType } from './enums';

type BodyType = Record<string, string | number | boolean>;
type HeadersType = Record<string, string>;

export interface IGET {
  uri: string;
  type: RequestType.GET;
  headers: HeadersType;
}
export interface IPOST {
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
