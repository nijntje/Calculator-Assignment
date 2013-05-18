//
//  GraphView.m
//  Calculator
//
//  Created by danielle vass on 09/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "CalculatorBrain.h"
#import "AxesDrawer.h"

@implementation GraphView


@synthesize dataSource = _dataSource;
@synthesize scale = _scale;
@synthesize origin = _origin;

#define DEFAULT_SCALE 1.0

- (CGFloat)scale
{
    if (!_scale) {
        return DEFAULT_SCALE; // don't allow zero scale
    } else {
        return _scale;
    }
}

- (void)setScale:(CGFloat)scale
{
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay]; // any time our scale changes, call for redraw
    }
}

- (void)setOrigin:(CGPoint)origin {
    if (origin.x != _origin.x || origin.y != _origin.y) {
        _origin = origin;
        [self setNeedsDisplay];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithFloat:origin.x] forKey:@"origin.x"];
        [defaults setObject:[NSNumber numberWithFloat:origin.y] forKey:@"origin.y"];
        [defaults synchronize];
    }
}

- (CGPoint)origin {
    if (!_origin.x && !_origin.y) {
        CGPoint origin;
        origin.x = self.bounds.origin.x + self.bounds.size.width / 2;
        origin.y = self.bounds.origin.y + self.bounds.size.height / 2;
        return origin;
    } else {
        return _origin;
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
        //[self setNeedsDisplay];
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        
        CGPoint translation = [gesture translationInView:self];
        
        self.origin = CGPointMake(self.origin.x + translation.x, self.origin.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self];
    }
    
}

- (void)tap:(UITapGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.origin = [gesture locationInView:[gesture view]];

    }
}

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw; 
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; // get initialized if someone uses alloc/initWithFrame: to create us
    }
    return self;
}

- (void)drawCircleAtPoint:(CGPoint)p withRadius:(CGFloat)radius inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES); // 360 degree (0 to 2pi) arc
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}

- (float)untranslateX:(float)x {
    float transformX = x - self.origin.x;
    float scaleX = transformX / self.scale;
    return scaleX;
}

- (float)translateY:(float)y {
    float scaleY = y * self.scale;
    float transformY = self.origin.y - scaleY;
    return transformY;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint midPoint; // center of our bounds in our coordinate system
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2;
    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2;
    
    CGFloat size = self.bounds.size.width / 2;
    if (self.bounds.size.height < self.bounds.size.width) size = self.bounds.size.height / 2;
    size *= self.scale; // scale is percentage of full view size
    
    
    CGContextSetLineWidth(context, 1.0);
    [[UIColor darkGrayColor] setStroke];
    
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    [[UIColor redColor] setStroke];
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, 0, [self translateY:[self.dataSource functionX:[self untranslateX:0] forGraphView:self]]);
    for (int i = 0; i < self.bounds.size.width * [self contentScaleFactor]; i++) {
        CGContextAddLineToPoint(context, i, [self translateY:[self.dataSource functionX:[self untranslateX:i] forGraphView:self]]);
    }


    CGContextStrokePath(context);
}



@end
