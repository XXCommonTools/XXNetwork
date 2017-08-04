//
//  XXNetworkingConfigurationManager.m
//  XXNetworkDemo
//
//  Created by xby on 2017/6/30.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXNetworkingConfigurationManager.h"
#import <AFNetworking/AFNetworking.h>

@interface XXNetworkingConfigurationManager ()

@end

@implementation XXNetworkingConfigurationManager


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}

+ (instancetype)sharedInstance {
    
    static XXNetworkingConfigurationManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XXNetworkingConfigurationManager alloc] init];
        sharedInstance.serviceIsOnline = NO;
        sharedInstance.apiNetworkingTimeoutSeconds = 20.0f;
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    return sharedInstance;
}

#pragma mark - private

#pragma mark - public

#pragma mark - delegate

#pragma mark - event response

#pragma mark - getters and setters
- (void)setCacheDir:(NSString *)cacheDir {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:cacheDir isDirectory:&isDir] && isDir) {
        
        _cacheDir = cacheDir;
        
    } else {
    
        NSException *exception = [[NSException alloc] initWithName:@"XXService提示" reason:[NSString stringWithFormat:@"%@这个不是一个目录",cacheDir] userInfo:nil];
        @throw exception;
    }
}
- (BOOL)isReachable {
    
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        
        return YES;
        
    } else {
        
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}





@end
