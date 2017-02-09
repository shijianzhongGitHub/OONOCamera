//
//  TakeMovieViewController.m
//  ZZYWeiXinShortMovie
//
//  Created by zhangziyi on 16/3/23.
//  Copyright © 2016年 GLaDOS. All rights reserved.
//
#define Screen_width [UIScreen mainScreen].bounds.size.width
#define Screen_height [UIScreen mainScreen].bounds.size.height
#import "TakeMovieViewController.h"
#import "Camera.h"
#import "StartButton.h"
#import <QuartzCore/QuartzCore.h>
#import "MyNavigationView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface TakeMovieViewController () <AVCaptureVideoDataOutputSampleBufferDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
{
    Camera *_camera;
    UIView *cameraView;
    NSMutableArray *imagesArray;
    UIImageView *preView;
    BOOL isStart;
    BOOL isCancel;
    CALayer *progressLayer;
    StartButton *startButton;
    UILabel *tipsLabel;
    NSTimer *timer;
    NSInteger time;
    
    MyNavigationView * navView;
}
@end

@implementation TakeMovieViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.navigationBar.tintColor = [UIColor greenColor];
//    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    isStart = NO;
    imagesArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor blackColor];
    
    navView=[[MyNavigationView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    
    [navView createMyNavigationBarWithBackGroundImage:nil andTitle:@"" andLeftBBIImage:[UIImage imageNamed:@"back"] andLeftBBITitle:nil andRightBBIImage:nil andRightBBITitle:nil andSEL:@selector(TakeMovieViewNavigationClick:) andClass:self];
    [self.view addSubview:navView];
    
    [self initCamera];//初始化摄像头
    [self initPreView];//初始化预览gif的view
    [self initStartButton];//初始化开始拍摄按钮
    //相机权限受限提示
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied ||authStatus == AVAuthorizationStatusRestricted)
    {
        NSLog(@"相机权限受限");
    }
    //拍摄手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    panGesture.delegate = self;
    [startButton addGestureRecognizer:panGesture];
    UILongPressGestureRecognizer *longPressGeture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(startAction:)];
    longPressGeture.delegate = self;
    longPressGeture.minimumPressDuration = 0.1;
    [startButton addGestureRecognizer:longPressGeture];
    
    UIButton * redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    redoButton.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height-60, 60, 44);
    [redoButton setTitle:@"重拍" forState:UIControlStateNormal];
    [redoButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [redoButton addTarget:self action:@selector(resetCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:redoButton];
    
    UIButton * finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    finishButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 95, [UIScreen mainScreen].bounds.size.height-60, 60, 44);
    [finishButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishButton];
    
//    UIBarButtonItem *redoButton = [[UIBarButtonItem alloc]initWithTitle:@"重拍" style:UIBarButtonItemStylePlain target:self action:@selector(resetCamera:)];
//    UIBarButtonItem *finishButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
//    self.navigationItem.rightBarButtonItems = @[finishButton,redoButton];
}
-(void)initCamera
{
    cameraView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, Screen_width, Screen_height/2)];
    [self.view insertSubview:cameraView atIndex:0];
    _camera = [[Camera alloc]init];
    _camera.frameNum = _frameNum;
    [_camera embedLayerWithView:cameraView];
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [_camera.deviceVideoOutput setSampleBufferDelegate:self queue:queue];
    [_camera startCamera];
}
-(void)initPreView
{
    preView = [[UIImageView alloc]initWithFrame:cameraView.bounds];
    preView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:preView];
    preView.hidden = YES;
}
-(void)initStartButton
{
    startButton = [[StartButton alloc]initWithFrame:CGRectMake(Screen_width/3, Screen_height/2+Screen_height/16+80, Screen_width/3, Screen_width/3)];
    [self.view addSubview:startButton];
}
-(void)initProgress
{
    progressLayer = [CALayer layer];
    progressLayer.backgroundColor = [UIColor greenColor].CGColor;
    progressLayer.frame = CGRectMake(0, Screen_height/2, Screen_width, 5);
    [self.view.layer addSublayer:progressLayer];
    CABasicAnimation *countTime = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    countTime.toValue = @0;
//    countTime.duration = _cameraTime=20;
    countTime.duration = 20;
    countTime.removedOnCompletion = NO;
    countTime.fillMode = kCAFillModeForwards;
    [progressLayer addAnimation:countTime forKey:@"progressAni"];
}
-(void)panAction:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (point.y < Screen_height/2) {
        isCancel = YES;
        progressLayer.backgroundColor = [UIColor redColor].CGColor;
        tipsLabel.text = @"松手取消";
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.backgroundColor = [UIColor redColor];
    }
    else
    {
        isCancel = NO;
        progressLayer.backgroundColor = [UIColor greenColor].CGColor;
        tipsLabel.text = @"⬆️上移取消";
        tipsLabel.textColor = [UIColor greenColor];
        tipsLabel.backgroundColor = [UIColor clearColor];
    }
}

-(void)startAction:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        isStart = YES;
        isCancel = NO;
        [startButton disappearAnimation];
        [self initProgress];
        tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(Screen_width/2-42, Screen_height/2-30, 84, 20)];
        tipsLabel.font = [UIFont systemFontOfSize:14];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.text = @"⬆️上移取消";
        tipsLabel.textColor = [UIColor greenColor];
        [self.view addSubview:tipsLabel];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
        time = 0;
        NSLog(@"start");
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        if (isCancel)
        {
            NSLog(@"cancel");
            isStart = NO;
            [timer invalidate];
            [progressLayer removeFromSuperlayer];
            [tipsLabel removeFromSuperview];
            [startButton appearAnimation];
            return;
        }
        else
        {
            if (time < 1)
            {
                isStart = NO;
                [timer invalidate];
                [imagesArray removeAllObjects];
                [progressLayer removeFromSuperlayer];
                [startButton appearAnimation];
                tipsLabel.text = @"手指不要放开";
                tipsLabel.textColor = [UIColor whiteColor];
                tipsLabel.backgroundColor = [UIColor redColor];
                [UIView animateWithDuration:2.0 animations:^{
                    tipsLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    [tipsLabel removeFromSuperview];
                }];
                return;
            }
            else if(time >=1 && time < _cameraTime){
                [self finishCamera];
            }
        }
    }
}
-(void)countDown:(NSTimer*)timerer
{
    time++;
    if (time >= _cameraTime)
    {
        [self finishCamera];
    }
    NSLog(@"%ld",(long)time);
}
-(void)resetCamera:(UIBarButtonItem*)sender
{
    cameraView.hidden = NO;
    [_camera startCamera];
    startButton.hidden = NO;
    [startButton appearAnimation];
    preView.hidden = YES;
    [imagesArray removeAllObjects];
}
- (void)finishCamera
{
    [timer invalidate];
    NSLog(@"%@",imagesArray);
    NSLog(@"totle=%ld",(unsigned long)imagesArray.count);
    [_camera stopCamera];
    isStart = NO;
    [progressLayer removeFromSuperlayer];
    [tipsLabel removeFromSuperview];
    startButton.hidden = YES;
    //预览gif动画
    preView.animationImages = imagesArray;
    preView.animationDuration = time;
    preView.animationRepeatCount = 0;
    preView.hidden = NO;
    cameraView.hidden = YES;
    [preView startAnimating];
}
-(void)done:(UIBarButtonItem*)sender
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否保存这段视频？" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:@"保存", nil];
    [alertView show];
    
    //push viewcontroller
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"buttonIndex ====== 0");
    }
    else
    {
        NSLog(@"buttonIndex ===== else");
        
        
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"video...");
    NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
    NSString *urlStr=[url path];
    
    [self saveVideo:urlStr];
    
    
//    NSString* path = [[info objectForKey:UIImagePickerControllerMediaURL] path];
//    
//    // 保存视频
//    
//    UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//    
//    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)saveVideo:(NSString *)videoPath
{
    [[[ALAssetsLibrary alloc]init] writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if (error)
        {
            NSLog(@"Save video fail：%@",error);
        }else{
            NSLog(@"Save video succeed.");
        }
        
    }];
    
}

// 视频保存回调

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo
{
    
    NSLog(@"%@",videoPath);
    
    NSLog(@"%@",error);
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (isStart)
    {
        UIImage *image = [self imageFromSampleBuffer:&sampleBuffer];
        image = [self normalizedImage:image];
        [imagesArray addObject:image];
    }
}
-(UIImage*) imageFromSampleBuffer:(CMSampleBufferRef*)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(*sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *basdAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(basdAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *image  = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(quartzImage);
    return (image);
}
- (UIImage *)normalizedImage:(UIImage*)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (void)TakeMovieViewNavigationClick:(UIButton *)Btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com