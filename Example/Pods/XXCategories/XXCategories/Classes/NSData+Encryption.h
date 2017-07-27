//
//  NSData+Encryption.h
//  WanXueEDU
//
//  Created by xishangzhuang on 15/9/29.
//  Copyright © 2015年 xishangzhuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(Encryption)

/**
 AES加密

 @param key 加密的key

 @return 加密后的二进制数据
 */
- (NSData *)AES256EncryptWithKey:(NSString *)key;

/**
 解密

 @param key 解密的Key

 @return 解密后的二进制数据
 */
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
