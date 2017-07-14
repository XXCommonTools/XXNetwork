//
//  NSDictionary+ToString.m
//  XXNetworkDemo
//
//  Created by xby on 2017/7/11.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import "NSDictionary+ToString.h"
#import "NSArray+ToString.h"


@implementation NSDictionary (ToString)

- (NSString *)toString {

    NSMutableArray *result = [[NSMutableArray alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if (![obj isKindOfClass:[NSString class]]) {
            
            obj = [NSString stringWithFormat:@"%@", obj];
        }
        if ([obj length] > 0) {
            
            [result addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
    }];
    NSArray *sortedResult = [result sortedArrayUsingSelector:@selector(compare:)];
    return [sortedResult toString];
}

@end
