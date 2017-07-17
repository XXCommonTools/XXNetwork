//
//  XXApiResponse.m
//  XXNetworkDemo
//
//  Created by xby on 2017/6/24.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXApiResponse.h"

@interface XXApiResponse ()

@property (assign,nonatomic,readwrite) XXApiResponseStatus status;
@property (copy,nonatomic,readwrite) NSString *reponseString;
@property (strong,nonatomic,readwrite) NSData *responseData;
@property (assign,nonatomic,readwrite) NSInteger requestId;
@property (strong,nonatomic,readwrite) XXApiRequest *request;
@property (strong,nonatomic,readwrite) NSError *error;
@property (assign,nonatomic,readwrite) BOOL isCache;
@property (strong,nonatomic,readwrite) id jsonResponseObject;


@end

@implementation XXApiResponse


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}

#pragma mark - private
- (XXApiResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        
        XXApiResponseStatus result = XXApiResponseStatusErrorNoNetwork;
        if (error.code == NSURLErrorTimedOut) {
            
            result = XXApiResponseStatusErrorTimeout;
        }
        return result;
        
    } else {
        
        return XXApiResponseStatusSuccess;
    }
}

#pragma mark - public
///根据服务器返回的数据创建XXApiResponse对象
- (instancetype)initWithRequestId:(NSInteger)requestId request:(XXApiRequest *)request responseData:(NSData *)responseData error:(NSError *)error {

    if (self = [super init]) {
        
        self.requestId = requestId;
        self.request = request;
        self.responseData = responseData;
        self.reponseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        self.status = [self responseStatusWithError:error];
        self.error = error;
        self.isCache = NO;
    }
    return self;
}
///根据缓存中的数据创建XXApiResponse对象
- (instancetype)initWithResponseData:(NSData *)responseData {

    if (self = [super init]) {
        
        self.responseData = responseData;
        self.reponseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        self.status = [self responseStatusWithError:nil];
        self.isCache = YES;
    }
    return self;
}


#pragma mark - delegate

#pragma mark - event response

#pragma mark - getters and setters
- (id)jsonResponseObject {

    if (!_jsonResponseObject) {
        
        if (self.responseData) {
            
            NSError *error = nil;
            _jsonResponseObject = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                
#ifdef DEBUG
                
                NSLog(@"\n响应数据:\n%@\n转json出错：\n%@\n",self.reponseString,error);
                
#endif
            }
        }
    }
    return _jsonResponseObject;
}


@end
