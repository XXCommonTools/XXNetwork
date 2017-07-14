//
//  XXApiRequest.m
//  XXNetworkDemo
//
//  Created by xby on 2017/7/13.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXApiRequest.h"

@interface XXApiRequest ()

@property (copy,nonatomic,readwrite) NSString *requestSerializer;

@end

@implementation XXApiRequest


#pragma mark - life cycle
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}

#pragma mark - private

#pragma mark - public

#pragma mark - delegate

#pragma mark - event response

#pragma mark - getters and setters
- (void)setRequestSerializerType:(NSInteger)requestSerializerType {

    _requestSerializerType = requestSerializerType;
    if (requestSerializerType == 0) {
        
        self.requestSerializer = @"XXApiRequestSerializerTypeHttp";
        
    } else {
    
        self.requestSerializer = @"XXApiRequestSerializerTypeJson";
    }
}


@end
