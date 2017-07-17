//
//  XXLog.m
//  XXNetworkDemo
//
//  Created by xby on 2017/7/13.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXLog.h"

@interface XXLog ()

@end

@implementation XXLog


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
    
}

#pragma mark - private

#pragma mark - public
/*
 #请求头
 #请求方式
 #请求地址
 #请求体
 #加密前的请求参数（json格式）
 #加密后的请求参数（json格式）
 #服务器返回的数据解密前（json格式）
 #服务器返回的数据解密后（json格式）
 #错误信息
 */
+ (void)logWithRequest:(NSURLRequest *)request params:(NSDictionary *)params finalParams:(NSDictionary *)finalParams reponseData:(NSData *)responseData finalResponseData:(NSData *)finalResponseData error:(NSError *)error {

#ifdef DEBUG
    
    NSMutableString *string = [[NSMutableString alloc] init];
    
    [string appendString:@"\n\n==============================================================\n=                        Resquest Infor                      =\n==============================================================\n\n"];
    
    NSDictionary *httpHeades = request.allHTTPHeaderFields;
    NSData *headData = [NSJSONSerialization dataWithJSONObject:httpHeades options:NSJSONWritingPrettyPrinted error:nil];
    NSString *headString = [[NSString alloc] initWithData:headData encoding:NSUTF8StringEncoding];
    
    [string appendFormat:@"\n\nRequest Header:\n%@",headString];
    [string appendFormat:@"\n\nRequest Method:\n%@",request.HTTPMethod];
    [string appendFormat:@"\n\nRequest Url:\n%@",request.URL];
    if (params) {
        
        NSData *requestParamsData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        NSString *requestParamsString = [[NSString alloc] initWithData:requestParamsData encoding:NSUTF8StringEncoding];
        
        [string appendFormat:@"\n\nRequest Params:\n%@",requestParamsString];
    }
    if (![finalParams isEqualToDictionary:params]) {
        
        NSData *finalParamsData = [NSJSONSerialization dataWithJSONObject:finalParams options:NSJSONWritingPrettyPrinted error:nil];
        NSString *finalParamsString = [[NSString alloc] initWithData:finalParamsData encoding:NSUTF8StringEncoding];
        [string appendFormat:@"\n\nRequest FinalParams:\n%@",finalParamsString];
    }
    NSString *httpBody = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    [string appendFormat:@"\n\nRequest Body:\n%@",httpBody];
    if (responseData) {
        
        NSString *reponseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        [string appendString:@"\n\n==============================================================\n=                        Response Result                     =\n==============================================================\n\n"];
        [string appendFormat:@"\n\nResponse String:\n\n%@",reponseString];
    }
    if (![finalResponseData isEqualToData:responseData]) {
        
        NSString *finalResponseString = [[NSString alloc] initWithData:finalResponseData encoding:NSUTF8StringEncoding];
        [string appendFormat:@"\n\nFinal Response String:\n\n%@",finalResponseString];
    }
    if (error) {
        
        [string appendString:@"\n\n==============================================================\n=                        Error Infor                         =\n==============================================================\n\n"];
        [string appendFormat:@"\n\nError LocalInfor:\n%@",error.localizedDescription];
        [string appendFormat:@"\n\nError:\n%@",error];
    }
    
    NSLog(@"\n\n\n\n%@\n\n\n\n",string);
#endif
}
/**
 缓存信息的日志
 
 @param data 缓存的数据
 @param url 请求的url
 @param method 请求的方式
 @param params 请求的参数
 */
+ (void)logCacheData:(NSData *)data url:(NSString *)url method:(NSString *)method params:(NSDictionary *)params {

#ifdef DEBUG
    
    NSMutableString *string = [[NSMutableString alloc] init];
    
    [string appendString:@"\n\n==============================================================\n=                        Cache Log                           =\n==============================================================\n\n"];
    
    [string appendString:@"\n\n==============================================================\n=                        Resquest Infor                      =\n==============================================================\n\n"];
    
    [string appendFormat:@"\n\nRequest Method:\n%@",method];
    [string appendFormat:@"\n\nRequest Url:\n%@",url];
    if (params) {
        
        NSData *requestParamsData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        NSString *requestParamsString = [[NSString alloc] initWithData:requestParamsData encoding:NSUTF8StringEncoding];
        
        [string appendFormat:@"\n\nRequest Params:\n%@",requestParamsString];
    }
    if (data) {
        
        NSString *reponseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [string appendString:@"\n\n==============================================================\n=                        Response Result                     =\n==============================================================\n\n"];
        [string appendFormat:@"\n\nResponse String:\n\n%@",reponseString];
    }
    
    NSLog(@"\n\n\n\n%@\n\n\n\n",string);
#endif
}

#pragma mark - delegate

#pragma mark - event response

#pragma mark - getters and setters



@end
