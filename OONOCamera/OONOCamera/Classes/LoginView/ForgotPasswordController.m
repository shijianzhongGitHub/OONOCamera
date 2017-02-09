//
//  ForgotPasswordController.m
//  OONOCamera
//
//  Created by 史建忠 on 16/8/30.
//  Copyright © 2016年 史建忠. All rights reserved.
//

#import "ForgotPasswordController.h"
#import "ResetPasswordController.h"
#import "MyNavigationView.h"
#import "PublicClass.h"

@interface ForgotPasswordController ()<UITextFieldDelegate>
{
    UITextField * phoneNumField;
    UITextField * verificationCodeField;
    UIButton    * sendCodeBtn;
    UIButton    * nextBtn;
    
    MyNavigationView * navView;
}

@property(nonatomic,assign)NSInteger timeCount;
@property(nonatomic,strong)NSTimer * timer;

@end

@implementation ForgotPasswordController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    navView=[[MyNavigationView alloc] initWithFrame:CGRectMake(0, 0, AppWidth, 64)];
    
    [navView createMyNavigationBarWithBackGroundImage:nil andTitle:@"" andLeftBBIImage:[UIImage imageNamed:@"back"] andLeftBBITitle:nil andRightBBIImage:nil andRightBBITitle:nil andSEL:@selector(ForgotNavigationClick:) andClass:self];
    [self.view addSubview:navView];
    
    [self setUpForgotPasswordUI];
}

- (void)setUpForgotPasswordUI
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
    
    verificationCodeField = [[UITextField alloc] init];
    verificationCodeField.frame = CGRectMake(20, 270, AppWidth-150, 44);
    verificationCodeField.placeholder = @" 请输入登录密码";
    verificationCodeField.layer.cornerRadius = 3;
    verificationCodeField.delegate = self;
    verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
    verificationCodeField.leftViewMode=UITextFieldViewModeAlways;
    verificationCodeField.clearButtonMode = UITextFieldViewModeAlways;
    verificationCodeField.font = [UIFont systemFontOfSize:16];
    verificationCodeField.keyboardType = UIKeyboardTypeDefault;
    verificationCodeField.backgroundColor = [UIColor whiteColor];
    verificationCodeField.textColor = [UIColor grayColor];
    [self.view addSubview:verificationCodeField];
    
    sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendCodeBtn.frame = CGRectMake(AppWidth-120, 270, 100, 44);
    [sendCodeBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:78/255.0 blue:39/255.0 alpha:1.0]];
    sendCodeBtn.layer.cornerRadius = 3;
    [sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    sendCodeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [sendCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendCodeBtn addTarget:self action:@selector(getForgotCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendCodeBtn];

    
    nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(20, 360, AppWidth-40, 44);
    [nextBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:78/255.0 blue:39/255.0 alpha:1.0]];
    nextBtn.layer.cornerRadius = 3;
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)leftBtnClick:(UIButton *)leftBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getForgotCodeBtnClick
{
    NSLog(@"========sendCodeBtnClick=======");

    sendCodeBtn.enabled=NO;
    self.timeCount=1;
    
    // 倒计时
    self.timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runTimeCountYanzheng) userInfo:nil repeats:YES];
    
}

//#pragma mark ---------buttonClick----------
//- (void)getRetisterButtonClick
//{
//    if(![PublicClass validateMobile:phoneNumField.text])
//    {
////        [self showErrorViewAtReg:@"请输入正确的手机号"];
//        return;
//    }
//    
//    /*
//     if (isNetwork) {
//     //连接服务器失败！
//     isNetwork = YES;
//     NSUserDefaults *userDef=[NSUserDefaults standardUserDefaults];
//     //    密码和手机号
//     NSString *PPstr=[NSString stringWithFormat:@"%@_%@_%@",[userDef objectForKey:@"phone"],[userDef objectForKey:@"rid"],[userDef objectForKey:@"rid"]];
//     
//     //    MD5加密
//     NSString *sig=[EncodeHelper MD5SumWithString:PPstr];
//     //    base64
//     //    NSString *sig=[EncodeHelper encodeBase64String:PPMD5Str];
//     
//     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//     //申明返回的结果是json类型
//     manager.responseSerializer = [AFJSONResponseSerializer serializer];
//     //申明请求的数据是json类型
//     manager.requestSerializer=[AFJSONRequestSerializer serializer];
//     //如果报接受类型不一致请替换一致text/html或别的
//     manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
//     
//     //传入的参数
//     NSDictionary *parameters = @{@"uid":[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"],@"sig":sig};
//     NSLog(@"parLogin ------------- %@  url ---------- %@",parameters,kGetToken);
//     //你的接口地址
//     NSString *rulString=[NSString stringWithFormat:@"%@?uid=%@&sig=%@",kGetToken,[userDef objectForKey:@"phone"],sig];
//     //发送请求
//     [manager sigGet:rulString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//     NSLog(@"JSONAtGetToken: %@", responseObject);
//     tokenStr=[responseObject objectForKey:@"uptoken"];
//     if ([[responseObject objectForKey:@"ret"]isEqualToString:@"-1004"]) {
//     [self showErrorViewAtReg:@"未能连接到服务器"];
//     codeButton.userInteractionEnabled = NO;
//     }
//     else
//     {
//     [errorImgView removeFromSuperview];
//     errorImgView = [[ErrorView alloc] initWithFrame:self.view.bounds];
//     [errorImgView createErrorViewCode:[responseObject objectForKey:@"ret"] andSEL:@selector(errorButtonClick) andClass:self];
//     [self.view addSubview:errorImgView];
//     [UIView animateWithDuration:1.001 //时长
//     delay:0.0 //延迟时间
//     options:UIViewAnimationOptionTransitionFlipFromBottom//动画效果
//     animations:^{
//     //动画设置区域
//     errorImgView.frame = CGRectZero;
//     } completion:^(BOOL finish){
//     //动画结束时调用
//     [errorImgView removeFromSuperview];
//     }];
//     
//     }
//     [waitingView.activityView stopAnimating]; // 结束旋转
//     waitingView.hidden =YES;
//     
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//     nextID=@"";
//     [waitingView.activityView stopAnimating]; // 结束旋转
//     waitingView.hidden = YES;
//     [errorImgView removeFromSuperview];
//     errorImgView = [[ErrorView alloc] initWithFrame:self.view.bounds];
//     [errorImgView createErrorViewCode:@"-1004" andSEL:@selector(errorButtonClick) andClass:self];
//     [self.view addSubview:errorImgView];
//     
//     }];
//     
//     [self showErrorViewAtReg:@"未能连接到服务器!"];
//     
//     }*/
//    
//    //    获取验证码
//    if([PublicClass validateMobile:phoneNumField.text])
//    {
//        sendCodeBtn.enabled=NO;
//        self.timeCount=1;
//        //                倒计时
//        self.timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runTimeCountYanzheng) userInfo:nil repeats:YES];
//        
////        netType =0;
////        [self getVrcodeClick];
//    }
//    else
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号不正确！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//    }
//    
//}

- (void)runTimeCountYanzheng
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

- (void)nextBtnClick
{
    ResetPasswordController * resetPasswordVC = [[ResetPasswordController alloc] init];
    [self.navigationController pushViewController:resetPasswordVC animated:YES];
}

- (void)ForgotNavigationClick:(UIButton *)navBtn
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
    [phoneNumField resignFirstResponder];
    [verificationCodeField resignFirstResponder];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y+150-(self.view.frame.size.height-216.0);//键盘高度216
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
