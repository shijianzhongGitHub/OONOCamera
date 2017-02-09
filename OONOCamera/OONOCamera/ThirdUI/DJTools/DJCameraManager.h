//
//  DJCameraManager.h
//  照相机demo
//
//  Created by Jason on 11/1/16.
//  Copyright © 2016年 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@protocol DJCameraManagerDelegate <NSObject>
@optional
- (void)cameraDidFinishFocus;
- (void)cameraDidStareFocus;
@end
@interface DJCameraManager : NSObject
@property (nonatomic,assign) id<DJCameraManagerDelegate>delegate;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) UIImage * croppedImage;
/**
 *  添加摄像范围到View
 *
 *  @param parent 传进来的parent的大小，就是摄像范围的大小
 */
- (void)configureWithParentLayer:(UIView *)parent;
/**
 *  切换前后镜
 *
 *  @param isFrontCamera
 */
- (void)switchCamera:(BOOL)isFrontCamera didFinishChanceBlock:(void(^)())block;
/**
 *  拍照
 *
 *  @param block 原图 比例图 裁剪图
 */
- (void)takePhotoWithImageBlock:(void(^)(UIImage *originImage,UIImage *scaledImage,UIImage *croppedImage))block;
/**
 *  切换闪光灯模式
 *
 *  @param sender 
 */
- (void)switchFlashMode:(UIButton*)sender;
/**
 *  点击对焦
 *
 *  @param devicePoint 
 */
- (void)focusInPoint:(CGPoint)devicePoint;

/**
 *  开启对焦监听 默认YES
 *
 *  @param  
 */
- (void)setFocusObserver:(BOOL)yes;
@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com