#import "NativeUriRequest.h"

@implementation NativeUriRequest
RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(makeRequest, makeRequestWithParams:(NSDictionary *)params
                 responseCallback:(RCTResponseSenderBlock)callback)
{
    NSString *url = [params objectForKey:@"uri"];
    NSString *type = [params objectForKey:@"type"];
    NSDictionary *incomingHeaders  = [params objectForKey:@"headers"];
    if (!url) {
        callback(@[[NSNull null], [self convertResultToDictionary:@"ERROR" :[NSNumber numberWithInt:(501)] :nil :@"PLEASE PROVIDE URI"]]);
        return;
    }
    if (!type) {
        callback(@[[NSNull null], [self convertResultToDictionary:@"ERROR" :[NSNumber numberWithInt:(501)] :nil :@"PLEASE PROVIDE TYPE"]]);
        return;
    }
    if (!incomingHeaders) {
        callback(@[[NSNull null], [self convertResultToDictionary:@"ERROR" :[NSNumber numberWithInt:(501)] :nil :@"PLEASE PROVIDE HEADERS"]]);
        return;
    }
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    for (NSString *someKey in incomingHeaders) {
        [urlRequest setValue:incomingHeaders[someKey] forHTTPHeaderField:someKey];
    }
    if([type isEqualToString:@"GET"]) {
        [[session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (data.length > 0 && error == nil)
          {
              NSDictionary *dicResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
              callback(@[[self convertResultToDictionary:@"SUCCESS" :[NSNumber numberWithInt:(httpResponse.statusCode)]  :dicResponse :nil], [NSNull null]]);
              return;
          }
          else
          {
              callback(@[[NSNull null], [self convertResultToDictionary:@"ERROR" :[NSNumber numberWithInt:(httpResponse.statusCode)]  :nil :error.description]]);
              return;
          }
        }] resume];
    } else if([type isEqualToString:@"POST"]) {
        NSError *errorSerialize;
        [urlRequest setHTTPMethod:@"POST"];
        if (![params objectForKey:@"body"]) {
            callback(@[[NSNull null], [self convertResultToDictionary:@"ERROR" :[NSNumber numberWithInt:(501)]  :nil :@"PLEASE PROVIDE BODY FOR POST REQUEST"]]);
            return;
        }
        NSData *postData = [NSJSONSerialization dataWithJSONObject:[params objectForKey:@"body"] options:0 error:&errorSerialize];
        [urlRequest setHTTPBody:postData];
        [[session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (data.length > 0 && error == nil)
          {
              NSDictionary *dicResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
              callback(@[[self convertResultToDictionary:@"SUCCESS" :[NSNumber numberWithInt:(httpResponse.statusCode)]  :dicResponse :nil], [NSNull null]]);
              return;
          }
          else
          {
              callback(@[[NSNull null], [self convertResultToDictionary:@"ERROR" :[NSNumber numberWithInt:(httpResponse.statusCode)]  :nil :error.description]]);
              return;
          }
        }] resume];
    } else {
        callback(@[[NSNull null], [self convertResultToDictionary:@"ERROR" :@(500) :nil :@"SOMETHING WAS WRONG"]]);
    }
}

- (NSDictionary *)convertResultToDictionary:(NSString *)type
                                            :(NSNumber *)statusCode
                                            :(NSDictionary * _Nullable)data
                                            :(NSString * _Nullable)error {
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
          [dictionary setObject:type forKey:@"type"];
          [dictionary setObject:statusCode forKey:@"statusCode"];
        if(data != nil) {
            [dictionary setObject:data forKey:@"data"];
        }   else {
            [dictionary setObject:error forKey:@"error"];
        }
        return  dictionary;
}

@end
