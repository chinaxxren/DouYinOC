//
//  TabBarController.m
//  DouYin
//
//  Created by 赵江明 on 2022/4/5.
//  Copyright © 2022 Jiangmingz. All rights reserved.
//

#import "TabBarController.h"

#import "ViewController.h"
#import "DouYinPlayerController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DouYinPlayerController *playerController = [DouYinPlayerController new];
    playerController.title = @"首页";
    ViewController *viewController = [ViewController new];
    viewController.title = @"我的";
    
    self.viewControllers = @[playerController,viewController];
}


@end
