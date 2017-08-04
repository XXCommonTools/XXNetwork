//
//  XXService.h
//  XXNetworkDemo
//
//  Created by xby on 2017/6/24.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXApiResponse.h"

@protocol XXServiceProtocol <NSObject>

@required;

@property (assign,nonatomic,readonly) BOOL isOnline;
@property (copy,nonatomic,readonly) NSString *onlineBaseUrl;
@property (copy,nonatomic,readonly) NSString *offlineBaseUrl;

@optional;

///拼接额外的参数,这个参数不会被验证
- (NSDictionary *)setUpExtraParamsWithUrl:(NSString *)url;
///拼接请求头
- (NSDictionary *)setUpHttpHeadersWithUrl:(NSString *)url;
///对参数做最后的处理，这里可以对参数加密做加密的操作
- (NSDictionary *)handleParams:(NSDictionary *)params url:(NSString *)url;
///对响应的数据做统一的处理，这里可以对响应的数据做解密的操作
- (XXApiResponse *)handleResponse:(XXApiResponse *)response;

@end


@interface XXService: NSObject

@property (copy,nonatomic,readonly) NSString *baseUrl;
@property (weak,nonatomic,readonly) id <XXServiceProtocol> child;

- (NSString *)fullUrlWithRequestUrl:(NSString *)requestUrl;

@end
