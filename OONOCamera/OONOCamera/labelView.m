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
-(void)createViewFram:(NSArray *)tagArray title:(NSString *)topTitle
{
    for(UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    self.tagArr = [NSArray arrayWithArray:tagArray];
    self.backgroundColor = DAColor(20, 20, 20);
    NSLog(@"tagArray== %@",tagArray);
    if(topTitle.length == 0)
    {
        topTitle = @"标签";
    }
    UIImageView *iconImg = [[UIImageView alloc] init];
    iconImg.frame = CGRectMake(10, 10, 7, 7);
    iconImg.backgroundColor = DAColor(128, 129, 130);
    iconImg.layer.cornerRadius = 7/2.0f;
    iconImg.layer.masksToBounds = YES;
    [self addSubview:iconImg];
    
    NSInteger viewY = 10-7/2.0;

    UILabel *historicalLabel = [[UILabel alloc]  init];
    historicalLabel.frame = CGRectMake(20, viewY, 100, 14);
    historicalLabel.text = topTitle;
    historicalLabel.textAlignment = NSTextAlignmentLeft;
    historicalLabel.font=[UIFont fontWithName:@"RTWSYueGoG0v1-Light" size:13];
    historicalLabel.textColor = DAColor(148, 148, 148);
    [self addSubview:historicalLabel];
    
    NSInteger viewW = 10;
    NSDictionary *nameDic = @{NSFontAttributeName:[UIFont fontWithName:@"RTWSYueGoG0v1-Light" size:13]};
    viewY += 24;
    for(int i=0;i < tagArray.count;i++)
    {
        NSString *userStr = [NSString stringWithFormat:@"%@",[tagArray objectAtIndex:i]];
        NSLog(@"tag == %@",userStr);
        if(userStr.length == 0 || [userStr isEqualToString:@"(null)"])
        {
            continue;
        }
        CGSize userSize=[userStr boundingRectWithSize:CGSizeMake(304,0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:nameDic context:nil].size;
        userSize.width += 20;
        
        UIButton *userButton=[UIButton buttonWithType:UIButtonTypeCustom];
        userButton.tag=20000+i;
        userButton.titleLabel.font=[UIFont fontWithName:@"RTWSYueGoG0v1-Light" size:13];
        [userButton setTitle:userStr forState:UIControlStateNormal];
        [userButton setTitleColor:DAColor(148, 148, 148) forState:UIControlStateNormal];
        userButton.backgroundColor = [UIColor clearColor];
        userButton.layer.masksToBounds = YES;
        userButton.layer.cornerRadius = 2.0f;
        userButton.backgroundColor = DAColor(50, 50, 50);
        [userButton addTarget:self action:@selector(selTagClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:userButton];
        
        if(viewW + userSize.width > 304)
        {
            viewW =10;
            viewY += 40-4;
            userButton.frame=CGRectMake(viewW, viewY, userSize.width, 24);
            viewW += userSize.width+12;
        }
        else
        {
            userButton.frame=CGRectMake(viewW, viewY, userSize.width, 24);
            viewW += userSize.width+12;
        }
    }
    viewY += 36;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 320, viewY);
}
-(void)selTagClick:(UIButton *)btn
{
    NSString *selTag  =[self.tagArr objectAtIndex:btn.tag - 20000];
    [self.addTagDelegate didAddTagClick:selTag];
}


@end
