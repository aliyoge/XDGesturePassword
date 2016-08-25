//
//  XDGestureHomeVC.m
//  XDGesturePassword
//
//  Created by wenjunhuang on 15/10/15.
//  Copyright © 2015年 wenjunhuang. All rights reserved.
//

#import "XDGestureHomeVC.h"
#import "XDGestureConfigVC.h"
#import "XDGestureLoginVC.h"

@interface XDGestureHomeVC ()
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *setPWBtn;
@end

@implementation XDGestureHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.loginBtn];
    [self.view addSubview:self.setPWBtn];
}

#pragma mark - action
- (void)btnClicked:(UIButton *)btn
{
    if (btn == self.loginBtn) {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kXDGesturePWKey]) {
            UIAlertView *alertView = [UIAlertView new];
            alertView.title = @"提示";
            alertView.message = @"请先设置手势密码！";
            [alertView addButtonWithTitle:@"取消"];
            [alertView show];
            return;
        }
        [self presentViewController:[XDGestureLoginVC new] animated:YES completion:nil];
    }
    else
    {
        [self.navigationController pushViewController:[XDGestureConfigVC new] animated:YES];
    }
}

#pragma mark - getter
- (UIButton *)loginBtn
{
    if (!_loginBtn) {
        _loginBtn = [UIButton new];
        [_loginBtn setTitle:@"手势解锁" forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_loginBtn setBackgroundColor:[UIColor orangeColor]];
        [_loginBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat _loginBtnW = 80;
        CGFloat _loginBtnH = 30;
        CGFloat _loginBtnX = 50;
        CGFloat _loginBtnY = self.view.frame.size.height * 0.5;
        _loginBtn.frame  = CGRectMake(_loginBtnX, _loginBtnY, _loginBtnW, _loginBtnH);
    }
    return _loginBtn;
}

- (UIButton *)setPWBtn
{
    if (!_setPWBtn) {
        _setPWBtn = [UIButton new];
        [_setPWBtn setTitle:@"设置手势" forState:UIControlStateNormal];
        [_setPWBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_setPWBtn setBackgroundColor:[UIColor orangeColor]];
        [_setPWBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat _setPWBtnW = 80;
        CGFloat _setPWBtnH = 30;
        CGFloat _setPWBtnX = self.view.frame.size.width - 80 - 30;
        CGFloat _setPWBtnY = self.view.frame.size.height * 0.5;
        _setPWBtn.frame  = CGRectMake(_setPWBtnX, _setPWBtnY, _setPWBtnW, _setPWBtnH);
    }
    return _setPWBtn;
}

@end
