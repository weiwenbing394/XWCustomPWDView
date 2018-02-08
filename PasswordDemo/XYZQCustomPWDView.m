//
//  XYZQCustomPWDView.m
//  PasswordDemo
//
//  Created by Admin on 2018/2/8.
//  Copyright © 2018年 DuKaiShun. All rights reserved.
//

#import "XYZQCustomPWDView.h"
#import "XYZQPWDFieldView.h"
#import "XYAlertContainer.h"

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

//密码位数
#define kDotCount 4
//取消按钮的颜色
#define cancelButtomColor [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f]
//确定能点击状态的颜色
#define okButtomEnableColor [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f]
//确定按钮不能点击时的状态的颜色
#define okButtomNotEnableColor [UIColor lightGrayColor]
//输入的密码
static NSString *pwdStr;

@implementation XYZQCustomPWDView

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles alertBlock:(alertButtonBlock)block{
    
    XYAlertContainer *alertView = [[XYAlertContainer alloc] init];
    [alertView setButtonTitleColor:cancelButtomColor];
    [alertView setButtonHighlightedColor:cancelButtomColor];
    [alertView setButtonTitles:buttonTitles];
    [alertView setContainerView:[[self class] createViewWithTitle:title message:message containerView:alertView buttonTitles:buttonTitles]];
    [alertView setButtonActionBlock:^(XYAlertContainer *alertView, int buttonIndex) {
        if (buttonIndex==0) {
            pwdStr=@"";
        }
        block?block(buttonIndex,pwdStr):nil;
        [alertView close];
    }];
    [alertView show];
    [self setSingleButtomColor:alertView buttonTitles:buttonTitles];
}

+ (UIView *)createViewWithTitle:(NSString *)title message:(NSString *)message containerView:(XYAlertContainer *)alertView buttonTitles:(NSArray *)buttonTitles{
    
    CGFloat textWidth = [UIScreen mainScreen].bounds.size.width - 120;
    CGFloat textMargin = 15;
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    titleLabel.frame = CGRectMake(textMargin, textMargin, textWidth, 40);
    [titleLabel setContentMode:UIViewContentModeBottom];
    
    
    //内容
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(textMargin, CGRectGetMaxY(titleLabel.frame), textWidth, 20)];
    messageLabel.font = [UIFont systemFontOfSize:16];
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.text = message;
    
    
    //输入框
    pwdStr=@"";
    @weakify(self);
    XYZQPWDFieldView * pasView = [[XYZQPWDFieldView alloc] initWithFrame:CGRectMake(textMargin * 2, CGRectGetMaxY(messageLabel.frame)+textMargin, textWidth-textMargin * 2, 45)];
    [pasView setPWDStrBlock:^(NSString *inputPwdStr) {
        @strongify(self);
        pwdStr=inputPwdStr;
        [self setSingleButtomColor:alertView buttonTitles:buttonTitles];
    }];
    
    //底view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textWidth + textMargin * 2, CGRectGetMaxY(pasView.frame)+textMargin)];
    [view addSubview:titleLabel];
    [view addSubview:messageLabel];
    [view addSubview:pasView];
    
    return view;
}

//设置确定按钮的可点击状态及颜色
+ (void)setSingleButtomColor:(XYAlertContainer *)alertView buttonTitles:(NSArray *)buttonTitles{
    if (buttonTitles.count<2) {
        return;
    }
    for (UIView *view in alertView.dialogView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn=(UIButton *)view;
            if ([btn.currentTitle isEqualToString:buttonTitles[1]]) {
                if (pwdStr.length==kDotCount) {
                    [btn setTitleColor:okButtomEnableColor forState:0];
                    [btn setTitleColor:okButtomEnableColor forState:UIControlStateHighlighted];
                    btn.userInteractionEnabled=YES;
                }else{
                    [btn setTitleColor:okButtomNotEnableColor forState:0];
                    [btn setTitleColor:okButtomNotEnableColor forState:UIControlStateHighlighted];
                    btn.userInteractionEnabled=NO;
                }
            }
        }
    }
}

@end
