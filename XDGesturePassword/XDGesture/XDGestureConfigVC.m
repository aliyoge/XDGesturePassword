//
//  XDGestureVC.m
//  XDGesturePassword
//
//  Created by wenjunhuang on 15/10/14.
//  Copyright © 2015年 wenjunhuang. All rights reserved.
//

#import "XDGestureConfigVC.h"

static inline UIColor*
UIColorWithRGB(float r, float g, float b, float a)
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

static NSUInteger const kLimitTapCount      = 4;
static NSString*  const kInputingTip        = @"绘制解锁图案";
static NSString*  const kVerifyTip          = @"再次确认手势密码";
static NSString*  const kErrorMessage       = @"密码不一致, 请重新输入";
static NSString*  const kDoneMessage        = @"密码设置成功";
static NSString*  const kLessThanFourTapTip = @"至少连接4个点, 请重新输入";
static NSString*  const kBottomTip          = @"设置手势密码, 防止他人未经授权查看";

@interface XDGestureConfigVC ()<XDGestureViewDelegate>
@property (nonatomic, strong) UIImageView   *backgroundImgView;
@property (nonatomic, strong) UILabel       *messageLabel;
@property (nonatomic, strong) UILabel       *bottomTipLabel;
@property (nonatomic, strong) XDGestureView *gesturePasswordView;
@property (nonatomic, strong) XDGestureView *gestureShowView;

@property (nonatomic, copy)   NSString      *tempPassword;
@end

@implementation XDGestureConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置手势密码";
    [self setupView];
}

- (void)setupView
{
    [self.view addSubview:self.backgroundImgView];
    [self.view addSubview:self.gesturePasswordView];
    [self.view addSubview:self.gestureShowView];
    [self.view addSubview:self.messageLabel];
    [self.view addSubview:self.bottomTipLabel];
}

#pragma mark - delegate
- (void)gesturePasswordView:(XDGestureView *)passwordView didStartedWithSequence:(NSUInteger)sequence
{
    if (self.tempPassword) {
        [self setMessageTip:kVerifyTip];
    }else{
        [self.gestureShowView reset];
        [self setMessageTip:kInputingTip];
    }
    
}

- (void)gesturePasswordView:(XDGestureView *)passwordView didMovedWithTouchedArcs:(char *)touchedArcs
{
    
}

- (void)gesturePasswordView:(XDGestureView *)passwordView didEndInputWithPassword:(NSString *)password touchedCount:(NSUInteger)touchedCount touchedArcs:(char *)touchedArcs sequence:(NSUInteger)sequence
{
    if (touchedCount < kLimitTapCount) {
        self.gesturePasswordView.isError = YES;
        [self setMessageTip:kLessThanFourTapTip];
        return;
    }else
    {
        if (self.tempPassword) {//确认密码
            if ([self.tempPassword isEqualToString:password]) {
                [[NSUserDefaults standardUserDefaults] setObject:password forKey:kXDGesturePWKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                self.tempPassword = nil;
                [self.navigationController popViewControllerAnimated:YES];
            }else
            {
                self.gesturePasswordView.isError = YES;
                self.tempPassword = nil;
                [self setMessageTip:kErrorMessage];
            }
        }else//第一次输入密码
        {
            self.tempPassword = password;
            [self.gestureShowView setTouchedArcs:touchedArcs];
            [self setMessageTip:kVerifyTip];
            [self.gesturePasswordView reset];
            return;
        }
    }
    
    __weak typeof(passwordView) weakpv = passwordView;
    __weak typeof(XDGestureConfigVC *) weakSelf = self;
    __weak typeof(self.gestureShowView) weaksv = self.gestureShowView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"weakpv.sequence == %ld , sequence = %ld",(unsigned long)weakpv.sequence,(unsigned long)sequence);
        if (weakpv.sequence == sequence) {//if not start another gesture
            [weakpv reset];
            [weaksv reset];
            [weakSelf setMessageTip:kInputingTip];
        }
    });
}

#pragma mark - method
- (UIColor *)getMessageTipColor
{
    return self.gesturePasswordView.isError ? UIColorWithRGB(217, 54, 9, 1) : UIColorWithRGB(142, 145, 168, 1);
}

- (void)setMessageTip:(NSString *)tip
{
    self.messageLabel.text      = tip;
    self.messageLabel.textColor = [self getMessageTipColor];
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
    float showViewWidth = (self.view.bounds.size.width / 6);
    float showViewHeight = showViewWidth;
    float showViewX = (self.view.bounds.size.width - showViewWidth) / 2;
    if (!_gestureShowView) {
            _gestureShowView = [[XDGestureView alloc] initWithFrame:CGRectMake(showViewX, top/2, showViewWidth, showViewHeight) isShowView:YES];
        _gestureShowView.backgroundColor = [UIColor clearColor];
    }
    return _gestureShowView;
}

- (UILabel *)messageLabel
{
    float messageLabely = self.gestureShowView.frame.origin.y + self.gestureShowView.frame.size.height;
    if (!_messageLabel) {
        _messageLabel               = [[UILabel alloc] initWithFrame:CGRectMake(0, messageLabely, self.view.bounds.size.width, 30)];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font          = [UIFont systemFontOfSize:16];
        _messageLabel.textColor     = [self getMessageTipColor];
        _messageLabel.text          = kInputingTip;
    }
    return _messageLabel;
}

- (UILabel *)bottomTipLabel
{
    if (!_bottomTipLabel) {
        _bottomTipLabel = [UILabel new];
        _bottomTipLabel.text = kBottomTip;
        _bottomTipLabel.textColor = UIColorWithRGB(142, 145, 168, 1);
        _bottomTipLabel.font = [UIFont systemFontOfSize:13];
        _bottomTipLabel.textAlignment = NSTextAlignmentCenter;
        CGFloat labelY = self.gesturePasswordView.frame.origin.y + self.gesturePasswordView.frame.size.height;
        _bottomTipLabel.frame = CGRectMake(0, labelY, self.view.bounds.size.width, 20);
    }
    return _bottomTipLabel;
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
