//
//  UIButton+DJBlock.m
//  TableViewCDemo
//
//  Created by Jason on 6/1/16.
//  Copyright © 2016年 Jason. All rights reserved.
//

#import "UIButton+DJBlock.h"
#import <objc/runtime.h>
static const int block_key;
@interface DJtarget : NSObject
@property (nonatomic,copy)void (^block)(id sender);
@end

@implementation DJtarget
- (void)dealloc
{
    NSLog(@"buttonTarget释放");
}
- (instancetype)initWithBlock:(void(^)(id sender))block
{
    if ([super init]) {
        self.block = [block copy];
    }
    return self;
}
- (void)buttonAction:(id)sender
{
    if (self.block) {
        self.block(sender);
    }
}

@end

@implementation UIButton (DJBlock)
- (void)addActionBlock:(void (^)(id))block forControlEvents:(UIControlEvents )event
{
    if (!block) {
        return;
    }
    [self addtargetBlock:block forControlEvents:event];
    
}
- (void)addtargetBlock:(void(^)(id))block forControlEvents:(UIControlEvents )event
{
    DJtarget *target = [[DJtarget alloc] initWithBlock:block];
    NSMutableArray *targets = [self _dj_allBlockTargets];
    [targets addObject:target];
    [self addTarget:target action:@selector(buttonAction:) forControlEvents:event];
}

- (NSMutableArray *)_dj_allBlockTargets
{
    NSMutableArray *targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com