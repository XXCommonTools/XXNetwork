#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "XXApiBaseManager.h"
#import "XXApiProxy.h"
#import "XXApiRequest.h"
#import "XXApiResponse.h"
#import "XXCacheManager.h"
#import "XXCacheModel.h"
#import "XXLog.h"
#import "XXNetwork.h"
#import "XXNetworkAnimation.h"
#import "XXNetworkingConfigurationManager.h"
#import "XXRequestGenerator.h"
#import "XXService.h"
#import "XXServiceGenerator.h"

FOUNDATION_EXPORT double XXNetworkVersionNumber;
FOUNDATION_EXPORT const unsigned char XXNetworkVersionString[];

