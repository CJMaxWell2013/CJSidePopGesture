// The MIT License (MIT)
//  UINavigationController+CJSidePopGesture.h
//  侧滑返回修改
//
//  Created by 北极星电力 on 2017/7/24.
//  Copyright © 2017年 北极星电力. All rights reserved.
//
// 侧滑返回网上有很多种思路如： http://www.jianshu.com/p/f83acf1d337b
// 其中---->forkingdog ( https://github.com/forkingdog )这款开源框架
// 比较受到咱们天朝开发人员的喜欢，但是其中有不少问题存在，就是当导航控制器
// 隐藏的时候，下一页控制器在来回的侧滑之间抖动时候，会出现导航条混乱的情况
// 该问题据说原作都没有修改好，而且一直存在这种情况，我决定根据自己的经验调整
// 了百度知道团队出品的全屏侧滑返回，并且提交Pods方便我们开发组内部的人员相互
// 共享下资源！！！若您无意中使用了，有问题可以在github上给我留言。
// 为了尊敬原作，fd开头的是百度知道的，cj开头的是我修改的。

#import <UIKit/UIKit.h>

/**
 ******使用方法，控制器拥有对导航控制器的控制权，所以你只要在当前控制器中做如下配置就行了**********
 
 1、如果您想隐藏导航栏很简单只需要在
 
     - (void)viewDidLoad {
     [super viewDidLoad];
         self.fd_prefersNavigationBarHidden = YES; // 将这个属性设置为YES可以隐藏当前导航栏，默认为NO不需设置
     // Do any additional setup after loading the view, typically from a nib.
     }
 
 2、如果你有需要将侧滑返回给禁止
 
 - (void)viewDidLoad {
     [super viewDidLoad];
     fd_interactivePopDisabled = YES; // 将这个属性设置为YES可以隐藏当前导航栏，默认为NO，支持侧滑返回
 
 }
 
 除此之外不需要做任何配置

 */
@interface UINavigationController (CJSidePopGesture)


@property (nonatomic, strong, readonly) UIPanGestureRecognizer *fd_fullscreenPopGestureRecognizer;

@property (nonatomic, assign) BOOL fd_viewControllerBasedNavigationBarAppearanceEnabled;

@end


@interface UIViewController (CJSidePopGesture)

/**
 侧滑是否可用
 */
@property (nonatomic, assign) BOOL fd_interactivePopDisabled;

/**
 是否需要隐藏当前控制器的导航条
 */
@property (nonatomic, assign) BOOL fd_prefersNavigationBarHidden;

/**
 该属性可以获取控制器在栈中是否还有楼上了
 */
@property (nonatomic, assign) BOOL cj_hasUpstairsController;

@end
