#import "NativeUriRequest.h"
#import "CLMManager.h"

@implementation NativeUriRequest
CMMotionManager *motionManager;
double totalMagneticField;

RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents {
    return @[
        @"ERROR_EVENT",
        @"MAGNETOMETER_EVENT",
        @"MOTION_EVENT"
    ];
}

+ (BOOL) requiresMainQueueSetup {
    return  YES;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

void _initManager(void) {
  if (!motionManager) {
      motionManager = [[CMMotionManager alloc] init];
  }
}

RCT_EXPORT_METHOD(getMagneticField) {
    _initManager();
    if (motionManager.isMagnetometerAvailable) {
        NSLog(@"AVAILABLE magnetometr");
        motionManager.magnetometerUpdateInterval = 0.1;
        motionManager.deviceMotionUpdateInterval = 0.1;
//        motionManager.showsDeviceMovementDisplay = true;
        __weak NativeUriRequest *weakself = self;
        [motionManager startMagnetometerUpdatesToQueue:(NSOperationQueue *)[NSOperationQueue currentQueue] withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
            __strong NativeUriRequest *strongSelf = weakself;
            if (error != nil) {
                [strongSelf sendEventWithName:@"ERROR_EVENT"
                  body:@{
                  @"error": error.userInfo
                }];
            }
            if (magnetometerData != nil) {
                [strongSelf sendEventWithName:@"MAGNETOMETER_EVENT"
                  body:@{
                    @"X_MAGNET": @(magnetometerData.magneticField.x),
                    @"Y_MAGNET": @(magnetometerData.magneticField.y),
                    @"Z_MAGNET": @(magnetometerData.magneticField.z)
                }];
//                totalMagneticField = magnetometerData.magneticField.x + magnetometerData.magneticField.y + magnetometerData.magneticField.z;
//                CGFloat number = [[NSNumber alloc] initWithDouble:totalMagneticField].floatValue;
//                NSLog(@"FLOAT %.2f", number / 1000);
//                [[UIScreen mainScreen] setBrightness: number / 1000];
            }
        }];
        [motionManager startDeviceMotionUpdatesToQueue:(NSOperationQueue *)[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            
                __strong NativeUriRequest *strongSelf = weakself;
                if (error != nil) {
                    [strongSelf sendEventWithName:@"ERROR_EVENT"
                      body:@{
                      @"error": error.userInfo
                    }];
                }
                if (motion != nil) {
                    [strongSelf sendEventWithName:@"MOTION_EVENT"
                      body:@{
                        @"YAW_MOTION": @(motion.attitude.yaw),
                        @"ROLL_MOTION": @(motion.attitude.roll),
                        @"PITCH_MOTION": @(motion.attitude.pitch),
                    }];
                }
        }];
    }
}

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
        }
        if (error != nil){
            [dictionary setObject:error forKey:@"error"];
        }
        return  dictionary;
}

@end
