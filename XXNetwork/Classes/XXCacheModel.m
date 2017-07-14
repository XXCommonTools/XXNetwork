//
//  XXCacheModel.m
//  XXNetworkDemo
//
//  Created by xby on 2017/7/7.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXCacheModel.h"

@interface XXCacheModel ()<NSCoding>

@property (strong,nonatomic,readwrite) NSDate *lastUpdateTime;
@property (assign,nonatomic,readwrite) BOOL isOutdated;
@property (assign,nonatomic,readwrite) BOOL isEmpty;
@property (assign,nonatomic,readwrite) NSTimeInterval cacheTime;


@end

@implementation XXCacheModel


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}
- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.lastUpdateTime forKey:@"lastUpdateTime"];
    [aCoder encodeBool:self.isOutdated forKey:@"isOutdated"];
    [aCoder encodeBool:self.isEmpty forKey:@"isEmpty"];
    [aCoder encodeDouble:self.cacheTime forKey:@"cacheTime"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {

    if (self = [super init]) {
        
        self.lastUpdateTime = [aDecoder decodeObjectForKey:@"lastUpdateTime"];
        self.isOutdated = [aDecoder decodeBoolForKey:@"isOutdated"];
        self.isEmpty = [aDecoder decodeBoolForKey:@"isEmpty"];
        self.cacheTime = [aDecoder decodeDoubleForKey:@"cacheTime"];
    }
    return self;
}

#pragma mark - private

#pragma mark - public
- (void)updateContent:(NSData *)content cacheTime:(NSTimeInterval)cacheTime {

    self.content = content;
    self.lastUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0];
    self.cacheTime = cacheTime;
}
#pragma mark - delegate

#pragma mark - event response

#pragma mark - getters and setters
- (BOOL)isEmpty {

    return self.content == nil;
}
- (BOOL)isOutdated {

    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    return time > self.cacheTime;
}


@end
