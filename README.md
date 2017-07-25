# CJSidePopGesture
iOS侧滑返回修改

# Installation

Use CocoaPods  

``` ruby
pod 'CJSidePopGesture', '~> 1.0.0'
```


# Overview

![snapshot](https://raw.githubusercontent.com/CJMaxWell2013/CJSidePopGesture/master/Snapshots/sideBack.gif)


这个扩展来自 @forkingdog 团队这些人的源码，以及@J_雨等人，参考文章地址：(http://www.jianshu.com/p/f83acf1d337b)

# Usage



**AOP**, just add 2 files and **no need** for any setups, all navigation controllers will be able to use fullscreen pop gesture automatically.  

To disable this pop gesture of a navigation controller:  

``` objc
navigationController.fd_fullscreenPopGestureRecognizer.enabled = NO;
```

To disable this pop gesture of a view controller:  

``` objc
viewController.fd_interactivePopDisabled = YES;
```

Require at least iOS **7.0**.

# View Controller Based Navigation Bar Appearance

It handles navigation bar transition properly when using fullscreen gesture to push or pop a view controller:  

- with bar -> without bar
- without bar -> with bar
- without bar -> without bar

This opmiziation is enabled by default, from now on you don't need to call **UINavigationController**'s `-setNavigationBarHidden:animated:` method, instead, use view controller's specific API to hide its bar:  

``` objc
- (void)viewDidLoad {
[super viewDidLoad];
self.fd_prefersNavigationBarHidden = NO;
}
```

And this property is **NO** by default.

# View Controller With ScrollView

If you want to use fullscreen pop gesture in ViewController with scrollView or subclass of scrollView , you should customize the scrollView or subclass of scrollView and overload the `gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:` method . like this:

``` objc
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
if (self.contentOffset.x <= 0) {
if ([otherGestureRecognizer.delegate isKindOfClass:NSClassFromString(@"_FDFullscreenPopGestureRecognizerDelegate")]) {
return YES;
}
}
return NO;
}
```

# Release Notes

**1.0.0** - 侧滑返回首次上传修改，这个版本支持到iOS7.0以及以上.

# License  
MIT

