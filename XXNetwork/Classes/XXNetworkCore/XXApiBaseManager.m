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
///在调用成功之后的params字典里面，用这个key可以取出请求的参数
NSString *const kXXApiManagerRequestParams = @"kXXApiManagerRequestParams";



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
@property (strong,nonatomic) id requestParams;
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

- (void)fetchCacheDataWithId:(NSInteger)requestId params:(id)apiParams {

    [self fetchCacheDataWithParams:apiParams success:^(NSData *cacheData) {
        
        if (cacheData) {
            
            [self handleCacheDataCallBackWithData:cacheData params:apiParams];
            
        } else {
            
            [self loadDataFromNetWorkWithId:requestId params:apiParams];
        }
    }];
}
- (void)handleCacheDataCallBackWithData:(NSData *)cacheData params:(id)apiParams {
    
    XXApiResponse *response = [[XXApiResponse alloc] initWithResponseData:cacheData];
    
    id aParams = [apiParams mutableCopy];
    NSMutableDictionary *afterParams = [[NSMutableDictionary alloc] init];
    afterParams[kXXApiManagerRequestParams] = aParams;
    afterParams[kXXApiManagerRequestId] = @(-1);
    [self afterCallAPIWithParams:afterParams];
    [self requestSuccessWithReponse:response];
}
- (void)fetchCacheDataWithParams:(id)params success:(void(^)(NSData *cacheData))successBlock {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        NSString *serviceIdenfitier = self.child.requestServiceIdentifier;
        NSString *url = self.child.requestUrl;
        NSString *method = [NSString stringWithFormat:@"%zd",self.child.requestMethod];
        NSData *data = [[XXCacheManager sharedInstance] fetchDataWithServiceIdentifier:serviceIdenfitier url:url method:method params:params];
        
        [XXLog logCacheData:data url:url method:method params:params];
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (successBlock) {
                
                successBlock(data);
            }
        });
    });
}
- (void)saveCacheData:(NSData *)data cacheTime:(NSTimeInterval)cacheTime params:(id)params {

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        NSString *serviceIdenfitier = self.child.requestServiceIdentifier;
        NSString *url = self.child.requestUrl;
        NSString *method = [NSString stringWithFormat:@"%zd",self.child.requestMethod];
        [[XXCacheManager sharedInstance] saveCacheData:data cacheTime:cacheTime serviceIdentifier:serviceIdenfitier url:url method:method params:params];
    });
}
- (void)deleteCacheData:(NSData *)data params:(id)params {
    
    NSString *serviceIdenfitier = self.child.requestServiceIdentifier;
    NSString *url = self.child.requestUrl;
    NSString *method = [NSString stringWithFormat:@"%zd",self.child.requestMethod];
    
    [[XXCacheManager sharedInstance] deleteDataWithServiceIdentifier:serviceIdenfitier url:url method:method params:params];
}
- (id)setUpRequestParams {
    
    id params = [self.paramSource paramsForApiManager:self];
    if ([self.child respondsToSelector:@selector(reformParams:)]) {
        
        id dict = [self.child reformParams:params];
        params = dict;
    }
    self.requestParams = params;
    return self.requestParams;
}
- (void)loadDataFromNetWorkWithId:(NSInteger)requestId params:(id)apiParams {
    
    if ([self isReachable]) {
        
        XXApiRequestSerializerType requestType = XXApiRequestSerializerTypeHttp;
        if ([self.child respondsToSelector:@selector(requestSerializerType)]) {
            
            requestType = [self.child requestSerializerType];
        }
        AFConstructingBlock bodyBlock = nil;
        if ([self.child respondsToSelector:@selector(constructingBodyBlock)]) {
            
            bodyBlock = [self.child constructingBodyBlock];
        }
        NSString *serviceIdentifier = self.child.requestServiceIdentifier;
        NSString *requestUrl = self.child.requestUrl;
        
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
        id aParams = [apiParams mutableCopy];
        NSMutableDictionary *afterParams = [[NSMutableDictionary alloc] init];
        afterParams[kXXApiManagerRequestId] = @(requestId);
        afterParams[kXXApiManagerRequestParams] = aParams;
        [self afterCallAPIWithParams:afterParams];
        
    } else {
        
        if ([self.child respondsToSelector:@selector(shouldLoadDataFromCacheWhenNoNetwork)]) {
            
            BOOL isLocal = [self.child shouldLoadDataFromCacheWhenNoNetwork];
            if (isLocal) {
                
                [self fetchCacheDataWithParams:apiParams success:^(NSData *cacheData) {
                   
                    if (cacheData) {
                        
                        [self handleCacheDataCallBackWithData:cacheData params:apiParams];
                        
                    } else {
                        
                        [self requestFailWithResponse:nil resultType:XXApiManagerResultTypeNoNetwork];
                    }
                }];
            } else {
                
                [self requestFailWithResponse:nil resultType:XXApiManagerResultTypeNoNetwork];
            }
        } else {
            
            [self requestFailWithResponse:nil resultType:XXApiManagerResultTypeNoNetwork];
        }
    }
}
- (NSInteger)loadDataWithParams:(id)apiParams {

    NSInteger requestId = 0;
    if ([self shouldCallAPIWithParams:apiParams]) {
        
        if ([self.validator manager:self isCorrectWithParamsData:apiParams]) {
            
            [self startAnimation];
            BOOL ignoreCache = NO;
            if ([self.child respondsToSelector:@selector(shouldLoadDataFromNetWork)]) {
                
                ignoreCache = [self.child shouldLoadDataFromNetWork];
                if (ignoreCache) {
                    
                    [self loadDataFromNetWorkWithId:requestId params:apiParams];
                    return requestId;
                }
            }
            if ([self.child respondsToSelector:@selector(shouldLoadDataFromCache)]) {
                
                BOOL isLocal = [self.child shouldLoadDataFromCache];
                if (isLocal) {
                    
                    [self fetchCacheDataWithId:requestId params:apiParams];
                    
                } else {
                    
                    [self loadDataFromNetWorkWithId:requestId params:apiParams];
                }
            } else {
                
                [self loadDataFromNetWorkWithId:requestId params:apiParams];
            }
        } else {
#ifdef DEBUG
            NSLog(@"\nXXApiBaseManager请求的参数验证失败\n验证器：%@\n请求的参数：%@\n",self.validator,apiParams);
#endif
        }
    } else {
        
#ifdef DEBUG
        NSLog(@"不允许发送请求，请实现 beforeCallingApiWithParams 这个方法");
#endif
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
                
                [self saveCacheData:response.responseData cacheTime:time params:[self setUpRequestParams]];
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

- (BOOL)shouldCallAPIWithParams:(id)params {

    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforeCallingApiWithParams:)]) {
        
        return [self.interceptor manager:self beforeCallingApiWithParams:params];
        
    } else {
        
        return YES;
    }

}
- (void)afterCallAPIWithParams:(id)params {

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

    id params = [self setUpRequestParams];
    NSInteger requestIdentifier = [self loadDataWithParams:params];
    [self.requestArray addObject:@(requestIdentifier)];
    
    return requestIdentifier;
}
///重置数据
- (void)resetData {
    
    self.fetchedRawData = nil;
}
///清除该接口的缓存数据
- (void)clearCacheData {
    
    id params = [self setUpRequestParams];
    [self fetchCacheDataWithParams:params success:^(NSData *cacheData) {
       
        [self deleteCacheData:cacheData params:params];
    }];
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
