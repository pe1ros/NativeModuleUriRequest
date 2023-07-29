import { makeRequest } from './module';
import type {
  IRequestGET,
  IRequestPOST,
  IResponseSuccess,
  IResponseError,
} from './types';
import { RequestType, ResponseType } from './enums';

export { makeRequest, RequestType, ResponseType };
export type { IRequestGET, IRequestPOST, IResponseSuccess, IResponseError };
