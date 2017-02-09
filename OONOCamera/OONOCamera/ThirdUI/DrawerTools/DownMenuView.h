//
//  DownMenuView.h
//  OONOCamera
//
//  Created by 史建忠 on 16/8/31.
//  Copyright © 2016年 史建忠. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    DownViewStateUp = 0,
    DownViewStateDown
}DownViewState;

@interface DownMenuView : UIView<UIGestureRecognizerDelegate>
{
    UIImageView *arrow;         //向上拖拽时显示的图片    
 
    CGPoint upPoint;            //抽屉拉出时的中心点
    CGPoint downPoint;          //抽屉收缩时的中心点
    
    UIView *parentView;         //抽屉所在的view
    UIView *contentView;        //抽屉里面显示的内容
    
    DownViewState drawState;  //当前抽屉状态
    
    UIView * coverView;
}

@property (nonatomic,assign)int upOrDown;

- (id)initWithView:(UIView *) contentview parentView :(UIView *) parentview;
- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
- (void)handleTap:(UITapGestureRecognizer *)recognizer;
- (void)transformArrow:(DownViewState) state;

@property (nonatomic,retain) UIView *parentView;
@property (nonatomic,retain) UIView *contentView;
@property (nonatomic,retain) UIImageView *arrow;  
@property (nonatomic) DownViewState drawState;

@end
