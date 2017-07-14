//
//  XXCacheModel.h
//  XXNetworkDemo
//
//  Created by xby on 2017/7/7.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXCacheModel: NSObject

@property (strong,nonatomic) NSData *content;
@property (strong,nonatomic,readonly) NSDate *lastUpdateTime;
@property (assign,nonatomic,readonly) BOOL isOutdated;
@property (assign,nonatomic,readonly) BOOL isEmpty;

- (void)updateContent:(NSData *)content cacheTime:(NSTimeInterval)cacheTime;

@end
