//
//  XDGestureLoginVC.m
//  XDGesturePassword
//
//  Created by wenjunhuang on 15/10/15.
//  Copyright © 2015年 wenjunhuang. All rights reserved.
//

#import "XDGestureLoginVC.h"

static NSUInteger const kLimitTapCount      = 4;
static NSString*  const kInputingTip        = @"请输入手势密码";
static NSString*  const kLessThanFourTapTip = @"至少连接4个点, 请重新输入";

static inline UIColor*
UIColorWithRGB(float r, float g, float b, float a)
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

@interface XDGestureLoginVC ()<XDGestureViewDelegate>
@property (nonatomic, strong) UIImageView   *backgroundImgView;
@property (nonatomic, strong) UIImageView   *headerView;
@property (nonatomic, strong) UILabel       *userNameLabel;
@property (nonatomic, strong) UILabel       *messageLabel;
@property (nonatomic, strong) UIButton      *forgetBtn;
@property (nonatomic, strong) UIButton      *changeLoginBtn;
@property (nonatomic, strong) XDGestureView *gesturePasswordView;
@property (nonatomic, assign) NSUInteger    errorCount;
@end

@implementation XDGestureLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView
{
    [self.view addSubview:self.backgroundImgView];
    [self.view addSubview:self.gesturePasswordView];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.userNameLabel];
    [self.view addSubview:self.messageLabel];
    [self.view addSubview:self.forgetBtn];
    [self.view addSubview:self.changeLoginBtn];
}

#pragma mark - delegate
- (void)gesturePasswordView:(XDGestureView *)passwordView didStartedWithSequence:(NSUInteger)sequence
{
    
}

- (void)gesturePasswordView:(XDGestureView *)passwordView didMovedWithTouchedArcs:(char *)touchedArcs
{
    
}

- (void)gesturePasswordView:(XDGestureView *)passwordView didEndInputWithPassword:(NSString *)password touchedCount:(NSUInteger)touchedCount touchedArcs:(char *)touchedArcs sequence:(NSUInteger)sequence
{

    NSString *gesturePW = [[NSUserDefaults standardUserDefaults] objectForKey:kXDGesturePWKey];
    __weak typeof(passwordView) weakpv = passwordView;
    __weak typeof(XDGestureLoginVC *) weakSelf = self;
    
    if (touchedCount > 0) {
        if (touchedCount < kLimitTapCount) {
            self.gesturePasswordView.isError = YES;
            [self setMessageTip:kLessThanFourTapTip];
        }else{
            if ([gesturePW isEqualToString:password]) {
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            }else{
                ++ _errorCount;
                if (_errorCount < 5) {
                    NSString *errorCountTip = [NSString stringWithFormat:@"输错%ld次, 您还可以重试%ld次",_errorCount,5-_errorCount];
                    self.gesturePasswordView.isError = YES;
                    [self setMessageTip:errorCountTip];
                }else{
                    UIAlertView *alertView = [UIAlertView new];
                    alertView.title = @"提示";
                    alertView.message = @"已经输错5次, 请采用其他登录方式！";
                    [alertView addButtonWithTitle:@"确定"];
                    [alertView show];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"weakpv.sequence == %ld , sequence = %ld",(unsigned long)weakpv.sequence,(unsigned long)sequence);
        if (weakpv.sequence == sequence) {//2秒后没有进行下一次输入，重置。
            [weakpv reset];
            [weakSelf setMessageTip:kInputingTip];
        }
    });
}

#pragma mark - action
- (void)forgetBtnClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeLoginBtnClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - method
- (void)setMessageTip:(NSString *)tip
{
    self.messageLabel.text      = tip;
    self.messageLabel.textColor = [self getMessageTipColor];
}

- (UIColor *)getMessageTipColor
{
    return self.gesturePasswordView.isError ? UIColorWithRGB(217, 54, 9, 1) : UIColorWithRGB(142, 145, 168, 1);
}

#pragma mark - getter
- (UIImageView *)headerView
{
    if (!_headerView) {
        _headerView = [UIImageView new];
        _headerView.image = [UIImage imageNamed:@"pop"];
        _headerView.contentMode = UIViewContentModeScaleAspectFill;
        CGFloat _headerViewW = self.view.frame.size.height * 0.15;
        CGFloat _headerViewH = _headerViewW;
        CGFloat _headerViewX = (self.view.frame.size.width - _headerViewW) * 0.5;
        CGFloat _headerViewY = (self.view.bounds.size.height - self.view.bounds.size.width)/5.0;
        _headerView.frame  = CGRectMake(_headerViewX, _headerViewY, _headerViewW, _headerViewH);
    }
    return _headerView;
}

- (UILabel *)userNameLabel
{
    if (!_userNameLabel) {
        _userNameLabel = [UILabel new];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.font = [UIFont boldSystemFontOfSize:16];
        _userNameLabel.textColor = UIColorWithRGB(142, 145, 168, 1);
        _userNameLabel.text = @"hanxinbank";
        CGFloat _userNameLabelW = self.view.frame.size.width;
        CGFloat _userNameLabelH = 20;
        CGFloat _userNameLabelX = 0;
        CGFloat _userNameLabelY = self.headerView.frame.origin.y + self.headerView.frame.size.height + 3;
        _userNameLabel.frame  = CGRectMake(_userNameLabelX, _userNameLabelY, _userNameLabelW, _userNameLabelH);
    }
    return _userNameLabel;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [UILabel new];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font          = [UIFont systemFontOfSize:16];
        _messageLabel.textColor     = [self getMessageTipColor];
        _messageLabel.text          = kInputingTip;
        CGFloat _messageLabelW = self.view.frame.size.width;
        CGFloat _messageLabelH = 20;
        CGFloat _messageLabelX = 0;
        CGFloat _messageLabelY = self.userNameLabel.frame.origin.y + self.userNameLabel.frame.size.height + 5;
        _messageLabel.frame  = CGRectMake(_messageLabelX, _messageLabelY, _messageLabelW, _messageLabelH);
    }
    return _messageLabel;
}

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

- (UIButton *)forgetBtn
{
    if (!_forgetBtn) {
        _forgetBtn = [UIButton new];
        _forgetBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_forgetBtn setTitle:@"忘记手势密码?" forState:UIControlStateNormal];
        [_forgetBtn setTitleColor:UIColorWithRGB(142, 145, 168, 1) forState:UIControlStateNormal];
        [_forgetBtn addTarget:self action:@selector(forgetBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        CGFloat _forgetBtnW = 100;
        CGFloat _forgetBtnH = 20;
        CGFloat _forgetBtnX = 20;
        CGFloat _forgetBtnY = self.gesturePasswordView.frame.origin.y + self.gesturePasswordView.frame.size.height;
        _forgetBtn.frame  = CGRectMake(_forgetBtnX, _forgetBtnY, _forgetBtnW, _forgetBtnH);
    }
    return _forgetBtn;
}

- (UIButton *)changeLoginBtn
{
    if (!_changeLoginBtn) {
        _changeLoginBtn = [UIButton new];
        _changeLoginBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_changeLoginBtn setTitle:@"切换登录方式" forState:UIControlStateNormal];
        [_changeLoginBtn setTitleColor:UIColorWithRGB(142, 145, 168, 1) forState:UIControlStateNormal];
        [_changeLoginBtn addTarget:self action:@selector(changeLoginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        CGFloat _changeLoginBtnW = 100;
        CGFloat _changeLoginBtnH = 20;
        CGFloat _changeLoginBtnX = self.view.frame.size.width - 100 - 20;
        CGFloat _changeLoginBtnY = self.gesturePasswordView.frame.origin.y + self.gesturePasswordView.frame.size.height;
        _changeLoginBtn.frame  = CGRectMake(_changeLoginBtnX, _changeLoginBtnY, _changeLoginBtnW, _changeLoginBtnH);
    }
    return _changeLoginBtn;
}

@end
