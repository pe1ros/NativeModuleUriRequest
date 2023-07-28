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
        callback(@[[NSNull null], @"PLEASE PROVIDE URI"]);
    }
    if (!type) {
        callback(@[[NSNull null], @"PLEASE PROVIDE TYPE"]);
    }
    if (!incomingHeaders) {
        callback(@[[NSNull null], @"PLEASE PROVIDE HEADERS"]);
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
              NSMutableDictionary *dictionary = [NSMutableDictionary new];
                [dictionary setObject:@"SUCCESS" forKey:@"type"];
                [dictionary setObject:[NSNumber numberWithInt:(httpResponse.statusCode)] forKey:@"statusCode"];
                [dictionary setObject:dicResponse forKey:@"data"];
                callback(@[dictionary, [NSNull null]]);
          }
          else
          {
              NSMutableDictionary *dictionary = [NSMutableDictionary new];
                [dictionary setObject:@"ERROR" forKey:@"type"];
                [dictionary setObject:[NSNumber numberWithInt:(httpResponse.statusCode)] forKey:@"statusCode"];
                [dictionary setObject:error.description forKey:@"error"];
                callback(@[[NSNull null], dictionary]);
          }
        }] resume];
    } else if([type isEqualToString:@"POST"]) {
    } else {
        callback(@[[NSNull null], @"SOMETHNG WAS WRONG"]);
    }
}


@end
