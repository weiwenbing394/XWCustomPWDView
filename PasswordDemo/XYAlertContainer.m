//
//  XYAlertContainer.m
//  iIndustrial
//
//  Created by zjx on 2017/11/9.
//
//

#import "XYAlertContainer.h"
#import <QuartzCore/QuartzCore.h>

@interface XYAlertContainer ()<XYAlertContainerDelegate>

@end

@implementation XYAlertContainer
#pragma mark - private's method
/**
 iOS7旋转处理
 */
- (void)changeOrientationForIOS7
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat startRotation = [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CGAffineTransform rotation;
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 270.0 / 180.0);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 90.0 / 180.0);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 180.0 / 180.0);
            break;
        default:
            rotation = CGAffineTransformMakeRotation(-startRotation + 0.0);
            break;
    }
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _dialogView.transform = rotation;
                     }
                     completion:nil
     ];
}

/**
 iOS8 旋转处理
 
 @param notification UIDeviceOrientationDidChangeNotification
 */
- (void)changeOrientationForIOS8:(NSNotification *)notification
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGSize dialogSize = [self calcDialogSize];
                         CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                         self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
                         _dialogView.frame = CGRectMake((screenWidth - dialogSize.width) / 2, (screenHeight - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
}

/**
 Description
 
 @param notification UIDeviceOrientationDidChangeNotification
 */
- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    if (_parentView) {
        return;
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        [self changeOrientationForIOS7];
    } else {
        [self changeOrientationForIOS8:notification];
    }
}

/**
 键盘弹出处理
 
 @param notification UIKeyboardWillShowNotification
 */
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize screenSize = [self calcScreenSize];
    CGSize dialogSize = [self calcDialogSize];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && [[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        CGFloat tmp = keyboardSize.height;
        keyboardSize.height = keyboardSize.width;
        keyboardSize.width = tmp;
    }
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
}


/**
 键盘收起处理
 
 @param notification UIKeyboardWillHideNotification
 */
- (void)keyboardWillHide:(NSNotification *)notification
{
    CGSize screenSize = [self calcScreenSize];
    CGSize dialogSize = [self calcDialogSize];
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_closeOnTouchUpOutside) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass:[XYAlertContainer class]]) {
        [self close];
    }
}

// Helper function: count and return the dialog's size

/**
 calc and return the dialog's size
 
 @return dialog's size
 */
- (CGSize)calcDialogSize
{
    CGFloat dialogWidth = _containerView.frame.size.width;
    CGFloat dialogHeight = _containerView.frame.size.height + _buttonHeight + _spaceHeight;
    
    return CGSizeMake(dialogWidth, dialogHeight);
}

// Helper function: count and return the screen's size

/**
 calc and return the screen's size
 
 @return screen's size
 */
- (CGSize)calcScreenSize
{
    if ([_buttonTitles count] > 0) {
        _buttonHeight = 44;
        _spaceHeight  = .5;
    } else {
        _buttonHeight = 0;
        _spaceHeight = 0;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // On iOS7, screen width and height doesn't automatically follow orientation
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            CGFloat tmp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = tmp;
        }
    }
    
    return CGSizeMake(screenWidth, screenHeight);
}

/**
 创建Alert内容容器视图
 
 @return 返回容器视图
 */
- (UIView *)createContainerView
{
    if (!_containerView) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (width-20), (width-20) *.5)];
    }
    
    CGSize screenSize = [self calcScreenSize];
    CGSize dialogSize = [self calcDialogSize];
    
    // For the black background
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    // This is the dialog's container; we attach the custom content and the buttons to this one
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)];
    
    // First, we style the dialog to match the iOS7 UIAlertView >>>
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = dialogContainer.bounds;
    
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithWhite:1.0 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithWhite:1.0 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithWhite:1.0 alpha:1.0] CGColor],
                       nil];
    
    gradient.cornerRadius = _cornerRadius;
    [dialogContainer.layer insertSublayer:gradient atIndex:0];
    
    dialogContainer.layer.cornerRadius = _cornerRadius;
    dialogContainer.layer.borderColor = [_borderColor CGColor];
    dialogContainer.layer.borderWidth = 0.5f;
    dialogContainer.layer.shadowRadius = _cornerRadius + 5;
    dialogContainer.layer.shadowOpacity = 0.1f;
    dialogContainer.layer.shadowOffset = CGSizeMake(0 - (_cornerRadius+5)/2, 0 - (_cornerRadius+5)/2);
    dialogContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    dialogContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:dialogContainer.bounds cornerRadius:dialogContainer.layer.cornerRadius].CGPath;
    dialogContainer.clipsToBounds = YES;
    
    // There is a line above the button
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - _buttonHeight - _spaceHeight, dialogContainer.bounds.size.width, _spaceHeight)];
    lineView.backgroundColor = _spaceColor;
    [dialogContainer addSubview:lineView];
    [dialogContainer addSubview:_containerView];
    
    [self createActionView:dialogContainer];
    
    return dialogContainer;
}

/**
 创建Alert操作按钮视图
 */
- (void)createActionView:(UIView *)container
{
    NSInteger buttonNums = _buttonTitles.count;
    CGFloat buttonWidth = CGRectGetWidth(container.bounds) / MAX(buttonNums, 1);
    
    for (NSInteger i = 0; i < buttonNums; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(i * buttonWidth, CGRectGetHeight(container.bounds) - _buttonHeight, buttonWidth, _buttonHeight)];
        [btn addTarget:self action:@selector(dialogButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:i];
        
        [btn setTitle:[_buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:_buttonTitleColor forState:UIControlStateNormal];
        [btn setTitleColor:_buttonHighlightedColor forState:UIControlStateHighlighted];
        [btn.titleLabel setFont:_buttonTitleFont];
        [btn.titleLabel setNumberOfLines:0];
        [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btn.layer setCornerRadius:_cornerRadius];
        
        [container addSubview:btn];
        
        if (buttonNums > 1 && i+1 < buttonNums) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(i+1 * buttonWidth, CGRectGetHeight(container.bounds) - _buttonHeight, _spaceHeight, _buttonHeight)];
            lineView.backgroundColor = _spaceColor;
            [container addSubview:lineView];
        }
    }
}

/**
 弹框按钮点击事件
 
 @param sender button
 */
- (void)dialogButtonAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(dialogButtonTouchUpInside:clickedButtonAtIndex:)]) {
        [_delegate dialogButtonTouchUpInside:self clickedButtonAtIndex:[sender tag]];
    }
    
    if (self.buttonActionBlock) {
        self.buttonActionBlock(self, (int)[sender tag]);
    }
}

#pragma mark - public's method
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _spaceColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
        _buttonTitleFont = [UIFont boldSystemFontOfSize:16.0f];
        _buttonTitleColor = [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f];
        _buttonHighlightedColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f];
        _borderColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
        _delegate = self;
        _closeOnTouchUpOutside = NO;
        _cornerRadius = 10.0;
        _buttonHeight = 44.0;
        _spaceHeight = 0.5;
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

/**
 Alert 弹出操作
 */
- (void)show
{
    self.dialogView = [self createContainerView];
    
    _dialogView.layer.shouldRasterize = YES;
    _dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [self addSubview:_dialogView];
    
    // Can be attached to a view or to the top most window
    if (_parentView) {  // Attached to a view:
        [_parentView addSubview:self];
    } else {    // Attached to the top most window
        
        // On iOS7, calculate with orientation
        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
            
            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            switch (interfaceOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 180.0 / 180.0);
                    break;
                default:
                    break;
            }
            
            [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        } else {    // On iOS8, just place the dialog in the middle
            
            CGSize screenSize = [self calcScreenSize];
            CGSize dialogSize = [self calcDialogSize];
            CGSize keyboardSize = CGSizeMake(0, 0);
            
            _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
        }
        
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    }
    
    _dialogView.layer.opacity = 0.5f;
    _dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         _dialogView.layer.opacity = 1.0f;
                         _dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:NULL
     ];
}

/**
 Alert 关闭操作
 */
- (void)close
{
    CATransform3D currentTransform = _dialogView.layer.transform;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        CGFloat startRotation = [[_dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
        
        _dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    }
    
    _dialogView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         _dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         _dialogView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
}

#pragma mark - CMAlertContainerDelegate
/**
 弹框按钮点击处理
 
 @param alertView 当前alert容器
 @param buttonIndex 按钮索引序号
 */
- (void)dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self close];
}

@end
