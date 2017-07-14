//
//  NSString+FilePath.h
//  SuperStudy2
//
//  Created by xby on 2016/11/16.
//  Copyright © 2016年 wanxue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FilePath)

/**
 在Library目录下创建目录

 @param dirName 目录的名字
 @return 目录的路径
 */
+ (NSString *)dirPathInLibraryWithName:(NSString *)dirName;
/**
 在dir目录下创建目录

 @param dirName 新创建的目录的名字
 @param dir 父目录
 @return 目录路径
 */
+ (NSString *)dirPathWithName:(NSString *)dirName inDir:(NSString *)dir;
/**
 在 dir 目录下创建文件

 @param fileName 文件名
 @param dir 目录
 @return 文件路径
 */
+ (NSString *)filePathWithName:(NSString *)fileName inDir:(NSString *)dir;
@end
