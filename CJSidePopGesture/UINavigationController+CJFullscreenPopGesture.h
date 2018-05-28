//
//  UINavigationController+CJFullscreenPopGesture.h
//  CJSidePopGestureDemo
//
//  Created by J.Cheng on 2018/5/2.
//  Copyright © 2018年 北极星电力. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CJFullscreenPopGesture)

/// 隐藏NavigationBar（default is NO）
@property (nonatomic, assign) BOOL cj_prefersNavigationBarHidden;
/// 关闭某个控制器的pop手势（default is NO）
@property (nonatomic, assign) BOOL cj_interactivePopDisabled;
/// 自定义的滑动返回手势是否与其他手势共存，一般使用默认值(default return NO：不与任何手势共存)
@property (nonatomic, assign) BOOL cj_recognizeSimultaneouslyEnable;

@end

typedef NS_ENUM(NSInteger,CJFullscreenPopGestureStyle) {
    CJFullscreenPopGestureGradientStyle,   // 根据滑动偏移量背景颜色渐变
    CJFullscreenPopGestureShadowStyle      // 侧边阴影效果，类似系统的滑动样式
};

@interface UINavigationController (CJFullscreenPopGesture) <UIGestureRecognizerDelegate>

/// A view controller is able to control navigation bar's appearance by itself,
/// rather than a global way, checking "fd_prefersNavigationBarHidden" property.
/// Default to YES, disable it if you don't want so.
@property (nonatomic, assign) BOOL cj_viewControllerBasedNavigationBarAppearanceEnabled;

/** default is CJFullscreenPopGestureGradientStyle */
@property (nonatomic, assign) CJFullscreenPopGestureStyle popGestureStyle;

/** 滑动偏移量临界值 `<150` 会取消返回 `>=150` 会pop*/
@property (nonatomic, assign) CGFloat cj_interactivePopMaxPanDistanceToLeftEdge;

/** 侧滑返回手势手势触发距离，默认全屏 */
@property (nonatomic, assign) CGFloat cj_shouldReceiveTouchDistanceToLeftEdge;

/** 所有的压栈截图 */
@property (nonatomic, strong) NSMutableArray<UIImage *> *childVCImages;

/**当Window的rootViewController发生变化时候，需要调用改方法，将所有的侧滑蒙版去掉
 */
- (void)removeAllScreenShotViewInWindow;

@end

