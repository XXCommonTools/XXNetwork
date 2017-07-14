//
//  XXRequestGenerator.m
//  XXNetworkDemo
//
//  Created by xby on 2017/6/24.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXRequestGenerator.h"
#import "XXServiceGenerator.h"
#import "XXNetworkingConfigurationManager.h"

@interface XXRequestGenerator ()

@property (strong,nonatomic) AFJSONRequestSerializer *jsonRequestSerializer;
@property (strong,nonatomic) AFHTTPRequestSerializer *httpRequestSerializer;

@end

@implementation XXRequestGenerator


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    static XXRequestGenerator *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XXRequestGenerator alloc] init];
    });
    return sharedInstance;
}
#pragma mark - private
- (NSDictionary *)setUpFullParamsWithService:(XXService *)service url:(NSString *)url requestParam:(NSDictionary *)params {

    NSMutableDictionary *fullParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    if ([service.child respondsToSelector:@selector(setUpExtraParamsWithUrl:)]) {
        
        NSDictionary *extraParams = [service.child setUpExtraParamsWithUrl:url];
        if (extraParams) {
            
            [extraParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                
                [fullParams setObject:obj forKey:key];
            }];
        }
    }
    if ([service.child respondsToSelector:@selector(handleParams:url:)]) {
        
        return [service.child handleParams:fullParams url:url];
        
    } else {
    
        return fullParams;
    }
}
- (XXApiRequest *)generateRequestWithServiceIdentifier:(NSString *)serviceIdenetifer params:(NSDictionary *)params requestUrl:(NSString *)requestUrl requestMethod:(NSString *)method requestSerializerType:(NSInteger)requestSerializerType bodyBlock:(void(^)(id <AFMultipartFormData> formData))bodyBlock {

    XXService *service = [[XXServiceGenerator sharedInstance] serviceWithIdentifier:serviceIdenetifer];
    //拼接service提供的额外的参数
    NSDictionary *fullParams = [self setUpFullParamsWithService:service url:requestUrl requestParam:params];
    //拼接全部的url地址
    NSString *fullUrl = [service fullUrlWithRequestUrl:requestUrl];
    
    NSMutableURLRequest *request;
    if (requestSerializerType == 0) {
        
        if (bodyBlock) {
            
            request = [self.httpRequestSerializer multipartFormRequestWithMethod:method URLString:fullUrl parameters:fullParams constructingBodyWithBlock:bodyBlock error:nil];
            
        } else {
        
            request = [self.httpRequestSerializer requestWithMethod:method URLString:fullUrl parameters:fullParams error:nil];
        }
        
    } else {
    
        if (bodyBlock) {
            
            request = [self.jsonRequestSerializer multipartFormRequestWithMethod:method URLString:fullUrl parameters:fullParams constructingBodyWithBlock:bodyBlock error:nil];
            
        } else {
            
            request = [self.jsonRequestSerializer requestWithMethod:method URLString:fullUrl parameters:fullParams error:nil];
        }
    }
    if ([service.child respondsToSelector:@selector(setUpHttpHeadersWithUrl:)]) {
        
        NSDictionary *headDict = [service.child setUpHttpHeadersWithUrl:requestUrl];
        if (headDict) {
            
            [headDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
               
                [request setValue:obj forHTTPHeaderField:key];
            }];
        }
    }
    
    XXApiRequest *apiRequest = [[XXApiRequest alloc] init];
    
    apiRequest.serviceIdentifier = serviceIdenetifer;
    apiRequest.requestParams = params;
    apiRequest.finalParams = fullParams;
    apiRequest.requestMethod = method;
    apiRequest.requestSerializerType = requestSerializerType;
    apiRequest.urlRequest = request;
    
    return apiRequest;
}
#pragma mark - public
- (XXApiRequest *)generateGETRequestWithServiceIdentifier:(NSString *)serviceIdentifier params:(NSDictionary *)params requestUrl:(NSString *)requestUrl requestSerializerType:(NSInteger)type {

    return [self generateRequestWithServiceIdentifier:serviceIdentifier params:params requestUrl:requestUrl requestMethod:@"GET" requestSerializerType:type bodyBlock:nil];
}
- (XXApiRequest *)generatePOSTRequestWithServiceIdentifier:(NSString *)serviceIdentifier params:(NSDictionary *)params requestUrl:(NSString *)requestUrl requestSerializerType:(NSInteger)type bodyBlock:(void(^)(id <AFMultipartFormData> formData))bodyBlock {

    return [self generateRequestWithServiceIdentifier:serviceIdentifier params:params requestUrl:requestUrl requestMethod:@"POST" requestSerializerType:type bodyBlock:bodyBlock];
}

- (XXApiRequest *)generatePUTRequestWithServiceIdentifier:(NSString *)serviceIdentifier params:(NSDictionary *)params requestUrl:(NSString *)requestUrl requestSerializerType:(NSInteger)type {

    return [self generateRequestWithServiceIdentifier:serviceIdentifier params:params requestUrl:requestUrl requestMethod:@"PUT" requestSerializerType:type bodyBlock:nil];
}

- (XXApiRequest *)generateDELETERequestWithServiceIdentifier:(NSString *)serviceIdentifier params:(NSDictionary *)params requestUrl:(NSString *)requestUrl requestSerializerType:(NSInteger)type {

    return [self generateRequestWithServiceIdentifier:serviceIdentifier params:params requestUrl:requestUrl requestMethod:@"DELETE" requestSerializerType:type bodyBlock:nil];
}
#pragma mark - delegate

#pragma mark - event response

#pragma mark - getters and setters
- (AFHTTPRequestSerializer *)httpRequestSerializer {

    if (!_httpRequestSerializer) {
        
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.timeoutInterval = [XXNetworkingConfigurationManager sharedInstance].apiNetworkingTimeoutSeconds;
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpRequestSerializer;
}
- (AFJSONRequestSerializer *)jsonRequestSerializer {

    if (!_jsonRequestSerializer) {
        
        _jsonRequestSerializer = [AFJSONRequestSerializer serializer];
        _jsonRequestSerializer.timeoutInterval = [XXNetworkingConfigurationManager sharedInstance].apiNetworkingTimeoutSeconds;
        _jsonRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _jsonRequestSerializer;
}




@end
