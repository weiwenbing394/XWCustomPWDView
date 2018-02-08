//
//  XYZQPasswordView.h
//
//  Created by xiaowei on 2018/2/8.
//  Copyright © 2018年 xiaowei. All rights reserved.
//

#import "XYZQPWDFieldView.h"

//密码点的大小
#define kDotSize CGSizeMake (10, 10)
//密码个数
#define kDotCount 4
//密码点的背景颜色
#define kDotBGColor [UIColor blackColor]
//边框线的颜色
#define kBorderColor [UIColor grayColor]
//边框线的宽度
#define pwdTextFieldBorderW    1
//输入框文字的颜色
#define pwdTextFieldTextColor  [UIColor clearColor]
//每一个输入框的高度等于当前view的高度
#define K_Field_Height self.frame.size.height

@implementation PWDTextField

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}

@end

@interface XYZQPWDFieldView ()

@property (nonatomic, strong) PWDTextField *textField;
//用于存放黑色的点点
@property (nonatomic, strong) NSMutableArray *dotArray;

@end

@implementation XYZQPWDFieldView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initPwdTextField];
    }
    return self;
}


/**
 创建ui
 */
- (void)initPwdTextField{
    //每个密码输入框的宽度
    CGFloat width = self.frame.size.width / kDotCount;
    
    //生成分割线
    for (int i = 0; i < kDotCount - 1; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.textField.frame) + (i + 1) * width, 0, pwdTextFieldBorderW, K_Field_Height)];
        lineView.backgroundColor = kBorderColor;
        [self addSubview:lineView];
    }
    
    self.dotArray = [[NSMutableArray alloc] init];
    //生成中间的点
    for (int i = 0; i < kDotCount; i++) {
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.textField.frame) + (width - kDotSize.width) / 2 + i * width, CGRectGetMinY(self.textField.frame) + (K_Field_Height - kDotSize.height) / 2, kDotSize.width, kDotSize.height)];
        dotView.backgroundColor = kDotBGColor;
        dotView.layer.cornerRadius = kDotSize.width / 2.0f;
        dotView.clipsToBounds = YES;
        dotView.hidden = YES; //先隐藏
        [self addSubview:dotView];
        //把创建的黑色点加入到数组中
        [self.dotArray addObject:dotView];
    }
}

/**
 *  重置显示的点
 */
- (void)textFieldDidChange:(UITextField *)textField{
    NSLog(@"%@", textField.text);
    for (UIView *dotView in self.dotArray) {
        dotView.hidden = YES;
    }
    for (int i = 0; i < textField.text.length; i++) {
        ((UIView *)[self.dotArray objectAtIndex:i]).hidden = NO;
    }
    if (textField.text.length == kDotCount) {
        NSLog(@"输入完毕");
    }
    self.PWDStrBlock ? self.PWDStrBlock(textField.text) : nil;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([string isEqualToString:@"\n"]) {
        //按回车关闭键盘
        [textField resignFirstResponder];
        return NO;
    } else if(string.length == 0) {
        //判断是不是删除键
        return YES;
    }else if(textField.text.length >= kDotCount) {
        //输入的字符个数大于6，则无法继续输入，返回NO表示禁止输入
        return NO;
    } else {
        return YES;
    }
}

/**
 *  清除密码
 */
- (void)clearUpPassword{
    self.textField.text = @"";
    [self textFieldDidChange:self.textField];
}


#pragma mark - lazy load
- (UITextField *)textField{
    if (!_textField) {
        _textField = [[PWDTextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, K_Field_Height)];
        _textField.backgroundColor = pwdTextFieldTextColor;
        //输入的文字颜色为无色
        _textField.textColor = pwdTextFieldTextColor;
        //输入框光标的颜色为无色
        _textField.tintColor = pwdTextFieldTextColor;
        _textField.delegate = self;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.layer.borderColor = [kBorderColor CGColor];
        _textField.layer.borderWidth = pwdTextFieldBorderW;
        [_textField becomeFirstResponder];
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_textField];
    }
    return _textField;
}

@end
