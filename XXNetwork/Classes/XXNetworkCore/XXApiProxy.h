//
//  XXApiProxy.h
//  XXNetworkDemo
//
//  Created by xby on 2017/6/24.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XXRequestGenerator.h"
#import "XXApiResponse.h"

typedef void(^XXCallBack)(XXApiResponse *response);
typedef void(^ProgressBlock)(NSProgress *progress);

@interface XXApiProxy: NSObject

+ (instancetype)sharedInstance;

- (NSInteger)callGETWithParams:(NSDictionary *)params requestSerializerType:(NSInteger)requestSerializerType requestServiceIdentifier:(NSString *)requestServiceIdentifier requestUrl:(NSString *)requestUrl success:(XXCallBack)successBlock fail:(XXCallBack)failBlock;

- (NSInteger)callPOSTWithParams:(NSDictionary *)params requestSerializerType:(NSInteger)requestSerializerType requestServiceIdentifier:(NSString *)requestServiceIdentifier requestUrl:(NSString *)requestUrl bodyBlock:(void(^)(id <AFMultipartFormData>formData))bodyBlock uploadProgressBlock:(ProgressBlock)progressBlock success:(XXCallBack)successBlock fail:(XXCallBack)failBlock;

- (NSInteger)callPUTWithParams:(NSDictionary *)params requestSerializerType:(NSInteger)requestSerializerType requestServiceIdentifier:(NSString *)requestServiceIdentifier requestUrl:(NSString *)requestUrl success:(XXCallBack)successBlock fail:(XXCallBack)failBlock;

- (NSInteger)callDELETEWithParams:(NSDictionary *)params requestSerializerType:(NSInteger)requestSerializerType requestServiceIdentifier:(NSString *)requestServiceIdentifier requestUrl:(NSString *)requestUrl success:(XXCallBack)successBlock fail:(XXCallBack)failBlock;

- (void)cancelRequestWithRequestID:(NSNumber *)requestID;

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
