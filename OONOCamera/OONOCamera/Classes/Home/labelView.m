//
//  labelView.m
//  duang
//
//  Created by jianzhong on 16/1/5.
//  Copyright © 2016年 jianzhong. All rights reserved.
//

#import "labelView.h"

@implementation labelView

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)createViewFrame:(NSArray *)tagArray title:(NSString *)topTitle
{
    self.tagArr = [NSArray arrayWithArray:tagArray];
    
    NSLog(@"tagArray== %@",tagArray);
    
    CGFloat downMennBtnW = 50;
    CGFloat margin = (AppWidth-downMennBtnW*4)/5;

    for(int i=0;i < tagArray.count;i++)
    {
        UIButton *iconButton=[UIButton buttonWithType:UIButtonTypeCustom];
        iconButton.tag=20000+i;
        iconButton.backgroundColor = [UIColor blackColor];
        iconButton.layer.masksToBounds = YES;
        iconButton.layer.cornerRadius = 2.0f;
        [iconButton setImage:[UIImage imageNamed:[tagArray objectAtIndex:i]] forState:UIControlStateNormal];
        [iconButton addTarget:self action:@selector(selTagClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:iconButton];
        
        if (i>3)
        {
            iconButton.frame=CGRectMake(25+(i-4)*(margin+downMennBtnW), 80, downMennBtnW, downMennBtnW);
        }
        else
        {
            iconButton.frame=CGRectMake(25+i*(margin+downMennBtnW), 10, downMennBtnW, downMennBtnW);
        }
    }
}

-(void)selTagClick:(UIButton *)btn
{
    NSString *selTag  =[self.tagArr objectAtIndex:btn.tag - 20000];
    [self.addTagDelegate didAddTagClick:selTag];
}


@end
