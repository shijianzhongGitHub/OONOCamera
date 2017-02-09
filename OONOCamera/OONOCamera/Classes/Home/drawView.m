//
//  drawView.m
//  OONOCamera
//
//  Created by 史建忠 on 16/9/5.
//  Copyright © 2016年 史建忠. All rights reserved.
//

#import "drawView.h"

@implementation drawView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    CGContextRef ctx = UIGraphicsGetCurrentContext();
   static int leftWidth = 20;//左边距
    int length = 40;//角长
    float heightMin = 0.25;//最小比例
    float heightMax = 0.75;//最大比例
    float height = self.frame.size.height;
    float width = self.frame.size.width;
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(ctx, 1);
    
        CGContextAddRect(ctx, CGRectMake(leftWidth, height * heightMin, width - length, height * (heightMax - heightMin)));

          CGContextStrokePath(ctx);
    
    int lineWidth = 4;
    int halfLine = lineWidth/2;
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    
    //左上角水平线
    CGContextMoveToPoint(ctx, leftWidth - halfLine, height * heightMin );
    CGContextAddLineToPoint(ctx, leftWidth + length, height * heightMin );
    //左上角垂直线
    CGContextMoveToPoint(ctx, leftWidth, height * heightMin - halfLine );
    CGContextAddLineToPoint(ctx, leftWidth, height * heightMin + length);
    //左下角水平线
    CGContextMoveToPoint(ctx, leftWidth - halfLine, height * heightMax);
    CGContextAddLineToPoint(ctx, leftWidth + length, height * heightMax );
    //左下角垂直线
    CGContextMoveToPoint(ctx, leftWidth, height * heightMax + halfLine);
    CGContextAddLineToPoint(ctx, leftWidth, height * heightMax - length);
    //右上角水平线
    CGContextMoveToPoint(ctx, width - leftWidth + halfLine, height * heightMin);
    CGContextAddLineToPoint(ctx, width - leftWidth - length, height * heightMin);
    //右上角垂直线
    CGContextMoveToPoint(ctx, width - leftWidth, height * heightMin - halfLine);
    CGContextAddLineToPoint(ctx, width - leftWidth, height * heightMin + length);
    //右下角水平线
    CGContextMoveToPoint(ctx, width - leftWidth + halfLine, height * heightMax );
    CGContextAddLineToPoint(ctx, width - leftWidth - length, height * heightMax );
    //右下角垂直线
    CGContextMoveToPoint(ctx, width - leftWidth,height * heightMax + halfLine);
    CGContextAddLineToPoint(ctx,width - leftWidth, height * heightMax - length);
    CGContextStrokePath(ctx);


}


@end
