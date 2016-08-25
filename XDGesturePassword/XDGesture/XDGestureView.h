//
//  XDGestureView.h
//  XDGesturePassword
//
//  Created by wenjunhuang on 15/10/14.
//  Copyright © 2015年 wenjunhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XDGestureView;
static NSString* const kXDGesturePWKey = @"kXDGesturePWKey";

@protocol XDGestureViewDelegate <NSObject>
@optional;
- (void)gesturePasswordView:(XDGestureView*) passwordView didStartedWithSequence:(NSUInteger) sequence;
- (void)gesturePasswordView:(XDGestureView*) passwordView didMovedWithTouchedArcs:(char *)touchedArcs;
- (void)gesturePasswordView:(XDGestureView*) passwordView didEndInputWithPassword:(NSString*) password touchedCount:(NSUInteger)touchedCount touchedArcs:(char *)touchedArcs sequence:(NSUInteger) sequence;
@end

@interface XDGestureView : UIView
- (instancetype)initWithFrame:(CGRect)frame isShowView:(BOOL)isShowView;
- (void)setTouchedArcs:(char *)tocuhedArcs;
- (UIColor *)getSelectedColor;
- (void)reset;

@property (nonatomic, assign) id<XDGestureViewDelegate> delegate;
@property (nonatomic, assign) BOOL isError;
@property (nonatomic, assign, readonly) NSUInteger sequence;
@end
