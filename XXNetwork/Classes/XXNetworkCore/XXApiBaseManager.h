//
//  XXApiBaseManager.h
//  XXNetworkDemo
//
//  Created by xby on 2017/6/22.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XXApiResponse.h"
#import <AFNetworking/AFNetworking.h>


typedef enum : NSUInteger {
    XXApiRequestMethodGET,
    XXApiRequestMethodPOST,
    XXApiRequestMethodPUT,
    XXApiRequestMethodDELETE
} XXApiRequestMethod;

typedef enum : NSUInteger {
    
    XXApiRequestSerializerTypeHttp,
    XXApiRequestSerializerTypeJson,
    
} XXApiRequestSerializerType;

typedef enum : NSUInteger {
    
    ///没有产生api请求，这个是manager的默认状态。
    XXApiManagerResultTypeDefault,
    ///API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    XXApiManagerResultTypeSuccess,
    ///API请求失败，进入失败的回调，详细失败的原因可以见 errorCode
    XXApiManagerResultTypeFail,
    ///API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    XXApiManagerResultTypeNoContent,
     ///网络不通,在调用API之前会判断一下当前网络是否通畅,没有网络就是这个状态。
    XXApiManagerResultTypeNoNetwork
    
} XXApiManagerResultType;

///在调用成功之后的params字典里面，用这个key可以取出requestID
extern NSString *const kXXApiManagerRequestId;



@protocol AFMultipartFormData;

typedef void(^AFConstructingBlock)(id<AFMultipartFormData> formData);




@class XXApiBaseManager;

@protocol XXApiManagerCallBackDelegate <NSObject>

@required;
///成功的回调
- (void)managerCallApiDidSuccess:(XXApiBaseManager *)manager;
///失败的回调
- (void)managerCallApiDidFailed:(XXApiBaseManager *)manager;
@optional;
///上传数据进度的回调
- (void)manager:(XXApiBaseManager *)manager uploadProgress:(NSProgress *)progress;

@end

@protocol XXApiManagerParamSource <NSObject>

@required;

- (NSDictionary *)paramsForApiManager:(XXApiBaseManager *)manager;

@end

@protocol XXApiManager <NSObject>

@required

///请求的地址不用带主机域名，主机域名在service里面
- (NSString *)requestUrl;
///请求的service的标识符
- (NSString *)requestServiceIdentifier;
///请求的方法 GET/POST/PUT/DELETE
- (XXApiRequestMethod)requestMethod;

@optional;
///默认是http的请求序列化
- (XXApiRequestSerializerType)requestSerializerType;
///拼接formData
- (AFConstructingBlock)constructingBodyBlock;
///在调用API之前额外添加一些参数,但不应该在这个函数里面修改已有的参数
- (NSDictionary *)reformParams:(NSDictionary *)params;
///返回YES则先从网络抓取数据，如果 cacheDataTime > 0 则更新本地数据
- (BOOL)shouldLoadDataFromNetWork;
///返回YES则先从本地抓取数据，如果本地有数据则不发送网络请求，如果本地没有则发送网络请求
- (BOOL)shouldLoadDataFromCache;
///返回YES则表示没有网络时则先从本地抓取数据，如果本地没有则请求失败
- (BOOL)shouldLoadDataFromCacheWhenNoNetwork;
///将数据保存到本地的时间单位秒,如果为0 则不保存
- (NSTimeInterval)cacheDataTime;

@end

@protocol XXApiManagerInterceptor <NSObject>

@optional;

- (BOOL)manager:(XXApiBaseManager *)manager beforePerformSuccessWithResponse:(XXApiResponse *)response;
- (void)manager:(XXApiBaseManager *)manager afterPerformSuccessWithResponse:(XXApiResponse *)response;

- (BOOL)manager:(XXApiBaseManager *)manager beforePerformFailWithResponse:(XXApiResponse *)response;
- (void)manager:(XXApiBaseManager *)manager afterPerformFailWithResponse:(XXApiResponse *)response;

///调用api之前的拦截器 返回YES调用api 返回NO 不调用api
- (BOOL)manager:(XXApiBaseManager *)manager beforeCallingApiWithParams:(NSDictionary *)params;
///调用api之后的拦截器
- (void)manager:(XXApiBaseManager *)manager afterCallingAPIWithParams:(NSDictionary *)params;


@end

@protocol XXApiManagerValidator <NSObject>

@required;

///验证回调的数据是否正确
- (BOOL)manager:(XXApiBaseManager *)manager isCorrectWithCallBackData:(id)data;
///验证请求的参数是否正确
- (BOOL)manager:(XXApiBaseManager *)manager isCorrectWithParamsData:(NSDictionary *)data;

@end

@protocol XXApiManagerDataReformer <NSObject>

@required;
///对回来的数据进行格式化
- (id)manager:(XXApiBaseManager *)manager reformData:(id)data;

@end

@interface XXApiBaseManager: NSObject

@property (weak,nonatomic) id <XXApiManagerCallBackDelegate> delegate;
@property (weak,nonatomic) id <XXApiManagerParamSource> paramSource;
@property (weak,nonatomic) NSObject <XXApiManager> *child;
@property (weak,nonatomic) id <XXApiManagerInterceptor> interceptor;
@property (weak,nonatomic) id <XXApiManagerValidator> validator;
@property (assign,nonatomic,readonly) XXApiManagerResultType resultType;
///失败时的code 0 为正常   通过这个可以看到对应的头文件，NSURLError.h NSURLErrorTimedOut
@property (assign,nonatomic,readonly) NSInteger errorCode;
@property (assign,nonatomic,readonly) BOOL isReachable;
@property (assign,nonatomic,readonly) BOOL isLoading;

/// loading Animation setting

///是否显示加载动画,如果设置YES，则需要赋值XXNetworkingConfigurationManager的animator这个属性
@property (assign,nonatomic) BOOL isShowLoadingAnimation;
/// 显示遮罩上面的文字
@property (copy,nonatomic) NSString *loadingText;
/// 遮罩显示的视图如果为nil则显示在window上
@property (weak,nonatomic) UIView *loadingView;

///发请求获取数据
- (NSInteger)loadData;
///重置数据
- (void)resetData;
- (void)cancelAllRequests;
- (void)cancelRequestWithRequestId:(NSInteger)requestID;
///清除该接口的缓存数据
- (void)clearCacheData;

///通过这个方法获取改造后的数据
- (id)fetchDataWithReformer:(id <XXApiManagerDataReformer>)reformer;

///以下是内部拦截器方法，继承之后需要调用一下super
- (BOOL)beforePerformSuccessWithResponse:(XXApiResponse *)response;
- (void)afterPerformSuccessWithResponse:(XXApiResponse *)response;

- (BOOL)beforePerformFailWithResponse:(XXApiResponse *)response;
- (void)afterPerformFailWithResponse:(XXApiResponse *)response;

- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params;
- (void)afterCallAPIWithParams:(NSDictionary *)params;

///这两个方法只是为了在宏里面可以调用，子类不需要调用这两个方法
- (void)requestSuccessWithReponse:(XXApiResponse *)response;
- (void)requestFailWithResponse:(XXApiResponse *)response resultType:(XXApiManagerResultType)resultType;

@end
