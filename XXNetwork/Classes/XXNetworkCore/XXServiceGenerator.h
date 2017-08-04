//
//  XXServiceGenerator.h
//  XXNetworkDemo
//
//  Created by xby on 2017/6/24.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXService.h"

@protocol XXServiceGeneratorDataSource <NSObject>

@required;
///  {"requestServiceIdentifier":"serviceClass"}
- (NSDictionary *)serviceClass;

@end

@interface XXServiceGenerator: NSObject

+ (instancetype)sharedInstance;

@property (weak,nonatomic) id <XXServiceGeneratorDataSource> dataSource;

- (XXService <XXServiceProtocol> *)serviceWithIdentifier:(NSString *)serviceIdentifier;

@end
