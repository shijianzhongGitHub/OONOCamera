//
//  ViewController.m
//  闪光灯
//
//  Created by 史建忠 on 16/8/29.
//  Copyright © 2016年 史建忠. All rights reserved.
//

#import "LoginViewController.h"

#import "DJCameraViewController.h"
#import "RegisterController.h"
#import "ForgotPasswordController.h"
#import "MyNavigationView.h"

#import <AVFoundation/AVFoundation.h>


@interface LoginViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>
{
    AVCaptureSession * _AVSession;//调用闪光灯的时候创建的类
    
    UIImageView      * iconImageView;
    UITextField      * accountField;
    UITextField      * passWordField;
    UIButton         * loginBtn;
    UIButton         * registeredBtn;
    UIButton         * forgotPasswordBtn;
    
    MyNavigationView * navView;
}

@property(nonatomic,retain)AVCaptureSession * AVSession;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self buildBtnUI];
    [self buildLogUI];
    
}

- (void)buildLogUI
{
    iconImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    iconImageView.frame = CGRectMake((AppWidth-iconImageView.frame.size.width*0.2)/2, 90, iconImageView.frame.size.width*0.2, iconImageView.frame.size.height*0.2);
    [self.view addSubview:iconImageView];
    
    accountField = [[UITextField alloc] init];
    accountField.frame = CGRectMake(20, 200, AppWidth-40, 44);
    accountField.placeholder = @" 请输入您的手机号";
    accountField.layer.cornerRadius = 3;
    accountField.delegate = self;
    accountField.leftViewMode=UITextFieldViewModeAlways;
    accountField.clearButtonMode = UITextFieldViewModeAlways;
    accountField.keyboardType = UIKeyboardTypeNumberPad;
    accountField.backgroundColor = [UIColor whiteColor];
    accountField.textColor = [UIColor grayColor];
    [self.view addSubview:accountField];
    
    passWordField = [[UITextField alloc] init];
    passWordField.frame = CGRectMake(20, 270, AppWidth-40, 44);
    passWordField.placeholder = @" 请输入登录密码";
    passWordField.layer.cornerRadius = 3;
    passWordField.delegate = self;
    passWordField.secureTextEntry = YES;
    passWordField.leftViewMode=UITextFieldViewModeAlways;
    passWordField.clearButtonMode = UITextFieldViewModeAlways;
    passWordField.keyboardType = UIKeyboardTypeDefault;
    passWordField.backgroundColor = [UIColor whiteColor];
    passWordField.textColor = [UIColor grayColor];
    [self.view addSubview:passWordField];
    
    loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(20, 360, AppWidth-40, 44);
    [loginBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:78/255.0 blue:39/255.0 alpha:1.0]];
    loginBtn.layer.cornerRadius = 3;
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(logBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    registeredBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registeredBtn.frame = CGRectMake(2, 415, 60, 30);
    [registeredBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [registeredBtn setTitle:@"注册" forState:UIControlStateNormal];
    registeredBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [registeredBtn addTarget:self action:@selector(loginVcRegisterBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registeredBtn];
    
    forgotPasswordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgotPasswordBtn.frame = CGRectMake(AppWidth-88, 415, 80, 30);
    [forgotPasswordBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [forgotPasswordBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
    forgotPasswordBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [forgotPasswordBtn addTarget:self action:@selector(forgotPasswordBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgotPasswordBtn];
}

- (void)loginVcRegisterBtnClick
{
    RegisterController * registerVC = [[RegisterController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)forgotPasswordBtnClick
{
    ForgotPasswordController * forgotPasswordVC = [[ForgotPasswordController alloc] init];
    [self.navigationController pushViewController:forgotPasswordVC animated:YES];
}

- (void)logBtnClick
{
    DJCameraViewController * cameraVC = [[DJCameraViewController alloc] init];
    [self.navigationController pushViewController:cameraVC animated:NO];
}

-(void)buildBtnUI
{
    NSArray * btnArray = [NSArray arrayWithObjects:@"相机",@"相册",@"闪光灯",@"关闭闪光灯", nil];
    
    for (int i = 0 ; i<4; i++)
    {
        UIButton * clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        clickBtn.frame = CGRectMake(130, 100 + i * 90, 100, 44);
        clickBtn.backgroundColor = [UIColor redColor];
        clickBtn.layer.cornerRadius = 3;
        clickBtn.tag = i;
        [clickBtn setTitle:[btnArray objectAtIndex:i] forState:UIControlStateNormal];
        [clickBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:clickBtn];
    }
}

-(void)btnClick:(UIButton *)btn
{
    if (btn.tag == 0)
    {
        NSLog(@"======Camera=======");
        //打开相机
        DJCameraViewController *VC = [DJCameraViewController new];
        [self presentViewController:VC animated:YES completion:nil];
    }
    else if(btn.tag == 1)
    {
        NSLog(@"======Library=======");
        //打开相册
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;//是否可以编辑
            //打开相册选择图片
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
    else if(btn.tag == 2)
    {
        NSLog(@"======flashlight=======");
        //打开闪光灯
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device.torchMode == AVCaptureTorchModeOff)
        {
            AVCaptureSession * session = [[AVCaptureSession alloc] init];
            AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            [session addInput:input];
            
            AVCaptureVideoDataOutput * output = [[AVCaptureVideoDataOutput alloc]init];
            [session addOutput:output];
            
            [session beginConfiguration];
            [device lockForConfiguration:nil];
            
            [device setTorchMode:AVCaptureTorchModeOn];
            [device unlockForConfiguration];
            [session commitConfiguration];
            
            [session startRunning];
            
            [self setAVSession:self.AVSession];
        }
    }
    else
    {
        NSLog(@"======close=======");
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //得到图片
    UIImage * image = [info objectForKeyedSubscript:UIImagePickerControllerOriginalImage];
    
    //图片保存到相册
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    [self dismissViewControllerAnimated:YES completion:nil];
}
//点击Cancel按钮后执行方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//选中图片进入的代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

-(void)closeFlashlight
{
    [self.AVSession stopRunning];
}

#pragma mark ----------keyboard----------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [accountField resignFirstResponder];
    [passWordField resignFirstResponder];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 150 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}
//return 键隐藏键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"scrollView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.275f];
    self.view.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [UIView commitAnimations];
}

@end












