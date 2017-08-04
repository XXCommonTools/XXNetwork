//
//  XXNetworkAnimation.h
//  Pods
//
//  Created by xby on 2017/7/14.
//
//

#import <UIKit/UIKit.h>

@protocol XXNetworkingAnimationAction <NSObject>

@required;

- (void)showLoadingWithText:(NSString *)text inView:(UIView *)view;
- (void)hideLoading;


@end

@interface XXNetworkAnimation : NSObject

@end
