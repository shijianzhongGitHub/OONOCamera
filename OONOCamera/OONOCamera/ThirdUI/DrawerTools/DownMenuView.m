//
//  DownMenuView.m
//  OONOCamera
//
//  Created by 史建忠 on 16/8/31.
//  Copyright © 2016年 史建忠. All rights reserved.
//

#import "DownMenuView.h"

@implementation DownMenuView
@synthesize contentView,parentView,drawState;
@synthesize arrow;

- (id)initWithView:(UIView *)contentview parentView :(UIView *)parentview;
{
    self = [super initWithFrame:CGRectMake(0,0,contentview.frame.size.width, contentview.frame.size.height+100)];
    if (self) {
        // Initialization code        
        contentView = contentview;
        parentView = parentview;
        
        self.backgroundColor = [UIColor blackColor];
        coverView = [[UIView alloc] init];
        coverView.userInteractionEnabled = NO;
        coverView.backgroundColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:0.5];
        coverView.frame = CGRectMake(0, 0, AppWidth, 0);
        [self addSubview:coverView];
        
        //一定要开启
        [parentView setUserInteractionEnabled:YES];
        
        //嵌入内容区域的背景
        //下移
        UIImage *drawer_bg = [UIImage imageNamed:@""];
        UIImageView *view_bg = [[UIImageView alloc]initWithImage:drawer_bg];
        [view_bg setFrame:CGRectMake(0,contentview.bounds.size.height/2-80,contentview.frame.size.width, contentview.bounds.size.height+50)];
        [self addSubview:view_bg];
    
        //头部拉拽的区域背景;
        
        //箭头的图片
        //箭头位置在下
        UIImage *drawer_arrow = [UIImage imageNamed:@"downArrow"];
        arrow = [[UIImageView alloc]initWithImage:drawer_arrow];
        [arrow setFrame:CGRectMake(0,0,28,28)];
        arrow.center = CGPointMake(contentview.frame.size.width/2, 266);
        [self addSubview:arrow];
        
        //嵌入内容的UIView
        [contentView setFrame:CGRectMake(0,40,contentview.frame.size.width, contentview.bounds.size.height+40)];
        [self addSubview:contentview];
        
        //单击的手势
        UITapGestureRecognizer *tapRecognize = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downHandleTap:)];
        tapRecognize.numberOfTapsRequired = 1;  
        tapRecognize.delegate = self;  
        [tapRecognize setEnabled :YES];  
        [tapRecognize delaysTouchesBegan];  
        [tapRecognize cancelsTouchesInView];  
        
        [self addGestureRecognizer:tapRecognize];
        
        //设置两个位置的坐标
        upPoint = CGPointMake(parentview.frame.size.width/2, parentview.frame.size.height/4-40);
        downPoint = CGPointMake(parentview.frame.size.width/2, -110);
        self.center = downPoint;
        
        //设置起始状态
        drawState = DownViewStateDown;
    }
    return self;
}
/* 
 *  handleTap 触摸函数 
 *  @recognizer  UITapGestureRecognizer 触摸识别器 
 */
-(void)downHandleTap:(UITapGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.3 delay:0.15 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        if (drawState == DownViewStateDown) {
            self.center = upPoint;
            
            coverView.frame = CGRectMake(0, 0, AppWidth, AppHeigt);
            
            [self transformArrow:DownViewStateUp];
        }else
        {
            self.center = downPoint;
            coverView.frame = CGRectMake(0, 0, AppWidth, 0);
            [self transformArrow:DownViewStateDown];
        }
    } completion:nil];

}
/* 
 *  transformArrow 改变箭头方向
 *  state  DrawerViewState 抽屉当前状态 
 */ 
-(void)transformArrow:(DownViewState)state
{
    [UIView animateWithDuration:0.3 delay:0.35 options:UIViewAnimationOptionCurveEaseOut animations:^{
       if (state == DownViewStateUp){
                arrow.transform = CGAffineTransformMakeRotation(M_PI);
            }else
            {
                 arrow.transform = CGAffineTransformMakeRotation(0);
            }
    } completion:^(BOOL finish){
           drawState = state;
    }];
}


@end
