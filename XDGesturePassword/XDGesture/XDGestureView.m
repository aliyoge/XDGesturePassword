//
//  XDGestureView.m
//  XDGesturePassword
//
//  Created by wenjunhuang on 15/10/14.
//  Copyright © 2015年 wenjunhuang. All rights reserved.
//

#import "XDGestureView.h"

const static char kGesutreSecurityKey = 0x50;

static inline UIColor*
UIColorWithRGB(float r, float g, float b, float a)
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

@interface XDGestureView ()
{
    CGPoint* _arcCenters;
    char  _touchedArcs[10];
}
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat margin;

@property (nonatomic, strong) UIColor *arcColor;
@property (nonatomic, strong) UIColor *touchedColor;
@property (nonatomic, strong) UIColor *errorColor;

@property (nonatomic, assign) CGPoint curPoint;

@property (nonatomic, assign) BOOL isShowView;
@end

@implementation XDGestureView

- (void)dealloc
{
//    free(_touchedArcs);
    free(_arcCenters);
}

- (instancetype)initWithFrame:(CGRect)frame isShowView:(BOOL)isShowView
{
    self = [self initWithFrame:frame];
    if (self) {
        self.isShowView = isShowView;
        if (isShowView) self.userInteractionEnabled = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.margin       = frame.size.width / 10;
        self.radius       = self.margin;
        self.arcColor     = UIColorWithRGB(142, 145, 168, 1);
        self.touchedColor = UIColorWithRGB(95, 168, 252, 1);
        self.errorColor   = UIColorWithRGB(217, 54, 9, 1);
        _sequence = 0;
        
        _arcCenters = (CGPoint*) malloc(sizeof(CGPoint) * 9);
        memset(_arcCenters, 0, sizeof(CGPoint) * 9);
        
        for (int i=0; i<9; i++) {
            CGPoint *p = (_arcCenters + i);
            (*p).x = (i % 3) * (self.radius * 2 + self.margin) + self.margin + self.radius;
            (*p).y = (i / 3) * (self.radius * 2 + self.margin) + self.margin + self.radius;
        }
        [self resetTouchedArcs];
    }
    return self;
}

#pragma mark - action
- (void)drawRect:(CGRect)rect
{
    for (int i=0; i<9; i++) {
        UIBezierPath *arcNormerPath = [UIBezierPath bezierPathWithArcCenter:*(_arcCenters+i) radius:self.radius startAngle:0 endAngle:M_PI*2 clockwise:NO];
        [arcNormerPath setLineWidth:1];
        if ([self getArcTouchedOrderWithArcNumber:i] >= 0) {
            [[self getSelectedColor] setStroke];
            [[self getSelectedColor] setFill];
            if (self.isShowView) {
                [[UIBezierPath bezierPathWithArcCenter:*(_arcCenters+i) radius:self.radius startAngle:0 endAngle:M_PI*2 clockwise:NO] fill];
            }else{
                [[UIBezierPath bezierPathWithArcCenter:*(_arcCenters+i) radius:self.radius/3 startAngle:0 endAngle:M_PI*2 clockwise:NO] fill];
            }
        }else{
            [self.arcColor setStroke];
        }
        [arcNormerPath stroke];
    }
    int firstTouchedArcNumber = _touchedArcs[0] - kGesutreSecurityKey;
    if (firstTouchedArcNumber < 0 ) return;
    
    UIBezierPath *linePath = [[UIBezierPath alloc] init];
    [linePath setLineWidth:1];
    [linePath moveToPoint:*(_arcCenters + firstTouchedArcNumber)];
    for (int i=0; i<9; i++) {
        if (_touchedArcs[i] >= kGesutreSecurityKey) {
            int arcNumber = _touchedArcs[i] - kGesutreSecurityKey;
            [linePath addLineToPoint:*(_arcCenters + arcNumber)];
        }else{
            break;
        }
    }
    
    if (!CGPointEqualToPoint(CGPointZero, self.curPoint)) {
        [linePath addLineToPoint:self.curPoint];
    }
    
    [[self getSelectedColor] setStroke];
    
    if (!self.isShowView) {
        [linePath stroke];
    }
}

#pragma mark - touchs
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    ++ _sequence;
    
    [self resetTouchedArcs];
    
    if ([self.delegate respondsToSelector:@selector(gesturePasswordView:didStartedWithSequence:)]) {
        [self.delegate gesturePasswordView:self didStartedWithSequence:_sequence];
    }
    
    UITouch *touch = [touches anyObject];
    if (!touch) return;
    
    CGPoint point = [touch locationInView:self];
    for (int i=0; i<9; i++) {
        if ([self isInArc:point arcCenter:*(_arcCenters + i) arcRadius:self.radius]) {
            [self setArcTouchedWithArcNumber:i];
            [self setNeedsDisplay];
            break;
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (!touch) return;
    
    CGPoint point = [touch locationInView:self];
    
    int latestTouchedArcNmuber = [self lastTouchedArcNmuber];
    if (latestTouchedArcNmuber > -1) {
        [self setMiddlePointTouched:*(_arcCenters + latestTouchedArcNmuber) curPoint:point];
    }
    
    for (int i=0; i<9; i++) {
        if ([self isInArc:point arcCenter:_arcCenters[i] arcRadius:self.radius] && [self getArcTouchedOrderWithArcNumber:i] == -1) {
            [self setArcTouchedWithArcNumber:i];
            break;
        }
    }
    
    _curPoint.x = point.x;
    _curPoint.y = point.y;
    [self setNeedsDisplay];
    
    if ([self.delegate respondsToSelector:@selector(gesturePasswordView:didMovedWithTouchedArcs:)]) {
        [self.delegate gesturePasswordView:self didMovedWithTouchedArcs:_touchedArcs];
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(gesturePasswordView:didEndInputWithPassword:touchedCount:touchedArcs:sequence:)]) {
        NSString *passwordStr = [NSString stringWithUTF8String:_touchedArcs];
        [self.delegate gesturePasswordView:self didEndInputWithPassword:passwordStr touchedCount:[self getTouchedCount] touchedArcs:_touchedArcs sequence:_sequence];
    }
    _curPoint.x = _curPoint.y = 0;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - method
- (BOOL)isInArc:(CGPoint)point arcCenter:(CGPoint)arcCenter arcRadius:(CGFloat)arcRadius
{
    CGFloat aline = fabs(arcCenter.x - point.x);
    CGFloat bline = fabs(arcCenter.y - point.y);
    if (aline > arcRadius || bline > arcRadius) {
        return NO;
    }
    CGFloat cline = sqrt(pow(aline, 2) + pow(bline, 2));
    return cline <= arcRadius;
}

- (void)resetTouchedArcs
{
    self.isError = NO;
    self.curPoint = CGPointMake(0, 0);
    
    memset(&_touchedArcs, 0, sizeof(char) * 10);
    
    if (self.superview) {
        [self setNeedsDisplay];
    }
}

- (void)setArcTouchedWithArcNumber:(int)number
{
    for (int i=0; i<9; i++) {
        if (_touchedArcs[i] == 0) {
            _touchedArcs[i] = number + kGesutreSecurityKey;
            break;
        }
    }
    _curPoint.x = _curPoint.y = 0;
}

- (int)getArcTouchedOrderWithArcNumber:(int)arcNumber
{
    if (_touchedArcs[0] == 0) return -1;
    int touchedOrder = -1;
    for (int i = 0; i<9; i++) {
        if (_touchedArcs[i] - kGesutreSecurityKey == arcNumber) {
            touchedOrder = i;
            break;
        }
    }
    return touchedOrder;
}

- (void)setMiddlePointTouched:(CGPoint)latestCenter curPoint:(CGPoint)curPoint
{
    CGPoint middlePoint;
    middlePoint.x = (latestCenter.x + curPoint.x) / 2;
    middlePoint.y = (latestCenter.y + curPoint.y) / 2;
    for (int i=0; i<9; i++) {
        if ([self isInArc:middlePoint arcCenter:*(_arcCenters + i) arcRadius:self.radius] && [self getArcTouchedOrderWithArcNumber:i] == -1) {
            [self setArcTouchedWithArcNumber:i];
            [self setNeedsDisplay];
            break;
        }
    }
}

- (void)reset
{
    [self resetTouchedArcs];
}

- (void)setIsError:(BOOL)isError
{
    _isError = isError;
    [self setNeedsDisplay];
}

- (void)setTouchedArcs:(char *)tocuhedArcs
{
    int count = sizeof(_touchedArcs) /sizeof(char);
    for (int i=0; i <count; i++) {
        *(_touchedArcs+i) = *(tocuhedArcs +i);
    }
    [self setNeedsDisplay];
}

#pragma mark - getter
- (int)lastTouchedArcNmuber
{
    if (_touchedArcs[0] == 0) return -1;
    
    int arcNmuber = -1;
    for (int i=0; i<9; i++) {
        if (_touchedArcs[i] == 0) {
            arcNmuber = _touchedArcs[i -1] - kGesutreSecurityKey;
            break;
        }
    }
    return arcNmuber;
}

- (int)getTouchedCount
{
    if (_touchedArcs[0] == 0) return 0;
    int touchedCount = 0;
    for (int i=0; i<9; i++) {
        if (_touchedArcs[i] == 0) {
            touchedCount = i;
            break;
        }
        if (i == 8) {
            touchedCount = 9;
        }
    }
    return touchedCount;
}

- (UIColor *)getSelectedColor
{
    return _isError ? self.errorColor : self.touchedColor;
}
@end
