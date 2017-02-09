//
//  UIButton+DJBlock.h
//  TableViewCDemo
//
//  Created by Jason on 6/1/16.
//  Copyright © 2016年 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (DJBlock)
- (void)addActionBlock:(void(^)(id sender))block forControlEvents:(UIControlEvents )event;
@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com