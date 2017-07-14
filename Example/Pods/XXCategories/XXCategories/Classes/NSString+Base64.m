//
//  NSString+Base64.m
//  XXNetworkDemo
//
//  Created by xby on 2017/7/11.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import "NSString+Base64.h"

@implementation NSString (Base64)

- (NSString *)base64String {

    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str  = [data base64EncodedStringWithOptions:kNilOptions];
    
    return str;
}

@end
