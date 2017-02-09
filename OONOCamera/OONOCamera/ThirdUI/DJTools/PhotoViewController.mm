//
//  PhotoViewController.m
//  照相机demo
//
//  Created by Jason on 11/1/16.
//  Copyright © 2016年 Jason. All rights reserved.
//

#import "PhotoViewController.h"
#import "UIButton+DJBlock.h"

@interface PhotoViewController ()<pg_edit_sdk_controller_delegate>

@end

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.frame = CGRectMake(0, 0, AppWidth, AppHeigt);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 20, 40, 40);
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    __weak typeof(self) weak = self;
//    [button addActionBlock:^(id sender) {
//        [weak dismissViewControllerAnimated:YES completion:nil];
//    } forControlEvents:UIControlEventTouchUpInside];
 
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(AppWidth/4-20, [UIScreen mainScreen].bounds.size.height - 60, 40, 40);
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:editBtn];
    [editBtn addTarget:self action:@selector(editBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(AppWidth-100, [UIScreen mainScreen].bounds.size.height - 60, 40, 40);
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:saveBtn];
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)saveBtnClick
{
    //保存到相册     Save to album
    UIImageWriteToSavedPhotosAlbum(self.image, nil, NULL, NULL);
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"保存成功" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles: nil];
    [alert show];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editBtnClick
{
    NSLog(@"===编辑===");
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self pPushPGEditSDKController];
}

#pragma mark - pg_edit_sdk_controller
- (void)pPushPGEditSDKController
{    
    pg_edit_sdk_controller *editCtl = nil;
    {
        //构建编辑对象    Construct edit target
        pg_edit_sdk_controller_object *obje = [[pg_edit_sdk_controller_object alloc] init];
        {
            //输入原图  Input original
            
            //            obje.pCSA_fullImage = [self.mV_displayImageView.mOrigImage copy];
            obje.pCSA_fullImage = _image;
        }
        editCtl = [[pg_edit_sdk_controller alloc] initWithEditObject:obje withDelegate:self];
    }
    NSAssert(editCtl, @"Error");
    if (editCtl)
    {
        [self.navigationController pushViewController:editCtl animated:YES];
    }
}

- (void)dgPhotoEditingViewControllerDidCancel:(UIViewController *)pController withClickSaveButton:(BOOL)isClickSaveBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dgPhotoEditingViewControllerDidFinish:(UIViewController *)pController
                                       object:(pg_edit_sdk_controller_object *)pOjbect
{
    NSLog(@"编辑完成 回调");
    //获取效果小图    Obtain effect thumbnail
    UIImage *image = [UIImage imageWithData:pOjbect.pOutEffectDisplayData];
    NSAssert(image, @" ");
//    [self.mV_displayImageView pSetupPreviewImage:image];
    //启动一个完成界面  Start a completed screen
    //    [self pPushCompleteViewController];
    [self.navigationController popViewControllerAnimated:YES];
    
    //获取效果大图    Obtain effect large image
    UIImage *imageOri = [UIImage imageWithData:pOjbect.pOutEffectOriData];
    NSAssert(imageOri, @" ");

    _image=imageOri;
    //保存到相册     Save to album
    UIImageWriteToSavedPhotosAlbum(imageOri, nil, NULL, NULL);
}

- (void)dgPhotoEditingViewControllerShowLoadingView:(UIView *)view
{
    //    [SVProgressHUD show];
}

- (void)dgPhotoEditingViewControllerHideLoadingView:(UIView *)view
{
    //    [SVProgressHUD dismiss];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end