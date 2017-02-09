//
//  labelView.h
//  duang
//
//  Created by jianzhong on 16/1/5.
//  Copyright © 2016年 jianzhong. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol addTagDelegate

-(void)didAddTagClick:(NSString *)tagName;

@end

@interface labelView : UIView
@property(nonatomic,strong)NSArray *tagArr;
@property(nonatomic,assign)id<addTagDelegate>addTagDelegate;
-(void)createViewFrame:(NSArray *)tagArray title:(NSString *)topTitle;
@end
