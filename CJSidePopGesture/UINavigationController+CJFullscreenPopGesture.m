//
//  UINavigationController+CJFullscreenPopGesture.m
//  CJSidePopGestureDemo
//
//  Created by J.Cheng on 2018/5/2.
//  Copyright © 2018年 北极星电力. All rights reserved.
//

#import "UINavigationController+CJFullscreenPopGesture.h"
#import <objc/runtime.h>

#define APP_WINDOW                  [UIApplication sharedApplication].delegate.window
#define SCREEN_WIDTH                [UIScreen mainScreen].bounds.size.width
#define SCREEN_BOUNDS               [UIScreen mainScreen].bounds


@interface CJScreenShotView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView      *maskView;

@end

@implementation CJScreenShotView

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
        [self addSubview:_imageView];
        
        _maskView = [[UIView alloc] initWithFrame:SCREEN_BOUNDS];
        _maskView.backgroundColor = [UIColor clearColor];
        [self addSubview:_maskView];
    }
    return self;
}

@end

typedef void (^_CJViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (CJFullscreenPopGesturePrivate)
@property (nonatomic, copy) _CJViewControllerWillAppearInjectBlock cj_willAppearInjectBlock;

@end

@implementation UIViewController (CJFullscreenPopGesturePrivate)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(cj_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)cj_viewWillAppear:(BOOL)animated {
    [self cj_viewWillAppear:animated];
    
    if (self.cj_willAppearInjectBlock) {
        self.cj_willAppearInjectBlock(self, animated);
    }
}

- (_CJViewControllerWillAppearInjectBlock)cj_willAppearInjectBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCj_willAppearInjectBlock:(_CJViewControllerWillAppearInjectBlock)block {
    objc_setAssociatedObject(self, @selector(cj_willAppearInjectBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


@implementation UIViewController (CJFullscreenPopGesture)

- (BOOL)cj_prefersNavigationBarHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setCj_prefersNavigationBarHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(cj_prefersNavigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCj_interactivePopDisabled:(BOOL)cj_interactivePopDisabled {
    objc_setAssociatedObject(self, @selector(cj_interactivePopDisabled), @(cj_interactivePopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)cj_interactivePopDisabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setCj_recognizeSimultaneouslyEnable:(BOOL)cj_recognizeSimultaneouslyEnable {
    objc_setAssociatedObject(self, @selector(cj_recognizeSimultaneouslyEnable), @(cj_recognizeSimultaneouslyEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)cj_recognizeSimultaneouslyEnable {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end


@implementation UINavigationController (CJFullscreenPopGesture)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(viewDidLoad),
            @selector(pushViewController:animated:),
            @selector(popToViewController:animated:),
            @selector(popToRootViewControllerAnimated:),
            @selector(popViewControllerAnimated:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"cj_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            Method originalMethod = class_getInstanceMethod(self, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
            if (class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

- (void)cj_viewDidLoad {
    [self cj_viewDidLoad];
    self.interactivePopGestureRecognizer.enabled = NO;
    self.cj_viewControllerBasedNavigationBarAppearanceEnabled = YES;
    self.showViewOffsetScale = 1 / 3.0;
    self.showViewOffset = self.showViewOffsetScale * SCREEN_WIDTH;
    self.screenShotView.hidden = YES;
    
    self.popGestureStyle = CJFullscreenPopGestureGradientStyle;
    UIPanGestureRecognizer *popRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
    popRecognizer.delegate = self;
    [self.view addGestureRecognizer:popRecognizer];         //自定义的滑动返回手势
}

- (void)cj_setupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController {
    if (!self.cj_viewControllerBasedNavigationBarAppearanceEnabled) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _CJViewControllerWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setNavigationBarHidden:viewController.cj_prefersNavigationBarHidden animated:animated];
        }
    };
    appearingViewController.cj_willAppearInjectBlock = block;
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.cj_willAppearInjectBlock) {
        disappearingViewController.cj_willAppearInjectBlock = block;
    }
}

#pragma mark - 重写父类方法

- (void)cj_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        [self createScreenShot];
    }
    [self cj_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    if (![self.viewControllers containsObject:viewController]) {
        [self cj_pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)cj_popViewControllerAnimated:(BOOL)animated {
    [self.childVCImages removeLastObject];
    return [self cj_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)cj_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray *viewControllers = [self cj_popToViewController:viewController animated:animated];
    if (self.childVCImages.count >= viewControllers.count){
        for (int i = 0; i < viewControllers.count; i++) {
            [self.childVCImages removeLastObject];
        }
    }
    return viewControllers;
}

- (NSArray<UIViewController *> *)cj_popToRootViewControllerAnimated:(BOOL)animated {
    [self.childVCImages removeAllObjects];
    return [self cj_popToRootViewControllerAnimated:animated];
}

- (void)dragging:(UIPanGestureRecognizer *)recognizer{
    if (self.viewControllers.count <= 1) return;
    CGFloat tx = [recognizer translationInView:self.view].x;
    CGFloat width_scale;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        width_scale = 0;
        self.screenShotView.hidden = NO;
        self.screenShotView.imageView.image = [self.childVCImages lastObject];
        self.screenShotView.imageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.showViewOffset, 0);
        self.screenShotView.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (tx < 0 ) { return; }
        width_scale = tx / SCREEN_WIDTH;
        self.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,tx, 0);
        self.screenShotView.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4 - width_scale * 0.5];
        self.screenShotView.imageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.showViewOffset + tx * self.showViewOffsetScale, 0);
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.view];
        BOOL reset = velocity.x < 0;
        if (tx >= self.cj_interactivePopMaxPanDistanceToLeftEdge && !reset) { // pop回去
            [UIView animateWithDuration:0.25 animations:^{
                self.screenShotView.maskView.backgroundColor = [UIColor clearColor];
                self.screenShotView.imageView.transform = reset ? CGAffineTransformTranslate(CGAffineTransformIdentity, -self.showViewOffset, 0) : CGAffineTransformIdentity;
                self.view.transform = reset ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, SCREEN_WIDTH, 0);
            } completion:^(BOOL finished) {
                [self popViewControllerAnimated:NO];
                self.screenShotView.hidden = YES;
                self.view.transform = CGAffineTransformIdentity;
                self.screenShotView.imageView.transform = CGAffineTransformIdentity;
            }];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                self.screenShotView.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4 + width_scale * 0.5];
                self.view.transform = CGAffineTransformIdentity;
                self.screenShotView.imageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.showViewOffset, 0);
            } completion:^(BOOL finished) {
                self.screenShotView.imageView.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

- (void)createScreenShot {
    if (self.childViewControllers.count == self.childVCImages.count+1) {
        UIGraphicsBeginImageContextWithOptions(APP_WINDOW.bounds.size, YES, 0);
        [APP_WINDOW.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        // CGFloat cgImageBytesPerRow = CGImageGetBytesPerRow(image.CGImage); // 2560
        // CGFloat cgImageHeight = CGImageGetHeight(image.CGImage); // 1137
        // NSUInteger size  = cgImageHeight * cgImageBytesPerRow;
        // NSLog(@"size:%lu",(unsigned long)size/1024/1024); // 输出 2910720
        UIGraphicsEndImageContext();
        [self.childVCImages addObject:image];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.visibleViewController.cj_interactivePopDisabled)     return NO;
    if (self.viewControllers.count <= 1)                          return NO;
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint point = [touch locationInView:gestureRecognizer.view];
        if (point.x < self.cj_shouldReceiveTouchDistanceToLeftEdge) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.visibleViewController.cj_recognizeSimultaneouslyEnable) {
        if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] || [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")] ) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Getter and Setter

- (NSMutableArray<UIImage *> *)childVCImages {
    NSMutableArray *images = objc_getAssociatedObject(self, _cmd);
    if (!images) {
        images = @[].mutableCopy;
        objc_setAssociatedObject(self, _cmd, images, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return images;
}

- (CJScreenShotView *)screenShotView {
    CJScreenShotView *shotView = objc_getAssociatedObject(self, _cmd);
    if (!shotView) {
        shotView = [[CJScreenShotView alloc] init];
        shotView.hidden = YES;
        [APP_WINDOW insertSubview:shotView atIndex:0];
        objc_setAssociatedObject(self, _cmd, shotView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return shotView;
}

- (void)setCj_viewControllerBasedNavigationBarAppearanceEnabled:(BOOL)cj_viewControllerBasedNavigationBarAppearanceEnabled {
    objc_setAssociatedObject(self, @selector(cj_viewControllerBasedNavigationBarAppearanceEnabled), @(cj_viewControllerBasedNavigationBarAppearanceEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (BOOL)cj_viewControllerBasedNavigationBarAppearanceEnabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setShowViewOffset:(CGFloat)showViewOffset {
    objc_setAssociatedObject(self, @selector(showViewOffset), @(showViewOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (CGFloat)showViewOffset {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setShowViewOffsetScale:(CGFloat)showViewOffsetScale {
    objc_setAssociatedObject(self, @selector(showViewOffsetScale), @(showViewOffsetScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (CGFloat)showViewOffsetScale {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (CJFullscreenPopGestureStyle)popGestureStyle {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setPopGestureStyle:(CJFullscreenPopGestureStyle)popGestureStyle {
    objc_setAssociatedObject(self, @selector(popGestureStyle), @(popGestureStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (popGestureStyle == CJFullscreenPopGestureShadowStyle) {
        self.screenShotView.maskView.hidden = YES;
        self.view.layer.shadowColor = [[UIColor grayColor] CGColor];
        self.view.layer.shadowOpacity = 0.7;
        self.view.layer.shadowOffset = CGSizeMake(-3, 0);
        self.view.layer.shadowRadius = 10;
    } else if (popGestureStyle == CJFullscreenPopGestureGradientStyle) {
        self.screenShotView.maskView.hidden = NO;
    }
}

- (CGFloat)cj_interactivePopMaxPanDistanceToLeftEdge
{
#if CGFLOAT_IS_DOUBLE
    CGFloat distance = [objc_getAssociatedObject(self, _cmd) doubleValue];
    if (distance < 1.0) {
        [self setCj_interactivePopMaxPanDistanceToLeftEdge:150];
        return 150;
    }
    return distance;
#else
    CGFloat distance = [objc_getAssociatedObject(self, _cmd) floatValue];
    if (distance < 1.0) {
        [self setCj_interactivePopMaxPanDistanceToLeftEdge:150.f];
        return 150.f;
    }
    return distance;
#endif
}

- (void)setCj_interactivePopMaxPanDistanceToLeftEdge:(CGFloat)distance
{
    SEL key = @selector(cj_interactivePopMaxPanDistanceToLeftEdge);
    objc_setAssociatedObject(self, key, @(MAX(0, distance)), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)cj_shouldReceiveTouchDistanceToLeftEdge
{
#if CGFLOAT_IS_DOUBLE
    CGFloat distance = [objc_getAssociatedObject(self, _cmd) doubleValue];
    if (distance <= 1.0) {
        [self setCj_shouldReceiveTouchDistanceToLeftEdge:SCREEN_WIDTH];
        return SCREEN_WIDTH;
    }
    return distance;
#else
    CGFloat distance = [objc_getAssociatedObject(self, _cmd) floatValue];
    if (distance <= 1.0f) {
        [self setCj_shouldReceiveTouchDistanceToLeftEdge:SCREEN_WIDTH];
        return SCREEN_WIDTH;
    }
    return distance;
#endif
}

- (void)setCj_shouldReceiveTouchDistanceToLeftEdge:(CGFloat)distance
{
    SEL key = @selector(cj_shouldReceiveTouchDistanceToLeftEdge);
    objc_setAssociatedObject(self, key, @(MAX(0, distance)), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end
