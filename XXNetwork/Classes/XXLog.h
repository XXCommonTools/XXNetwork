//
//  XXLog.h
//  XXNetworkDemo
//
//  Created by xby on 2017/7/13.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXLog: NSObject

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
+ (void)logWithRequest:(NSURLRequest *)request params:(NSDictionary *)params finalParams:(NSDictionary *)finalParams reponseData:(NSData *)responseData finalResponseData:(NSData *)finalResponseData error:(NSError *)error;


@end
