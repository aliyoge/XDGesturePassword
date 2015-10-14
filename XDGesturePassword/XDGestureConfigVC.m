//
//  XDGestureVC.m
//  XDGesturePassword
//
//  Created by wenjunhuang on 15/10/14.
//  Copyright © 2015年 wenjunhuang. All rights reserved.
//

#import "XDGestureConfigVC.h"
#import "XDGestureView.h"

static inline UIColor*
UIColorWithRGB(float r, float g, float b, float a)
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

static NSString* const kInputingTip     = @"请输入解锁密码";
static NSString* const kErrorMessage    = @"密码输入错误";

@interface XDGestureConfigVC ()<XDGestureViewDelegate>
@property (nonatomic, strong) UIImageView   *backgroundImgView;
@property (nonatomic, strong) UILabel       *messageLabel;
@property (nonatomic, strong) XDGestureView *gesturePasswordView;
@property (nonatomic, strong) XDGestureView *gestureShowView;
@end

@implementation XDGestureConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView
{
    [self.view addSubview:self.backgroundImgView];
    [self.view addSubview:self.gesturePasswordView];
    [self.view addSubview:self.gestureShowView];
    [self.view addSubview:self.messageLabel];
}

#pragma mark - delegate
- (void)gesturePasswordView:(XDGestureView *)passwordView didStartedWithSequence:(NSUInteger)sequence
{
    [self.gestureShowView reset];
    self.messageLabel.textColor = [self.gesturePasswordView getSelectedColor];
    self.messageLabel.text      = kInputingTip;
}

- (void)gesturePasswordView:(XDGestureView *)passwordView didMovedWithActiveCircle:(char *)active
{
    [self.gestureShowView setAcitveCircle:active];
}

- (void)gesturePasswordView:(XDGestureView *)passwordView didEndInputWithPassword:(NSString *)password touchedCount:(NSUInteger)touchedCount sequence:(NSUInteger)sequence
{
    self.messageLabel.text      = kErrorMessage;
    self.gesturePasswordView.isError      = YES;
    self.messageLabel.textColor = [self.gesturePasswordView getSelectedColor];
    
    __weak typeof(passwordView) weakpv = passwordView;
    __weak typeof(self.gestureShowView) weaksv = self.gestureShowView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"weakpv.sequence == %ld , sequence = %ld",weakpv.sequence,sequence);
        if (weakpv.sequence == sequence) {//if not start another gesture
            [weakpv reset];
            [weaksv reset];
            self.messageLabel.textColor = [weakpv getSelectedColor];
            self.messageLabel.text      = kInputingTip;
        }
    });
}

#pragma mark - getter

- (XDGestureView *)gesturePasswordView
{
    float top = (self.view.bounds.size.height - self.view.bounds.size.width)/2.0 * 1.5;
    if (!_gesturePasswordView) {
        _gesturePasswordView = [[XDGestureView alloc] initWithFrame:CGRectMake(0, top, self.view.bounds.size.width, self.view.bounds.size.width) isShowView:NO];
        _gesturePasswordView.backgroundColor = [UIColor clearColor];
        _gesturePasswordView.delegate = self;
    }
    return _gesturePasswordView;
}

- (XDGestureView *)gestureShowView
{
    float top = (self.view.bounds.size.height - self.view.bounds.size.width)/2.0 * 1.5;
    float showViewWidth = (self.view.bounds.size.width / 5);
    float showViewHeight = showViewWidth;
    float showViewX = (self.view.bounds.size.width - showViewWidth) / 2;
    if (!_gestureShowView) {
            _gestureShowView = [[XDGestureView alloc] initWithFrame:CGRectMake(showViewX, top/3, showViewWidth, showViewHeight) isShowView:YES];
        _gestureShowView.backgroundColor = [UIColor clearColor];
    }
    return _gestureShowView;
}

- (UILabel *)messageLabel
{
    float top = (self.view.bounds.size.height - self.view.bounds.size.width)/2.0 * 1.5;
    if (!_messageLabel) {
        _messageLabel               = [[UILabel alloc] initWithFrame:CGRectMake(0, top/2.2, self.view.bounds.size.width, top/1.0)];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font          = [UIFont systemFontOfSize:16];
        _messageLabel.textColor     = [self.gesturePasswordView getSelectedColor];
        _messageLabel.text          = kInputingTip;
    }
    return _messageLabel;
}

- (UIImageView *)backgroundImgView
{
    if (!_backgroundImgView) {
        _backgroundImgView = [UIImageView new];
        _backgroundImgView.userInteractionEnabled = YES;
        _backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImgView.image = [UIImage imageNamed:@"background"];
        _backgroundImgView.frame = self.view.bounds;
    }
    return _backgroundImgView;
}

@end
