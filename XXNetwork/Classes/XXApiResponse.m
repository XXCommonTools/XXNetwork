//
//  XXApiResponse.m
//  XXNetworkDemo
//
//  Created by xby on 2017/6/24.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXApiResponse.h"

@interface XXApiResponse ()

@property (assign,nonatomic,readwrite) NSInteger status;
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
/// AFN的去除 null values 的方法
- (id)removeNullValuesWithObject:(id)object readingOptions:(NSJSONReadingOptions)readingOptions {
    
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[(NSArray *)object count]];
        for (id value in (NSArray *)object) {
            
            id tempObject = [self removeNullValuesWithObject:value readingOptions:readingOptions];
            [mutableArray addObject:tempObject];
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableArray : [NSArray arrayWithArray:mutableArray];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:object];
        for (id <NSCopying> key in [(NSDictionary *)object allKeys]) {
            id value = (NSDictionary *)object[key];
            if (!value || [value isEqual:[NSNull null]]) {
                [mutableDictionary removeObjectForKey:key];
            } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                
                mutableDictionary[key] = [self removeNullValuesWithObject:value readingOptions:readingOptions];
            }
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableDictionary : [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }
    
    return object;
}

- (NSInteger)responseStatusWithError:(NSError *)error {
    if (error) {
        
        NSInteger errorCode = error.code;
        return errorCode;
        
    } else {
        
        return 0;
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
            
            //删除jsonResponseObject 中的NSNull的类型
            _jsonResponseObject = [self removeNullValuesWithObject:_jsonResponseObject readingOptions:NSJSONReadingMutableContainers];
        }
    }
    return _jsonResponseObject;
}


@end
