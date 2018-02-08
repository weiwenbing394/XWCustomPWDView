//
//  XYAlertContainer.h
//  iIndustrial
//
//  Created by zjx on 2017/11/9.
//
//

#import <UIKit/UIKit.h>

@protocol XYAlertContainerDelegate;

@interface XYAlertContainer : UIView

@property (nonatomic, strong) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, strong) UIView *dialogView;    // Dialog's container view
@property (nonatomic, strong) UIView *containerView; // Container within the dialog (place your ui elements here)
@property (nonatomic, strong) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL closeOnTouchUpOutside;       // Closes the AlertView when finger is lifted outside the bounds.
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, strong) UIColor *spaceColor;
@property (nonatomic, assign) CGFloat spaceHeight;
@property (nonatomic, strong) UIFont *buttonTitleFont;
@property (nonatomic, strong) UIColor *buttonTitleColor;
@property (nonatomic, strong) UIColor *buttonHighlightedColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, weak) id<XYAlertContainerDelegate> delegate;
@property (copy) void (^buttonActionBlock)(XYAlertContainer *alertView, int buttonIndex);


/**
 Alert 弹出操作
 */
- (void)show;


/**
 Alert 关闭操作
 */
- (void)close;

@end

@protocol XYAlertContainerDelegate <NSObject>

@optional
/**
 弹框按钮点击处理
 
 @param alertView 当前alert容器
 @param buttonIndex 按钮索引序号
 */
- (void)dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
