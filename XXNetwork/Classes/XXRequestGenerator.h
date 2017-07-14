//
//  XXRequestGenerator.h
//  XXNetworkDemo
//
//  Created by xby on 2017/6/24.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "XXApiRequest.h"

@interface XXRequestGenerator: NSObject

+ (instancetype)sharedInstance;

- (XXApiRequest *)generateGETRequestWithServiceIdentifier:(NSString *)serviceIdentifier params:(NSDictionary *)params requestUrl:(NSString *)requestUrl requestSerializerType:(NSInteger)type;

- (XXApiRequest *)generatePOSTRequestWithServiceIdentifier:(NSString *)serviceIdentifier params:(NSDictionary *)params requestUrl:(NSString *)requestUrl requestSerializerType:(NSInteger)type bodyBlock:(void(^)(id <AFMultipartFormData> formData))bodyBlock;

- (XXApiRequest *)generatePUTRequestWithServiceIdentifier:(NSString *)serviceIdentifier params:(NSDictionary *)params requestUrl:(NSString *)requestUrl requestSerializerType:(NSInteger)type;

- (XXApiRequest *)generateDELETERequestWithServiceIdentifier:(NSString *)serviceIdentifier params:(NSDictionary *)params requestUrl:(NSString *)requestUrl requestSerializerType:(NSInteger)type;

@end
