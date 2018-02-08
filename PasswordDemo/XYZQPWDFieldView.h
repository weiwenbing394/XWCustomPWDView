//
//  XYZQPWDFieldView.h
//
//  Created by xiaowei on 2018/2/8.
//  Copyright © 2018年 xiaowei. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 创建一个不允许复制的输入框
 */
@interface PWDTextField:UITextField

@end

@interface XYZQPWDFieldView : UIView<UITextFieldDelegate>

/**
 密码内容回调
 */
@property (nonatomic ,copy) void (^PWDStrBlock) (NSString *pwdStr);

/**
 *  清除密码
 */
- (void)clearUpPassword;

@end
