//
//  XXApiBaseManager.m
//  XXNetworkDemo
//
//  Created by xby on 2017/6/22.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXApiBaseManager.h"

#import "XXApiProxy.h"
#import "XXNetworkingConfigurationManager.h"
#import "XXCacheManager.h"
#import "XXLog.h"

///在调用成功之后的params字典里面，用这个key可以取出requestID
NSString *const kXXApiManagerRequestId = @"kXXApiManagerRequestId";


#define CallApi(requestId,requestMethod) {\
__weak typeof(self) weakSelf = self;\
requestId = [[XXApiProxy sharedInstance] call##requestMethod##WithParams:apiParams requestSerializerType:requestType requestServiceIdentifier:serviceIdentifier requestUrl:requestUrl success:^(XXApiResponse *response) {\
__strong typeof(weakSelf) strongSelf = weakSelf;\
[strongSelf requestSuccessWithReponse:response];\
} fail:^(XXApiResponse *response) {\
__strong typeof(weakSelf) strongSelf = weakSelf;\
[strongSelf requestFailWithResponse:response resultType:XXApiManagerResultTypeFail];\
}];\
}


@interface XXApiBaseManager ()


@property (strong,nonatomic,readwrite) id fetchedRawData;
@property (strong,nonatomic) NSMutableArray *requestArray;
@property (assign,nonatomic,readwrite) XXApiManagerResultType resultType;
@property (assign,nonatomic,readwrite) BOOL isLoading;
@property (strong,nonatomic) XXApiResponse *response;
@property (strong,nonatomic) NSDictionary *requestParams;
///失败时的code 0 为正常   通过这个可以看到对应的头文件，NSURLError.h NSURLErrorTimedOut
@property (assign,nonatomic,readwrite) NSInteger errorCode;



@end

@implementation XXApiBaseManager


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
    [self cancelAllRequests];
    self.requestArray = nil;
}
- (instancetype)init {

    if (self = [super init]) {

        _delegate = nil;
        _validator = nil;
        _paramSource = nil;
        _fetchedRawData = nil;
        _resultType = XXApiManagerResultTypeDefault;
        
        if ([self conformsToProtocol:@protocol(XXApiManager)]) {
            
            self.child = (id <XXApiManager>)self;
            
        } else {

            self.child = (id <XXApiManager>)self;
            NSException *exception = [[NSException alloc] initWithName:@"XXApiBaseManager提示" reason:[NSString stringWithFormat:@"%@没有遵循XXApiManager协议",self.child] userInfo:nil];
            @throw exception;
        }
    }
    return self;
}

#pragma mark - private
- (BOOL)isReachable {
    
    BOOL isReachability = [XXNetworkingConfigurationManager sharedInstance].isReachable;
    
    if (!isReachability) {
        
        self.resultType = XXApiManagerResultTypeNoNetwork;
    }
    return isReachability;
}

- (NSData *)fetchCacheDataWithParams:(NSDictionary *)params {

    NSString *serviceIdenfitier = self.child.requestServiceIdentifier;
    NSString *url = self.child.requestUrl;
    NSString *method = [NSString stringWithFormat:@"%zd",self.child.requestMethod];
    NSData *data = [[XXCacheManager sharedInstance] fetchDataWithServiceIdentifier:serviceIdenfitier url:url method:method params:params];
    
    [XXLog logCacheData:data url:url method:method params:params];
    
    return data;
}
- (void)saveCacheData:(NSData *)data cacheTime:(NSTimeInterval)cacheTime {

    NSString *serviceIdenfitier = self.child.requestServiceIdentifier;
    NSString *url = self.child.requestUrl;
    NSString *method = [NSString stringWithFormat:@"%zd",self.child.requestMethod];
    [[XXCacheManager sharedInstance] saveCacheData:data cacheTime:cacheTime serviceIdentifier:serviceIdenfitier url:url method:method params:self.requestParams];
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params {

    NSInteger requestId = 0;
    XXApiRequestSerializerType requestType = XXApiRequestSerializerTypeHttp;
    if ([self.child respondsToSelector:@selector(requestSerializerType)]) {
        
        requestType = [self.child requestSerializerType];
    }
    AFConstructingBlock bodyBlock = nil;
    if ([self.child respondsToSelector:@selector(constructingBodyBlock)]) {
        
        bodyBlock = [self.child constructingBodyBlock];
    }
    NSDictionary *apiParams = params;
    if ([self.child respondsToSelector:@selector(reformParams:)]) {
        
        NSDictionary *dict = [self.child reformParams:params];
        apiParams = [[NSDictionary alloc] initWithDictionary:dict];
    }
    self.requestParams = apiParams;
    NSString *serviceIdentifier = self.child.requestServiceIdentifier;
    NSString *requestUrl = self.child.requestUrl;
    
    if ([self shouldCallAPIWithParams:apiParams]) {
        
        if ([self.validator manager:self isCorrectWithParamsData:apiParams]) {
            
            [self startAnimation];
            
            if ([self.child respondsToSelector:@selector(shouldLoadDataFromCache)]) {
                
                BOOL isLocal = [self.child shouldLoadDataFromCache];
                if (isLocal) {
                    NSData *localData = [self fetchCacheDataWithParams:apiParams];
                    if (localData) {
                        
                        XXApiResponse *response = [[XXApiResponse alloc] initWithResponseData:localData];
                        NSMutableDictionary *afterParams = [apiParams mutableCopy];
                        afterParams[kXXApiManagerRequestId] = @(-1);
                        [self afterCallAPIWithParams:afterParams];
                        [self requestSuccessWithReponse:response];
                        return -1;
                    }
                }
            }
            
            if ([self isReachable]) {
                
                self.isLoading = YES;
                switch (self.child.requestMethod) {
                        
                    case XXApiRequestMethodGET:{
                        
                        CallApi(requestId, GET);
                        break;
                    }
                    case XXApiRequestMethodPOST:{
                        
                        __weak typeof(self) weakSelf = self;
                        [[XXApiProxy sharedInstance] callPOSTWithParams:apiParams requestSerializerType:requestType requestServiceIdentifier:serviceIdentifier requestUrl:requestUrl bodyBlock:bodyBlock uploadProgressBlock:^(NSProgress *progress) {
                            
                            __strong typeof(weakSelf) strongSelf = weakSelf;
                            [strongSelf requestUploadProgress:progress];
                            
                        } success:^(XXApiResponse *response) {
                            
                            __strong typeof(weakSelf) strongSelf = weakSelf;
                            [strongSelf requestSuccessWithReponse:response];
                            
                        } fail:^(XXApiResponse *response) {
                            
                            __strong typeof(weakSelf) strongSelf = weakSelf;
                            [strongSelf requestFailWithResponse:response resultType:XXApiManagerResultTypeFail];
                            
                        }];
                        break;
                    }
                    case XXApiRequestMethodPUT:{
                        
                        CallApi(requestId, PUT);
                        break;
                    }
                    case XXApiRequestMethodDELETE:{
                        
                        CallApi(requestId, DELETE);
                        break;
                    }
                    default:
                        break;
                }
                NSMutableDictionary *afterParams = [apiParams mutableCopy];
                afterParams[kXXApiManagerRequestId] = @(requestId);
                [self afterCallAPIWithParams:afterParams];
                
            } else {
            
                if ([self.child respondsToSelector:@selector(shouldLoadDataFromCacheWhenNoNetwork)]) {
                    
                    BOOL isLocal = [self.child shouldLoadDataFromCacheWhenNoNetwork];
                    if (isLocal) {
                        
                        NSData *localData = [self fetchCacheDataWithParams:apiParams];
                        if (localData) {
                            
                            XXApiResponse *response = [[XXApiResponse alloc] initWithResponseData:localData];
                            NSMutableDictionary *afterParams = [apiParams mutableCopy];
                            afterParams[kXXApiManagerRequestId] = @(-1);
                            [self afterCallAPIWithParams:afterParams];
                            [self requestSuccessWithReponse:response];
                            return -1;
                            
                        } else {
                        
                            [self requestFailWithResponse:nil resultType:XXApiManagerResultTypeNoNetwork];
                        }
                    }
                } else {
                
                    [self requestFailWithResponse:nil resultType:XXApiManagerResultTypeNoNetwork];
                }
                NSMutableDictionary *afterParams = [apiParams mutableCopy];
                afterParams[kXXApiManagerRequestId] = @(-2);
                [self afterCallAPIWithParams:afterParams];
            }
        } else {
        
            NSException *exception = [[NSException alloc] initWithName:@"XXApiBaseManager提示" reason:[NSString stringWithFormat:@"验证器：%@验证参数：%@失败",self.validator,apiParams] userInfo:nil];
            @throw exception;
        }
    }
    
    return requestId;
}
- (void)requestSuccessWithReponse:(XXApiResponse *)response {

    [self stopAnimation];
    
    self.isLoading = NO;
    self.response = response;
    self.resultType = XXApiManagerResultTypeSuccess;
    self.errorCode = response.status;
    [self.requestArray removeObject:@(response.requestId)];
    self.fetchedRawData = [response.jsonResponseObject copy];
    
    if ([self.validator manager:self isCorrectWithCallBackData:self.fetchedRawData]) {
        
        if ([self.child respondsToSelector:@selector(cacheDataTime)]) {
            
            NSTimeInterval time = [self.child cacheDataTime];
            if (time > 0 && !response.isCache) {
                
                [self saveCacheData:response.responseData cacheTime:time];
            }
        }
        if ([self beforePerformSuccessWithResponse:response]) {
            
            if ([self.delegate respondsToSelector:@selector(managerCallApiDidSuccess:)]) {
                
                [self.delegate managerCallApiDidSuccess:self];
            }
            [self afterPerformSuccessWithResponse:response];
        }
    } else {
        
        [self requestFailWithResponse:response resultType:XXApiManagerResultTypeNoContent];
    }
}
- (void)requestFailWithResponse:(XXApiResponse *)response resultType:(XXApiManagerResultType)resultType {

    [self stopAnimation];
    
    self.isLoading = NO;
    self.response = response;
    self.resultType = resultType;
    self.errorCode = response.status;
    [self.requestArray removeObject:@(response.requestId)];
    self.fetchedRawData = [response.jsonResponseObject copy];
    
    if ([self beforePerformFailWithResponse:response]) {
        
        if ([self.delegate respondsToSelector:@selector(managerCallApiDidFailed:)]) {
            
            [self.delegate managerCallApiDidFailed:self];
        }
        [self afterPerformFailWithResponse:response];
    }
}
- (void)requestUploadProgress:(NSProgress *)progress {

    if ([self.delegate respondsToSelector:@selector(manager:uploadProgress:)]) {
        
        [self.delegate manager:self uploadProgress:progress];
    }
}

- (void)startAnimation {

    BOOL showAnimation = self.isShowLoadingAnimation;
    if (showAnimation) {
        
        NSString *showText = self.loadingText;
        UIView *showView = self.loadingView;
        //加载动画
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [[XXNetworkingConfigurationManager sharedInstance].animator showLoadingWithText:showText inView:showView];
        });
    }
}

- (void)stopAnimation {
    
    //停止动画
    BOOL showAnimation = self.isShowLoadingAnimation;
    if (showAnimation) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[XXNetworkingConfigurationManager sharedInstance].animator hideLoading];
        });
    }
}
#pragma mark - interceptor
- (BOOL)beforePerformSuccessWithResponse:(XXApiResponse *)response {

    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformSuccessWithResponse:)]) {
        
        return [self.interceptor manager:self beforePerformSuccessWithResponse:response];
        
    } else {
        
        return YES;
    }
}
- (void)afterPerformSuccessWithResponse:(XXApiResponse *)response {

    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResponse:)]) {
        
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
}

- (BOOL)beforePerformFailWithResponse:(XXApiResponse *)response {

    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)]) {
        
        return [self.interceptor manager:self beforePerformFailWithResponse:response];
        
    } else {
        
        return YES;
    }
}
- (void)afterPerformFailWithResponse:(XXApiResponse *)response {

    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResponse:)]) {
        
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params {

    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforeCallingApiWithParams:)]) {
        
        return [self.interceptor manager:self beforeCallingApiWithParams:params];
        
    } else {
        
        return YES;
    }

}
- (void)afterCallAPIWithParams:(NSDictionary *)params {

    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallingAPIWithParams:)]) {
        
        [self.interceptor manager:self afterCallingAPIWithParams:params];
    }
}

#pragma mark - public
- (id)fetchDataWithReformer:(id <XXApiManagerDataReformer>)reformer {

    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:reformData:)]) {
        
        resultData = [reformer manager:self reformData:self.fetchedRawData];
        
    } else {
        
        resultData = [self.fetchedRawData mutableCopy];
    }
    return resultData;
}
- (NSInteger)loadData {

    NSDictionary *params = [self.paramSource paramsForApiManager:self];
    NSInteger requestIdentifier = [self loadDataWithParams:params];
    [self.requestArray addObject:@(requestIdentifier)];
    
    return requestIdentifier;
}
- (void)cancelAllRequests {

    [[XXApiProxy sharedInstance] cancelRequestWithRequestIDList:self.requestArray];
    [self.requestArray removeAllObjects];
}
- (void)cancelRequestWithRequestId:(NSInteger)requestID {

    [[XXApiProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
    [self.requestArray removeObject:@(requestID)];
}

#pragma mark - delegate

#pragma mark - event response

#pragma mark - getters and setters
- (NSMutableArray *)requestArray {

    if (!_requestArray) {
        
        _requestArray = [[NSMutableArray alloc] init];
    }
    return _requestArray;
}


@end
