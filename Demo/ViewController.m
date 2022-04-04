//
//  ViewController.m
//  Demo
//
//  Created by Jiangmingz on 2016/6/30.
//  Copyright © 2016年 Jiangmingz. All rights reserved.
//

#import "ViewController.h"
#import "DouYinViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    DouYinViewController *controller = [DouYinViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
