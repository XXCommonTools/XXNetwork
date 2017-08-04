//
//  XXService.m
//  XXNetworkDemo
//
//  Created by xby on 2017/6/24.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXService.h"

@interface XXService ()

@property (copy,nonatomic,readwrite) NSString *baseUrl;
@property (weak,nonatomic,readwrite) id <XXServiceProtocol> child;

@end

@implementation XXService


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}
- (instancetype)init {

    if (self = [super init]) {
        
        if ([self conformsToProtocol:@protocol(XXServiceProtocol)]) {
            
            self.child = (id <XXServiceProtocol>) self;
            
        } else {
        
            NSException *exception = [[NSException alloc] initWithName:@"XXService提示" reason:[NSString stringWithFormat:@"%@没有遵循XXServiceProtocol协议",self.child] userInfo:nil];
            @throw exception;
        }
    }
    return self;
}

#pragma mark - private

#pragma mark - public
- (NSString *)fullUrlWithRequestUrl:(NSString *)requestUrl {

    NSString *fullUrl = [NSString stringWithFormat:@"%@%@",self.baseUrl,requestUrl];
    return fullUrl;
}
#pragma mark - delegate

#pragma mark - event response

#pragma mark - getters and setters
- (NSString *)baseUrl {

    return self.child.isOnline ? self.child.onlineBaseUrl : self.child.offlineBaseUrl;
}


@end
