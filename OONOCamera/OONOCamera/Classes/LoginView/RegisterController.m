//
//  registerController.m
//  OONOCamera
//
//  Created by 史建忠 on 16/8/30.
//  Copyright © 2016年 史建忠. All rights reserved.
//

#import "RegisterController.h"
#import "MyNavigationView.h"

@interface RegisterController ()<UITextFieldDelegate>
{
    UITextField * phoneNumField;
    UITextField * VerificationCodeField;//验证码
    UITextField * passwordField;
    
    UIButton    * registerBtn;
    UIButton    * sendCodeBtn;//发送验证码
    
    MyNavigationView * navView;
}

/** 倒计时 */
@property (nonatomic, assign) NSInteger timeCount;
@property (nonatomic, strong) NSTimer * timer;

@end

@implementation RegisterController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    navView=[[MyNavigationView alloc] initWithFrame:CGRectMake(0, 0, AppWidth, 64)];
    
    [navView createMyNavigationBarWithBackGroundImage:nil andTitle:@"注册" andLeftBBIImage:[UIImage imageNamed:@"back"] andLeftBBITitle:nil andRightBBIImage:nil andRightBBITitle:nil andSEL:@selector(RegisterNavigationClick:) andClass:self];    
    [self.view addSubview:navView];
    
    [self buildUI];
}

- (void)buildUI
{
    phoneNumField = [[UITextField alloc] init];
    phoneNumField.frame = CGRectMake(20, 200, AppWidth-40, 44);
    phoneNumField.placeholder = @" 请输入您的手机号";
    phoneNumField.layer.cornerRadius = 3;
    phoneNumField.delegate = self;
    phoneNumField.font = [UIFont systemFontOfSize:16];
    phoneNumField.leftViewMode=UITextFieldViewModeAlways;
    phoneNumField.clearButtonMode = UITextFieldViewModeAlways;
    phoneNumField.keyboardType = UIKeyboardTypeNumberPad;
    phoneNumField.backgroundColor = [UIColor whiteColor];
    phoneNumField.textColor = [UIColor grayColor];
    [self.view addSubview:phoneNumField];
    
    VerificationCodeField = [[UITextField alloc] init];
    VerificationCodeField.frame = CGRectMake(20, 270, AppWidth-150, 44);
    VerificationCodeField.placeholder = @" 请输入验证码";
    VerificationCodeField.layer.cornerRadius = 3;
    VerificationCodeField.delegate = self;
    VerificationCodeField.leftViewMode=UITextFieldViewModeAlways;
    VerificationCodeField.clearButtonMode = UITextFieldViewModeAlways;
    VerificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
    VerificationCodeField.font = [UIFont systemFontOfSize:16];
    VerificationCodeField.keyboardType = UIKeyboardTypeDefault;
    VerificationCodeField.backgroundColor = [UIColor whiteColor];
    VerificationCodeField.textColor = [UIColor grayColor];
    [self.view addSubview:VerificationCodeField];
    
    sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendCodeBtn.frame = CGRectMake(AppWidth-120, 270, 100, 44);
    [sendCodeBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:78/255.0 blue:39/255.0 alpha:1.0]];
    sendCodeBtn.layer.cornerRadius = 3;
    [sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    sendCodeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [sendCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendCodeBtn addTarget:self action:@selector(getRegisterCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendCodeBtn];
    
    passwordField = [[UITextField alloc] init];
    passwordField.frame = CGRectMake(20, 340, AppWidth-40, 44);
    passwordField.placeholder = @" 请输入登录密码";
    passwordField.layer.cornerRadius = 3;
    passwordField.delegate = self;
    passwordField.secureTextEntry = YES;
    passwordField.leftViewMode=UITextFieldViewModeAlways;
    passwordField.clearButtonMode = UITextFieldViewModeAlways;
    passwordField.font = [UIFont systemFontOfSize:16];
    passwordField.keyboardType = UIKeyboardTypeDefault;
    passwordField.backgroundColor = [UIColor whiteColor];
    passwordField.textColor = [UIColor grayColor];
    [self.view addSubview:passwordField];
    
    registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(20, 430, AppWidth-40, 44);
    [registerBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:78/255.0 blue:39/255.0 alpha:1.0]];
    registerBtn.layer.cornerRadius = 3;
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(registerVcRegisterBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)leftBtnClick:(UIButton *)leftBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getRegisterCodeBtnClick
{
    sendCodeBtn.enabled=NO;
    self.timeCount=1;
    
    // 倒计时
    self.timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runTimeCountAtRegisterView) userInfo:nil repeats:YES];

}

- (void)runTimeCountAtRegisterView
{
    if(self.timeCount<61)
    {
        self.timeCount++;
        NSString *timeString=[NSString stringWithFormat:@"等待(%d)",61-self.timeCount];
        sendCodeBtn.backgroundColor=[UIColor grayColor];
        [sendCodeBtn setTitle:timeString forState:UIControlStateNormal];
        sendCodeBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
        sendCodeBtn.enabled=NO;
    }
    else
    {
        self.timeCount=1;
        [sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        sendCodeBtn.backgroundColor=[UIColor colorWithRed:255/255.0 green:48/255.0 blue:48/255.0 alpha:1.0];
        sendCodeBtn.enabled=YES;
        [self.timer invalidate];
        self.timer=nil;
    }
}

- (void)RegisterNavigationClick:(UIButton *)navBtn
{
    switch (navBtn.tag) {
        case 101:
        {
            NSLog(@"返回");
            [self.navigationController popViewControllerAnimated:YES];
            
        }
            break;
        case 102:
        {
            NSLog(@"下一步");
        }
        default:
            break;
    }
}

#pragma mark ----------keyboard----------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [VerificationCodeField resignFirstResponder];
    [passwordField resignFirstResponder];
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

- (void)registerVcRegisterBtnClick
{
    
}

@end
