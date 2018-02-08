//
//  RootViewController.m
//  PasswordDemo
//
//  Created by aDu on 2017/2/6.
//  Copyright © 2017年 DuKaiShun. All rights reserved.
//

#import "RootViewController.h"
#import "XYZQCustomPWDView.h"


@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"密码设置";
    self.view.backgroundColor = [UIColor colorWithRed:230 / 250.0 green:230 / 250.0 blue:230 / 250.0 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor brownColor];
    button.frame = CGRectMake(100, 180, self.view.frame.size.width - 200, 50);
    [button addTarget:self action:@selector(clearPaw) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"弹出输入框" forState:UIControlStateNormal];
    [self.view addSubview:button];
}

- (void)clearPaw
{
    
    [XYZQCustomPWDView showAlertWithTitle:@"温馨提示" message:@"请输入交易功能开启密码" buttonTitles:@[@"取消",@"确认"] alertBlock:^(int buttonIndex,NSString *pwdStr) {
        if (buttonIndex==0) {
            NSLog(@"点击了取消");
        }else{
            NSLog(@"点击了确定");
        }
        NSLog(@"密码是：%@",pwdStr);
    }];
}

@end
