//
//  MyNavigationView.h
//  RedEnvelope
//
//  Created by 史建忠 on 16/9/5.
//  Copyright © 2016年 史建忠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyNavigationView : UIView

@property(nonatomic,strong)UIButton *listButton;
@property(nonatomic,strong)UIButton *rightBtn;
@property(strong,nonatomic)UILabel *label;
@property(nonatomic,strong)UIImageView *megImg;
// 显示两个按钮
- (void)createMyNavigationBarWithBackGroundImage:(UIImage *)backgroundImage andTitle:(NSString *)title andLeftBBIImage:(UIImage *)leftBBIImage andLeftBBITitle:(NSString *)leftBBITitle andRightBBIImage:(UIImage *)rightBBIImage andRightBBITitle:(NSString *)rightBBITitle  andSEL:(SEL)sel andClass:(id)classObject;

@end
