//
//  ViewController.m
//  CJSidePopGestureDemo
//
//  Created by 北极星电力 on 2017/7/24.
//  Copyright © 2017年 北极星电力. All rights reserved.
//

#import "ViewController.h"
#import "UINavigationController+CJFullscreenPopGesture.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cj_prefersNavigationBarHidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
