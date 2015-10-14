//
//  XDGestureView.h
//  XDGesturePassword
//
//  Created by wenjunhuang on 15/10/14.
//  Copyright © 2015年 wenjunhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XDGestureView;

@protocol XDGestureViewDelegate <NSObject>

@optional;
- (void)gesturePasswordView:(XDGestureView*) passwordView didStartedWithSequence:(NSUInteger) sequence;
- (void)gesturePasswordView:(XDGestureView*) passwordView didMovedWithActiveCircle:(char *)active;
- (void)gesturePasswordView:(XDGestureView*) passwordView didEndInputWithPassword:(NSString*) password touchedCount:(NSUInteger)touchedCount sequence:(NSUInteger) sequence;
@end

@interface XDGestureView : UIView
- (instancetype)initWithFrame:(CGRect)frame isShowView:(BOOL)isShowView;
- (void)setAcitveCircle:(char *)activeCircle;
- (UIColor *)getSelectedColor;
- (void)reset;

@property (nonatomic, assign) id<XDGestureViewDelegate> delegate;
@property (nonatomic, assign) BOOL isError;
@property (nonatomic, assign, readonly) NSUInteger sequence;
@end
