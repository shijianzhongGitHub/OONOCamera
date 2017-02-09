//
//  PhotoEditingViewController.h
//  PhotoEditFramework
//
//  Created by Cc on 14-7-30.
//  Copyright (c) 2014年 Cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class pg_edit_sdk_controller_object;

/////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol pg_edit_sdk_controller_delegate <NSObject>

/**
 *  完成后调用，点击保存，object 是 pg_edit_sdk_controller_object 对象
 *  Invoke after completion, click save, object's target is pg_edit_sdk_controller_object
 */
- (void)dgPhotoEditingViewControllerDidFinish:(UIViewController *)pController
                                       object:(pg_edit_sdk_controller_object *)object;

/**
 *  完成后调用，点击取消
 *  Invoke after completion, click cancel
 */
- (void)dgPhotoEditingViewControllerDidCancel:(UIViewController *)pController withClickSaveButton:(BOOL)isClickSaveBtn;

@optional

/**
 *  当需要长时间等待时会调用此接口，如果没有实现此协议，那么将用默认系统Loading代替，开始Loading回调
 *  This interface is invoked when waiting for long periods of time, if you did not implement this protocol, it will be replaced by system default Loading, start Loading callback
 */
- (void)dgPhotoEditingViewControllerShowLoadingView:(UIView*)view;

/**
 *  当需要长时间等待结束时会调用此接口，如果没有实现此协议，那么将用默认系统Loading代替，结束Loading回调
 *  This interface is invoked when waiting for long periods of time to end, if you did not implement this protocol, it will be replaced by system default Loading, end Loading callback
 */
- (void)dgPhotoEditingViewControllerHideLoadingView:(UIView*)view;

@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface pg_edit_sdk_controller : UIViewController

@property (nonatomic,weak,readonly) id<pg_edit_sdk_controller_delegate> pDelegate;

    /**
     *  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
     *  方法中调用此方法
     *  Method will invoke this method
     */
    + (BOOL)sStart:(NSString *)key;

    /**
     *  获取SDK作图引用计数
     */
    + (NSNumber *)sGotSDKReferenceCount;


/**
 *  初始化
 *  Initialize
 */
- (instancetype)initWithEditObject:(pg_edit_sdk_controller_object *)object
                      withDelegate:(id<pg_edit_sdk_controller_delegate>)delegate;


@end
/////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface pg_edit_sdk_controller_object : NSObject

////////////////////////////// 输入   Input

/**
 *  输入原图
 *  Input original
 */
@property (nonatomic,strong) UIImage *pCSA_fullImage;

////////////////////////////// 输出   Output

/**
 *  输出效果原图
 *  Output effect original
 */
@property (nonatomic,strong) NSData *pOutEffectOriData;

/**
 *  输出效果小图
 *  Output effect thumbnail
 */
@property (nonatomic,strong) NSData *pOutEffectDisplayData;

@end
