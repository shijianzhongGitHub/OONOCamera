//
//  ResetPasswordController.m
//  OONOCamera
//
//  Created by 史建忠 on 16/8/30.
//  Copyright © 2016年 史建忠. All rights reserved.
//

#import "ResetPasswordController.h"
#import "MyNavigationView.h"

@interface ResetPasswordController ()<UITextFieldDelegate>
{
    UITextField * newPasswordField;
    UITextField * newPasswordAgainField;
    UIButton    * completeBtn;
    
    MyNavigationView * navView;
}

@end

@implementation ResetPasswordController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    navView=[[MyNavigationView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    
    [navView createMyNavigationBarWithBackGroundImage:nil andTitle:@"重置密码" andLeftBBIImage:[UIImage imageNamed:@"back"] andLeftBBITitle:nil andRightBBIImage:nil andRightBBITitle:nil andSEL:@selector(ResetNavigationClick:) andClass:self];
    [self.view addSubview:navView];
    
    [self setUpResetPasswordUI];
}

- (void)setUpResetPasswordUI
{
    newPasswordField = [[UITextField alloc] init];
    newPasswordField.frame = CGRectMake(20, 200, self.view.frame.size.width-40, 44);
    newPasswordField.placeholder = @" 请输入新密码";
    newPasswordField.layer.cornerRadius = 3;
    newPasswordField.delegate = self;
    newPasswordField.font = [UIFont systemFontOfSize:16];
    newPasswordField.leftViewMode=UITextFieldViewModeAlways;
    newPasswordField.clearButtonMode = UITextFieldViewModeAlways;
    newPasswordField.keyboardType = UIKeyboardTypeNumberPad;
    newPasswordField.backgroundColor = [UIColor whiteColor];
    newPasswordField.textColor = [UIColor grayColor];
    [self.view addSubview:newPasswordField];
    
    newPasswordAgainField = [[UITextField alloc] init];
    newPasswordAgainField.frame = CGRectMake(20, 270, self.view.frame.size.width-40, 44);
    newPasswordAgainField.placeholder = @" 请再次输入新密码";
    newPasswordAgainField.layer.cornerRadius = 3;
    newPasswordAgainField.delegate = self;
    newPasswordAgainField.leftViewMode=UITextFieldViewModeAlways;
    newPasswordAgainField.clearButtonMode = UITextFieldViewModeAlways;
    newPasswordAgainField.font = [UIFont systemFontOfSize:16];
    newPasswordAgainField.keyboardType = UIKeyboardTypeDefault;
    newPasswordAgainField.backgroundColor = [UIColor whiteColor];
    newPasswordAgainField.textColor = [UIColor grayColor];
    [self.view addSubview:newPasswordAgainField];
    
    completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    completeBtn.frame = CGRectMake(20, 360, self.view.frame.size.width-40, 44);
    [completeBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:78/255.0 blue:39/255.0 alpha:1.0]];
    completeBtn.layer.cornerRadius = 3;
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    completeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(completeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:completeBtn];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)completeBtnClick
{
    
}

- (void)leftBtnClick:(UIButton *)leftBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)ResetNavigationClick:(UIButton *)navBtn
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
    [newPasswordField resignFirstResponder];
    [newPasswordAgainField resignFirstResponder];
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
