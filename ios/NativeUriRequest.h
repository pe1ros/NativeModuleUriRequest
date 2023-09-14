
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNNativeUriRequestSpec.h"

@interface NativeUriRequest : NSObject <NativeNativeUriRequestSpec>
#else
#import <React/RCTBridgeModule.h>

#import <CoreMotion/CoreMotion.h>
#import <React/RCTEventEmitter.h>

@interface NativeUriRequest : RCTEventEmitter <RCTBridgeModule>
@property (nonatomic, strong) CMMotionManager* manager;
@property (nonatomic, strong) CMDeviceMotionHandler motionHandler;
@property (nonatomic, strong) CMMagnetometerHandler magnitometerHandler;
#endif

@end
