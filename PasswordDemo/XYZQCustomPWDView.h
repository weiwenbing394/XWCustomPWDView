//
//  XYZQCustomPWDView.h
//  PasswordDemo
//
//  Created by Admin on 2018/2/8.
//  Copyright © 2018年 DuKaiShun. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 按钮点击事件回调block
 @param buttonIndex 点击的按钮的下标
 @param pwdStr 输入的密码
 */
typedef void (^alertButtonBlock) (int buttonIndex,NSString *pwdStr);

@interface XYZQCustomPWDView : UIView

@property (nonatomic, copy) alertButtonBlock alertBlock;

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles alertBlock:(alertButtonBlock)block;

@end
