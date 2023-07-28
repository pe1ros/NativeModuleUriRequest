
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNNativeUriRequestSpec.h"

@interface NativeUriRequest : NSObject <NativeNativeUriRequestSpec>
#else
#import <React/RCTBridgeModule.h>

@interface NativeUriRequest : NSObject <RCTBridgeModule>
#endif

@end
