//
//  ZDStickerView.h
//
//  Created by 史建忠 on 16/8/31.
//  Copyright © 2016年 史建忠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPGripViewBorderView.h"

@protocol DragViewDelegate;

@interface DragView : UIView
{
    SPGripViewBorderView *borderView;
}

@property (assign, nonatomic) UIView *contentView;
@property (nonatomic) BOOL preventsPositionOutsideSuperview; //default = YES
@property (nonatomic) BOOL preventsResizing; //default = NO
@property (nonatomic) BOOL preventsDeleting; //default = NO
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;

@property (strong, nonatomic) id <DragViewDelegate> delegate;

- (void)hideDelHandle;
- (void)showDelHandle;
- (void)hideEditingHandles;
- (void)showEditingHandles;

@end

@protocol DragViewDelegate <NSObject>
@required
@optional
- (void)stickerViewDidBeginEditing:(DragView *)sticker;
- (void)stickerViewDidEndEditing:(DragView *)sticker;
- (void)stickerViewDidCancelEditing:(DragView *)sticker;
- (void)stickerViewDidClose:(DragView *)sticker;
@end


