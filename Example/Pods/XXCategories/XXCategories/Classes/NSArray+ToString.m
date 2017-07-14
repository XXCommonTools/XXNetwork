//
//  NSArray+ToString.m
//  XXNetworkDemo
//
//  Created by xby on 2017/7/11.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import "NSArray+ToString.h"

@implementation NSArray (ToString)

- (NSString *)toString {

    NSMutableString *paramString = [[NSMutableString alloc] init];    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([paramString length] == 0) {
            
            [paramString appendFormat:@"%@", obj];
            
        } else {
            
            [paramString appendFormat:@"&%@", obj];
        }
    }];
    
    return paramString;
}

@end
