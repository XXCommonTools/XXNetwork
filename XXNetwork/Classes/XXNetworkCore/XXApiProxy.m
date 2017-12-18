//
//  XXApiProxy.m
//  XXNetworkDemo
//
//  Created by xby on 2017/6/24.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXApiProxy.h"

#import "XXServiceGenerator.h"
#import "XXLog.h"

@interface XXApiProxy ()

@property (strong,nonatomic) AFHTTPSessionManager *manager;
@property (strong,nonatomic) NSMutableDictionary *requestDict;

@end

@implementation XXApiProxy


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    static XXApiProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XXApiProxy alloc] init];
    });
    return sharedInstance;
}


#pragma mark - private
- (NSInteger)callApiWithRequest:(XXApiRequest *)request serviceIdentifer:(NSString *)requestServiceIdentifier uploadProgress:(ProgressBlock)uploadProgressBlock success:(XXCallBack)successBlock fail:(XXCallBack)failBlock {

    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.manager dataTaskWithRequest:request.urlRequest uploadProgress:uploadProgressBlock downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.requestDict removeObjectForKey:requestID];
        
        XXApiResponse *xxResponse = [[XXApiResponse alloc] initWithRequestId:[requestID integerValue] request:request responseData:responseObject error:error];
        
        XXApiResponse *finalResponse = xxResponse;
        XXService *service = [[XXServiceGenerator sharedInstance] serviceWithIdentifier:requestServiceIdentifier];
        
        if ([service.child respondsToSelector:@selector(handleResponse:)]) {
             
            finalResponse = [service.child handleResponse:xxResponse];
        }
        if (error) {
            
            failBlock ? failBlock(finalResponse) : nil;
            
        } else {
            
            successBlock ? successBlock(finalResponse) : nil;
        }
        [XXLog logWithRequest:request.urlRequest params:request.requestParams finalParams:request.finalParams reponseData:responseObject finalResponseData:finalResponse.responseData error:error];
    }];
    [dataTask resume];
    NSNumber *requestId = @(dataTask.taskIdentifier);
    self.requestDict[requestId] = dataTask;
    
    return dataTask.taskIdentifier;
}
#pragma mark - public
- (NSInteger)callGETWithParams:(id)params requestSerializerType:(NSInteger)requestSerializerType requestServiceIdentifier:(NSString *)requestServiceIdentifier requestUrl:(NSString *)requestUrl success:(XXCallBack)successBlock fail:(XXCallBack)failBlock {

    XXApiRequest *apiRequest = [[XXRequestGenerator sharedInstance] generateGETRequestWithServiceIdentifier:requestServiceIdentifier params:params requestUrl:requestUrl requestSerializerType:requestSerializerType];
    
    return [self callApiWithRequest:apiRequest serviceIdentifer:requestServiceIdentifier uploadProgress:nil success:successBlock fail:failBlock];
}

- (NSInteger)callPOSTWithParams:(id)params requestSerializerType:(NSInteger)requestSerializerType requestServiceIdentifier:(NSString *)requestServiceIdentifier requestUrl:(NSString *)requestUrl bodyBlock:(void(^)(id <AFMultipartFormData>formData))bodyBlock uploadProgressBlock:(ProgressBlock)progressBlock success:(XXCallBack)successBlock fail:(XXCallBack)failBlock {

    XXApiRequest *apiRequest = [[XXRequestGenerator sharedInstance] generatePOSTRequestWithServiceIdentifier:requestServiceIdentifier params:params requestUrl:requestUrl requestSerializerType:requestSerializerType bodyBlock:bodyBlock];
    
    return [self callApiWithRequest:apiRequest serviceIdentifer:requestServiceIdentifier uploadProgress:progressBlock success:successBlock fail:failBlock];
}

- (NSInteger)callPUTWithParams:(id)params requestSerializerType:(NSInteger)requestSerializerType requestServiceIdentifier:(NSString *)requestServiceIdentifier requestUrl:(NSString *)requestUrl success:(XXCallBack)successBlock fail:(XXCallBack)failBlock {

    XXApiRequest *apiRequest = [[XXRequestGenerator sharedInstance] generatePUTRequestWithServiceIdentifier:requestServiceIdentifier params:params requestUrl:requestUrl requestSerializerType:requestSerializerType];
    
    return [self callApiWithRequest:apiRequest serviceIdentifer:requestServiceIdentifier uploadProgress:nil success:successBlock fail:failBlock];
}

- (NSInteger)callDELETEWithParams:(id)params requestSerializerType:(NSInteger)requestSerializerType requestServiceIdentifier:(NSString *)requestServiceIdentifier requestUrl:(NSString *)requestUrl success:(XXCallBack)successBlock fail:(XXCallBack)failBlock {

     XXApiRequest *apiRequest = [[XXRequestGenerator sharedInstance] generateDELETERequestWithServiceIdentifier:requestServiceIdentifier params:params requestUrl:requestUrl requestSerializerType:requestSerializerType];
    
    return [self callApiWithRequest:apiRequest serviceIdentifer:requestServiceIdentifier uploadProgress:nil success:successBlock fail:failBlock];
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID {

    NSURLSessionDataTask *task = self.requestDict[requestID];
    [task cancel];
    [self.requestDict removeObjectForKey:requestID];
}
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList {

    for (NSNumber *requetId in requestIDList) {
        
        [self cancelRequestWithRequestID:requetId];
    }
}

#pragma mark - delegate

#pragma mark - event response

#pragma mark - getters and setters
- (AFHTTPSessionManager *)manager {

    if (!_manager) {
        
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _manager;
}
- (NSMutableDictionary *)requestDict {

    if (!_requestDict) {
        
        _requestDict = [[NSMutableDictionary alloc] init];
    }
    return _requestDict;
}


@end
