//
//  XXApiRequest.h
//  XXNetworkDemo
//
//  Created by xby on 2017/7/13.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXApiRequest: NSObject

@property (copy,nonatomic) NSString *serviceIdentifier;
@property (strong,nonatomic) id requestParams;
@property (strong,nonatomic) id finalParams;
@property (copy,nonatomic) NSString *requestMethod;
@property (copy,nonatomic,readonly) NSString *requestSerializer;
@property (strong,nonatomic) NSURLRequest *urlRequest;
@property (assign,nonatomic) NSInteger requestSerializerType;


@end
