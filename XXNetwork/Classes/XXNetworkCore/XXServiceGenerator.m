//
//  XXServiceGenerator.m
//  XXNetworkDemo
//
//  Created by xby on 2017/6/24.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXServiceGenerator.h"

@interface XXServiceGenerator ()

@property (strong,nonatomic) NSMutableDictionary *serviceDict;

@end

@implementation XXServiceGenerator


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    static XXServiceGenerator *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XXServiceGenerator alloc] init];
    });
    return sharedInstance;
}


#pragma mark - private
- (XXService <XXServiceProtocol> *)newServiceWithIdentifier:(NSString *)serviceIdentifier {

    NSAssert([self.dataSource respondsToSelector:@selector(serviceClass)], @"请实现XXServiceGeneratorDataSource的serviceClass方法");
    NSString *classString = [[self.dataSource serviceClass] objectForKey:serviceIdentifier];
    if (classString) {
        
        id service = [[NSClassFromString(classString) alloc] init];
        
        NSAssert(service, [NSString stringWithFormat:@"无法创建service，请检查 XXServiceGeneratorDataSource 提供的数据是否正确"],service);
        NSAssert([service conformsToProtocol:@protocol(XXServiceProtocol)], @"你提供的Service没有遵循XXServiceProtocol");
        
        [self.serviceDict setObject:service forKey:serviceIdentifier];
        
        return service;
        
    } else {
    
        NSAssert(NO, @"serviceClass中无法找不到相匹配identifier");
    }
    return nil;
}
#pragma mark - public
- (XXService<XXServiceProtocol> *)serviceWithIdentifier:(NSString *)serviceIdentifier {

    NSAssert(self.dataSource, @"必须提供dataSource绑定并实现serviceClass方法，否则无法正常使用Service模块");
    XXService <XXServiceProtocol> *temp = self.serviceDict[serviceIdentifier];
    if (temp) {
        
        return temp;
        
    } else {
    
        return [self newServiceWithIdentifier:serviceIdentifier];
    }
}

#pragma mark - delegate

#pragma mark - event response

#pragma mark - getters and setters
- (NSMutableDictionary *)serviceDict {

    if (!_serviceDict) {
        
        _serviceDict = [[NSMutableDictionary alloc] init];
    }
    return _serviceDict;
}


@end
