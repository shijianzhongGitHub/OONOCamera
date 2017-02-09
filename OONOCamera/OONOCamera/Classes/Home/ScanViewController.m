//
//  ViewController.m
//  OONOCamera
//
//  Created by 史建忠 on 16/9/5.
//  Copyright © 2016年 史建忠. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "drawView.h"
static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";
@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL lastResult;
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)drawView *drawView;

@end

@implementation ScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
  
//    AVCaptureSession *session = [[AVCaptureSession alloc]init];
//    session.sessionPreset = AVCaptureSessionPreset640x480;
    [self startReading];
    _lastResult = YES;
}
//扫描相册二维码
-(void)chooseImage
{
    [self openPhoto];
}
- (void)openPhoto
{
    [self openLocalPhoto];
}
/*!
 *  打开本地照片，选择图片识别
 */
- (void)openLocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
    
    picker.allowsEditing = YES;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}
//当选择一张图片后进入这里

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    //系统自带识别方法
   
     CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    CGImageRef ref = (CGImageRef)image.CGImage;
    CIImage *cii = [CIImage imageWithCGImage:ref];
     NSArray *features = [detector featuresInImage:cii];
   
     if (features.count >=1)
     {
     CIQRCodeFeature *feature = [features objectAtIndex:0];
     NSString *scanResult = feature.messageString;
     
         UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"二维码扫描" message:scanResult preferredStyle:UIAlertControllerStyleAlert];
         UIAlertAction *oneAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
             [self dismissViewControllerAnimated:YES completion:nil];
             [self startReading];
             
         }];
         UIAlertAction *twoAction = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scanResult]]) {
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scanResult]];
             }else{
                 UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:@"网址有误" preferredStyle:UIAlertControllerStyleAlert];
                 [self presentViewController:alertC animated:YES completion:nil];
                 [self dismissViewControllerAnimated:YES completion:nil];
                 [self startReading];
             }
             [self dismissViewControllerAnimated:YES completion:nil];
             [self startReading];
             
         }];
         [alertC addAction:oneAction];
         [alertC addAction:twoAction];
         [self presentViewController:alertC animated:YES completion:nil];
         
         
     NSLog(@"%@",scanResult);
     }
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)startReading
{
    // 获取 AVCaptureDevice 实例
    NSError * error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 初始化输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    // 创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    // 添加输入流
    [_captureSession addInput:input];
    // 初始化输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    //设置扫描区域 注:这里CGRectMake中填写的数字是0-1,并且x与y互换,height与width互换
    [captureMetadataOutput setRectOfInterest:CGRectMake(0.25,20/self.view.layer.bounds.size.width,  0.5,(self.view.layer.bounds.size.width - 40)/self.view.layer.bounds.size.width)];
    
    
    // 添加输出流
    [_captureSession addOutput:captureMetadataOutput];
    
    // 创建dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // 设置元数据类型 AVMetadataObjectTypeQRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // 创建输出对象
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    [_videoPreviewLayer setFrame:self.view.layer.bounds];
    [self.view.layer addSublayer:_videoPreviewLayer];
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, self.view.layer.bounds.size.height * 0.25, self.view.layer.bounds.size.width - 40, self.view.layer.bounds.size.height * 0.5)];
    _imageView.image = [UIImage imageNamed:@"qrcode_scan_full_net"];
  
    [self.view addSubview:_imageView];
    _drawView = [[drawView alloc]initWithFrame:self.view.bounds];
    _drawView.backgroundColor = [UIColor blackColor];
    _drawView.alpha = 0.5;
    [self.view addSubview:_drawView];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 80, self.view.frame.size.height - 90, 50, 50)];
    [button setBackgroundImage:[UIImage imageNamed:@"erweima@3x"] forState:UIControlStateNormal];
 
    [button addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
    [_drawView addSubview:button];
    
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 30, 35, 35);
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_drawView addSubview:backBtn];
    
    //选定一块区域,设置不同的透明度
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0,  self.view.bounds.size.width,  self.view.bounds.size.height)];
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(20, self.view.layer.bounds.size.height * 0.25, self.view.layer.bounds.size.width - 40, self.view.layer.bounds.size.height * 0.5) cornerRadius:0] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [_drawView.layer setMask:shapeLayer];
    // 开始会话
    [_captureSession startRunning];
    [self stepAnimation];
   
    return YES;
}

- (void)stepAnimation
{

    CGRect frame = CGRectMake(20, self.view.layer.bounds.size.height * -0.25, self.view.layer.bounds.size.width-40, self.view.layer.bounds.size.height * 0.5);
   
    _imageView.frame = frame;
    
    _imageView.alpha = 0.0;
    
    __weak __typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:1.2 animations:^{
        _imageView.alpha = 1.0;
        _imageView.frame = CGRectMake(20, self.view.layer.bounds.size.height * 0.25,self.view.layer.bounds.size.width-40, self.view.layer.bounds.size.height * 0.5);
        
    } completion:^(BOOL finished)
     {
         
         [weakSelf performSelector:@selector(stepAnimation) withObject:nil afterDelay:0.3];
     }];
}

- (void)stopReading
{
    // 停止会话
    [_captureSession stopRunning];
    _captureSession = nil;
    [_imageView removeFromSuperview];
    
    
}
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result;
               if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = metadataObj.stringValue;
                
        
        } else {
            NSLog(@"不是二维码");
        }
        [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:NO];
    }
}
- (void)reportScanResult:(NSString *)result
{
    [self stopReading];
    if (!_lastResult) {
        return;
    }
    _lastResult = NO;
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"二维码扫描" message:result preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *oneAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self startReading];

    }];
    UIAlertAction *twoAction = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:result]]) {
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
        }else{
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:@"网址有误" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertC animated:YES completion:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self startReading];
        }
            [self dismissViewControllerAnimated:YES completion:nil];
            [self startReading];
        
    }];
    [alertC addAction:oneAction];
    [alertC addAction:twoAction];
    [self presentViewController:alertC animated:YES completion:nil];

    // 以下处理了结果，继续下次扫描
    _lastResult = YES;
}

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
