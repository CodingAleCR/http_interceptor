#import "HttpInterceptorPlugin.h"
#import <http_interceptor/http_interceptor-Swift.h>

@implementation HttpInterceptorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftHttpInterceptorPlugin registerWithRegistrar:registrar];
}
@end
