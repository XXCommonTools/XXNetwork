//
//  XXCacheManager.h
//  XXNetworkDemo
//
//  Created by xby on 2017/7/7.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXCacheManager: NSObject

+ (instancetype)sharedInstance;

- (void)saveCacheData:(NSData *)data cacheTime:(NSTimeInterval)cacheTime serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url method:(NSString *)method params:(id)params;

- (NSData *)fetchDataWithServiceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url method:(NSString *)method params:(id)params;

- (void)deleteDataWithServiceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url method:(NSString *)method params:(id)params;
///删除所有的缓存数据
- (void)deleteAllCacheData;

@end
