//
//  XXApiResponse.h
//  XXNetworkDemo
//
//  Created by xby on 2017/6/24.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXApiRequest.h"

typedef enum : NSUInteger {
    XXApiResponseStatusSuccess,
    XXApiResponseStatusErrorTimeout,
    XXApiResponseStatusErrorNoNetwork,
} XXApiResponseStatus;


//响应对象
@interface XXApiResponse: NSObject

@property (assign,nonatomic,readonly) XXApiResponseStatus status;
@property (copy,nonatomic,readonly) NSString *reponseString;
@property (strong,nonatomic,readonly) NSData *responseData;
@property (assign,nonatomic,readonly) NSInteger requestId;
@property (strong,nonatomic,readonly) XXApiRequest *request;
@property (strong,nonatomic,readonly) NSError *error;
@property (assign,nonatomic,readonly) BOOL isCache;
@property (strong,nonatomic,readonly) id jsonResponseObject;

///根据服务器返回的数据创建XXApiResponse对象
- (instancetype)initWithRequestId:(NSInteger)requestId request:(XXApiRequest *)request responseData:(NSData *)responseData error:(NSError *)error;
///根据缓存中的数据创建XXApiResponse对象
- (instancetype)initWithResponseData:(NSData *)responseData;

@end
