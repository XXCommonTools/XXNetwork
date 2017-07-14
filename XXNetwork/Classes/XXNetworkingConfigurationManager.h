//
//  XXNetworkingConfigurationManager.h
//  XXNetworkDemo
//
//  Created by xby on 2017/6/30.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XXNetworkingAnimationAction/XXNetworkingAnimationAction.h>

@interface XXNetworkingConfigurationManager: NSObject

+ (instancetype)sharedInstance;

@property (assign,nonatomic,readonly) BOOL isReachable;
@property (assign,nonatomic) BOOL serviceIsOnline;
@property (assign,nonatomic) NSTimeInterval apiNetworkingTimeoutSeconds;
///服务器返回数据的缓存目录，如果不设置默认为 Library/XXNetworkCacheData
@property (copy,nonatomic) NSString *cacheDir;
@property (weak,nonatomic) id <XXNetworkingAnimationAction> animator;

@end
