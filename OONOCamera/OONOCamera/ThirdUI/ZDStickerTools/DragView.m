//
//  ZDStickerView.m
//
//  Created by 史建忠 on 16/8/31.
//  Copyright © 2016年 史建忠. All rights reserved.
//

#import "DragView.h"
#import <QuartzCore/QuartzCore.h>

#define kSPUserResizableViewGlobalInset 5.0
#define kSPUserResizableViewDefaultMinWidth 48.0
#define kSPUserResizableViewInteractiveBorderSize 0.0
#define kZDStickerViewControlSize 20.0


@interface DragView ()

@property (strong, nonatomic) UIImageView *resizingControl;
@property (strong, nonatomic) UIImageView *deleteControl;

@property (nonatomic) BOOL preventsLayoutWhileResizing;

@property (nonatomic) float deltaAngle;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;

@property (nonatomic) CGPoint touchStart;

@end

@implementation DragView
@synthesize contentView, touchStart;

@synthesize prevPoint;
@synthesize deltaAngle, startTransform; //rotation
@synthesize resizingControl, deleteControl;
@synthesize preventsPositionOutsideSuperview;
@synthesize preventsResizing;
@synthesize preventsDeleting;
@synthesize minWidth, minHeight;


-(void)singleTap:(UIPanGestureRecognizer *)recognizer
{
    if (NO == self.preventsDeleting)
    {
        UIView * close = (UIView *)[recognizer view];
        [close.superview removeFromSuperview];
    }
    
    if([_delegate respondsToSelector:@selector(stickerViewDidClose:)])
    {
        [_delegate stickerViewDidClose:self];
    }
}

-(void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        if (self.bounds.size.width < minWidth || self.bounds.size.width < minHeight)
        {
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     minWidth,
                                     minHeight);
            resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                       self.bounds.size.height-kZDStickerViewControlSize,
                                              kZDStickerViewControlSize,
                                              kZDStickerViewControlSize);
            deleteControl.frame = CGRectMake(0, 0,
                                             kZDStickerViewControlSize, kZDStickerViewControlSize);
            prevPoint = [recognizer locationInView:self];
             
        } else {
            CGPoint point = [recognizer locationInView:self];
            float wChange = 0.0, hChange = 0.0;
            
            wChange = (point.x - prevPoint.x);
            hChange = (point.y - prevPoint.y);
            
            if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
                prevPoint = [recognizer locationInView:self];
                return;
            }
            
            if (YES == self.preventsLayoutWhileResizing) {
                if (wChange < 0.0f && hChange < 0.0f) {
                    float change = MIN(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
                if (wChange < 0.0f) {
                    hChange = wChange;
                } else if (hChange < 0.0f) {
                    wChange = hChange;
                } else {
                    float change = MAX(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
            }
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                                     self.bounds.size.width + (wChange),
                                     self.bounds.size.height + (hChange));
            resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                              self.bounds.size.height-kZDStickerViewControlSize,
                                              kZDStickerViewControlSize, kZDStickerViewControlSize);
            deleteControl.frame = CGRectMake(0, 0,
                                             kZDStickerViewControlSize, kZDStickerViewControlSize);
            prevPoint = [recognizer locationInView:self];
        }
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);
        float angleDiff = deltaAngle - ang;
        if (NO == preventsResizing) {
            self.transform = CGAffineTransformMakeRotation(-angleDiff);
        }
        
        borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
        [borderView setNeedsDisplay];
        
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
}

- (void)setupDefaultAttributes {
    borderView = [[SPGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
    [borderView setHidden:YES];
//    [self addSubview:borderView];
    
    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5) {
        self.minWidth = kSPUserResizableViewDefaultMinWidth;
        self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    } else {
        self.minWidth = self.bounds.size.width*0.5;
        self.minHeight = self.bounds.size.height*0.5;
    }
    self.preventsPositionOutsideSuperview = YES;
    self.preventsLayoutWhileResizing = YES;
    self.preventsResizing = NO;
    self.preventsDeleting = NO;
    
    deleteControl = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,
                                                                 kZDStickerViewControlSize, kZDStickerViewControlSize)];
    deleteControl.backgroundColor = [UIColor clearColor];
    deleteControl.image = [UIImage imageNamed:@"ZDBtn3.png" ];
    deleteControl.alpha = 0.2;
    deleteControl.userInteractionEnabled = YES;
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(singleTap:)];
    [deleteControl addGestureRecognizer:singleTap];
    [self addSubview:deleteControl];
    
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (void)setContentView:(UIView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    
    [self bringSubviewToFront:borderView];
    [self bringSubviewToFront:resizingControl];
    [self bringSubviewToFront:deleteControl];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    
    borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                      self.bounds.size.height-kZDStickerViewControlSize,
                                      kZDStickerViewControlSize,
                                      kZDStickerViewControlSize);
    deleteControl.frame = CGRectMake(0, 0,
                                     kZDStickerViewControlSize, kZDStickerViewControlSize);
    [borderView setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    touchStart = [touch locationInView:self.superview];
    if([_delegate respondsToSelector:@selector(stickerViewDidBeginEditing:)]) {
        [_delegate stickerViewDidBeginEditing:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(stickerViewDidEndEditing:)]) {
        [_delegate stickerViewDidEndEditing:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(stickerViewDidCancelEditing:)]) {
        [_delegate stickerViewDidCancelEditing:self];
    }
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x,
                                    self.center.y + touchPoint.y - touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX) {
            newCenter.x = midPointX;
        }
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY) {
            newCenter.y = midPointY;
        }
    }
    self.center = newCenter;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    [self translateUsingTouchLocation:touch];
    touchStart = touch;
}

- (void)hideDelHandle
{
    deleteControl.hidden = YES;
}

- (void)showDelHandle
{
    deleteControl.hidden = NO;
}

- (void)hideEditingHandles
{
    resizingControl.hidden = YES;
    deleteControl.hidden = YES;
    [borderView setHidden:YES];
}

- (void)showEditingHandles
{
    resizingControl.hidden = NO;
    deleteControl.hidden = NO;
    [borderView setHidden:NO];
}

@end
