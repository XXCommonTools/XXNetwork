//
//  XXCacheManager.m
//  XXNetworkDemo
//
//  Created by xby on 2017/7/7.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXCacheManager.h"
#import "XXNetworkingConfigurationManager.h"
#import "XXCacheModel.h"


#import <XXCategories/NSDictionary+ToString.h>
#import <XXCategories/NSString+MD5.h>
#import <XXCategories/NSString+FilePath.h>

@interface XXCacheManager ()

@property (copy,nonatomic) NSString *cacheDir;
@property (copy,nonatomic) NSString *cacheObjectDir;
@property (copy,nonatomic) NSString *cacheDataDir;



@end

@implementation XXCacheManager


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    static XXCacheManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[XXCacheManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - private
- (NSString *)dataKeyWithServiceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url method:(NSString *)method params:(id)params {

    NSString *paramString = @"";
    if ([params isKindOfClass:[NSDictionary class]]) {
        
        paramString = [params toString];
        
    } else if ([params isKindOfClass:[NSArray class]]) {
        
        paramString = [params toString];
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@_%@",serviceIdentifier,url,method,paramString];
    NSString *md5String = [key md5String];
    return md5String;
}
- (void)saveCacheData:(NSData *)data key:(NSString *)key cacheTime:(NSTimeInterval)cacheTime {

    NSString *fileName = [self.cacheObjectDir stringByAppendingPathComponent:key];
    XXCacheModel *cacheModel = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    if (!cacheModel) {
        
        cacheModel = [[XXCacheModel alloc] init];
    }
    [cacheModel updateContent:data cacheTime:cacheTime];
    BOOL isOk = [NSKeyedArchiver archiveRootObject:cacheModel toFile:fileName];
    NSString *dataFileName = [self.cacheDataDir stringByAppendingPathComponent:key];
    BOOL isWrite = [data writeToFile:dataFileName atomically:YES];
#ifdef DEBUG
    if (isOk) {
        
        NSLog(@"缓存数据对象归档成功,文件名：%@  ~~~~~~~ 数据：%@",fileName,cacheModel);
        
    } else {
        
        NSLog(@"缓存数据对象归档不成功,文件名：%@  ~~~~~~~ 数据：%@",fileName,cacheModel);
    }
    if (isWrite) {
        
        NSLog(@"数据文件保存成功,文件名：%@  ~~~~~~~ 数据：%@",dataFileName,data);

    } else {
        
        NSLog(@"数据文件保存不成功,文件名：%@  ~~~~~~~ 数据：%@",dataFileName,data);
    }
#endif

}
- (NSData *)fetchDataWithKey:(NSString *)key {

    NSString *fileName = [self.cacheObjectDir stringByAppendingPathComponent:key];
    NSString *dataFileName = [self.cacheDataDir stringByAppendingPathComponent:key];
    
    XXCacheModel *cacheModel = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    cacheModel.content = [NSData dataWithContentsOfFile:dataFileName];
    if (cacheModel.isOutdated || cacheModel.isEmpty) {
    
        [self deleteFileWithPath:dataFileName];
        return nil;
        
    } else {
    
        return cacheModel.content;
    }
}
- (void)deleteDataWithKey:(NSString *)key {

    NSString *fileName = [self.cacheObjectDir stringByAppendingPathComponent:key];
    NSString *dataFileName = [self.cacheDataDir stringByAppendingPathComponent:key];
    [self deleteFileWithPath:fileName];
    [self deleteFileWithPath:dataFileName];
}
- (void)deleteFileWithPath:(NSString *)path {

    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:path error:nil];
}
#pragma mark - public
- (void)saveCacheData:(NSData *)data cacheTime:(NSTimeInterval)cacheTime serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url method:(NSString *)method params:(id)params {

    NSString *key = [self dataKeyWithServiceIdentifier:serviceIdentifier url:url method:method params:params];
    [self saveCacheData:data key:key cacheTime:cacheTime];
}

- (NSData *)fetchDataWithServiceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url method:(NSString *)method params:(id)params {

    NSString *key = [self dataKeyWithServiceIdentifier:serviceIdentifier url:url method:method params:params];
    return  [self fetchDataWithKey:key];
}
- (void)deleteDataWithServiceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url method:(NSString *)method params:(id)params {

    NSString *key = [self dataKeyWithServiceIdentifier:serviceIdentifier url:url method:method params:params];
    [self deleteDataWithKey:key];
}
///删除所有的缓存数据
- (void)deleteAllCacheData {
    
    [self deleteFileWithPath:self.cacheDir];
    [self deleteFileWithPath:self.cacheObjectDir];
    [self deleteFileWithPath:self.cacheDataDir];
    
    self.cacheDataDir = nil;
    self.cacheObjectDir = nil;
    self.cacheDir = nil;
    
}
#pragma mark - delegate

#pragma mark - event response

#pragma mark - getters and setters
- (NSString *)cacheDir {

    if (!_cacheDir) {
        
        NSString *temp = [XXNetworkingConfigurationManager sharedInstance].cacheDir;
        if (temp) {
            
            _cacheDir = temp;
            
        } else {
            
            _cacheDir = [NSString dirPathInLibraryWithName:@"XXNetworkCacheData"];
        }
    }
    return _cacheDir;
}
- (NSString *)cacheObjectDir {

    if (!_cacheObjectDir) {
        
        _cacheObjectDir = [NSString dirPathWithName:@"object" inDir:self.cacheDir];
    }
    return _cacheObjectDir;
}
- (NSString *)cacheDataDir {

    if (!_cacheDataDir) {
        
        _cacheDataDir = [NSString dirPathWithName:@"data" inDir:self.cacheDir];
    }
    return _cacheDataDir;
}

@end
