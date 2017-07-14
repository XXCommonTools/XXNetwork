//
//  NSString+FilePath.m
//  SuperStudy2
//
//  Created by xby on 2016/11/16.
//  Copyright © 2016年 wanxue. All rights reserved.
//

#import "NSString+FilePath.h"

@implementation NSString (FilePath)

#pragma mark - public

+ (NSString *)dirPathInLibraryWithName:(NSString *)dirName {

    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    
    NSString *dirPath = [libraryPath stringByAppendingFormat:@"/%@",dirName];
    
    NSString *lastPath = [self createPath:dirPath];
    
    return lastPath;

    
}
+ (NSString *)dirPathWithName:(NSString *)dirName inDir:(NSString *)dir {

    NSString *dirPath = [dir stringByAppendingFormat:@"/%@",dirName];
    
    NSString *lastPath = [self createPath:dirPath];
    
    return lastPath;

}

+ (NSString *)filePathWithName:(NSString *)fileName inDir:(NSString *)dir {

    NSString *fullPath = [dir stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fullPath]) {
        
        [fileManager createFileAtPath:fullPath contents:nil attributes:nil];
#ifdef DEBUG
        NSLog(@"创建文件成功：%@",fullPath);
#endif
    }
    return fullPath;
}

#pragma mark - private
+ (NSString *)createPath:(NSString *)path {
    
    NSString *lastPath = path;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:path]) {
        //目录不存在
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error) {
#ifdef DEBUG
            NSLog(@"创建目录失败:%@  错误:%@",path,error);
#endif
            lastPath = nil;
            
        } else {
#ifdef DEBUG
            NSLog(@"创建目录成功:%@",path);
#endif
            lastPath = path;
        }
    }
    return lastPath;
}

@end
