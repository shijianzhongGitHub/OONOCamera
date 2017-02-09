//
//  ViewController.m
//  照相机demo
//
//  Created by Jason on 11/1/16.
//  Copyright © 2016年 Jason. All rights reserved.
//

#import "DJCameraViewController.h"
#import "PhotoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIButton+DJBlock.h"
#import "DJCameraManager.h"

#import "DownMenuView.h"
#import "UpMenuView.h"
#import "DragView.h"
#import "labelView.h"
#import "ScanViewController.h"
#import "WCLRecordVideoVC.h"
#import "TakeMovieViewController.h"
#import "WechatShortVideoController.h"

//weakself
#define WEAKSELF_SC __weak __typeof(&*self)weakSelf_SC = self;
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface DJCameraViewController () <DJCameraManagerDelegate,addTagDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,WechatShortVideoDelegate,UIGestureRecognizerDelegate>
{
    DragView                * userResizableView1;
    DownMenuView            * downView;
    UpMenuView              * upView;
    
    labelView               * favoriteview;
    DragView                * cameraView;
    DragView                * flashView;
    DragView                * shootView;
    
    UIView                  * sceneViewOne;
    UIView                  * sceneViewTwo;
    UIView                  * sceneViewThree;

    
    UIButton                * downMenuBtn;
    UIButton                * upMenuBtn;
    UIButton                * shootBtn;
    
    NSMutableArray          * downBtnArray;
    NSMutableArray          * upBtnArray;
    NSMutableArray          * upArray;
    NSMutableArray          * screenBtnArray;
    UIImageView             * imageView;
    UIImageView             * cameraImage;
    
    UIImagePickerController * _picker;
    NSTimer                 * timer;
    NSInteger pictureCount;
    NSInteger SetCount;//设置的连拍数
    
    NSInteger percent;
    int t;
    NSInteger viewHeight;
    
    CGFloat _lastScale;
    
    UIButton                * lensBtn;
    UIButton                * flashBtn;
    UIButton                * sceneBtn;
    UIButton                * hdrBtn;
    UIButton                * qrcodeBtn;
    UIButton                * voiceBtn;
    UIButton                * cameraBtn;
    UIButton                * shootButton;
    UIButton                * takePhotoBtn;
    
}
@property (nonatomic,strong)DJCameraManager * manager;
@property (nonatomic,strong)UITextField     * timeField;
@property (nonatomic,strong)UIButton        * percentBtn;
/**
 *  按钮状态
 */
@property (nonatomic, assign) NSInteger x;

@end

@implementation DJCameraViewController
/**
 *  在页面结束或出现记得开启／停止摄像
 *
 *  @param animated
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    if (![self.manager.session isRunning])
    {
        [self.manager.session startRunning];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.manager.session isRunning])
    {
        [self.manager.session stopRunning];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)dealloc
{
    NSLog(@"照相机释放了");
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    t = 1;
    _lastScale = 1.0;
    percent = 1;
    viewHeight = 0;
    downBtnArray = [NSMutableArray array];
    upBtnArray = [NSMutableArray array];
    upArray = [NSMutableArray array];
    screenBtnArray = [NSMutableArray array];
    
    [self initLayout];
    [self initPickButton];
    [self initDismissButton];//取消按钮
    
    [self upMenu];
    [self downMenu];
}

- (void)initLayout
{
    self.view.backgroundColor = [UIColor blackColor];
    
    cameraImage = [[UIImageView alloc]initWithFrame:CGRectMake(20,AppHeigt-160, 60, 60)];
    cameraImage.userInteractionEnabled = YES;
    cameraImage.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:cameraImage];
    
    sceneViewOne = [[UIView alloc]initWithFrame:CGRectMake(0, 20, AppWidth, AppWidth)];
    [self.view addSubview:sceneViewOne];
    DJCameraManager *manager = [[DJCameraManager alloc] init];
    // 传入View的frame 就是摄像的范围
    [manager configureWithParentLayer:sceneViewOne];
    manager.delegate = self;
    self.manager = manager;
    
//    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
//    [pinchRecognizer setDelegate:self];
//    [sceneViewOne addGestureRecognizer:pinchRecognizer];
    
}

- (void)upMenu
{
    UIView *uiview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, AppWidth, 80)];//上拉菜单高度
    UIImage *image = [UIImage imageNamed:@""];
    UIImageView *upImageView = [[UIImageView alloc]initWithImage:image];
    imageView.center = uiview.center;
    [uiview addSubview:upImageView];
    
    upView = [[UpMenuView alloc]initWithView:uiview parentView:self.view];
    [self.view addSubview:upView];
    [self.view bringSubviewToFront:upView];
    
    for (int i = 0; i<upArray.count; i++)
    {
        upMenuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        upMenuBtn.tag = i;
        upMenuBtn.userInteractionEnabled = YES;
        [upMenuBtn addTarget:self action:@selector(upMenuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)downMenu
{
    UIView *uiview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, AppWidth, 180)];//下拉菜单高度
    UIImage * image = [UIImage imageNamed:@""];
    UIImageView * downImageView = [[UIImageView alloc]initWithImage:image];
    imageView.center = uiview.center;
    [uiview addSubview:downImageView];
    
    downView = [[DownMenuView alloc]initWithView:uiview parentView:self.view];
    [self.view addSubview:downView];
    [self.view bringSubviewToFront:downView];
    
    NSArray * imageArray = [NSArray arrayWithObjects:@"landscape_highlighted",@"switch_highlighted",@"flash_highlighted",@"HDR_highlighted",@"voice_highlighted",@"scan_highlighted",@"shoot_highlighted",@"camera_highlighted", nil];
    NSArray * btnTitleArray = [NSArray arrayWithObjects:@"取景框切换",@"镜头切换",@"闪光灯",@"HDR",@"声音",@"扫描二维码",@"连拍",@"摄像", nil];
    [downBtnArray addObjectsFromArray:imageArray];
    
    CGFloat downMennBtnW = 133/2;
    CGFloat margin = (AppWidth-downMennBtnW*4)/5;
    
    
    for (int j = 0; j<downBtnArray.count; j++)
    {
        downMenuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (j>3)
        {
            downMenuBtn.frame = CGRectMake(margin-5+(j-4)*(margin+downMennBtnW), 70+80, 133/2, 133/2);
        }
        else
        {
            downMenuBtn.frame = CGRectMake(margin-5+j*(margin+downMennBtnW), 60, 133/2, 133/2);
        }
        
        downMenuBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        downMenuBtn.imageEdgeInsets = UIEdgeInsetsMake(5,13,10,downMenuBtn.titleLabel.bounds.size.width);
        downMenuBtn.titleEdgeInsets = UIEdgeInsetsMake(70, -downMenuBtn.titleLabel.bounds.size.width-53, 0, 0);
        downMenuBtn.tag = j;
        [downMenuBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [downMenuBtn setImage:[UIImage imageNamed:[imageArray objectAtIndex:j]] forState:UIControlStateNormal];
        
        [downMenuBtn addTarget:self action:@selector(downMenuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [downMenuBtn setTitle:[btnTitleArray objectAtIndex:j] forState:UIControlStateNormal];
        
        [downView addSubview:downMenuBtn];
    }
}

- (void)upMenuButtonClick:(UIButton *)button
{
    switch (button.tag)
    {
        case 0:
        {
            [upBtnArray addObject:[downBtnArray objectAtIndex:0]];
            [upArray addObject:upBtnArray];
        }
            break;
        case 1:
        {
            [upBtnArray addObject:[downBtnArray objectAtIndex:1]];
            [upArray addObject:upBtnArray];
        }
            break;
        case 2:
        {
            [upBtnArray addObject:[downBtnArray objectAtIndex:2]];
            [upArray addObject:upBtnArray];
        }
            break;
        case 3:
        {
            [upBtnArray addObject:[downBtnArray objectAtIndex:3]];
            [upArray addObject:upBtnArray];
        }
            break;
        case 4:
        {
            [upBtnArray addObject:[downBtnArray objectAtIndex:4]];
            [upArray addObject:upBtnArray];
        }
            break;
        case 5:
        {
            NSLog(@"===5===");
            [upBtnArray addObject:[downBtnArray objectAtIndex:5]];
            [upArray addObject:upBtnArray];
        }
            break;
        case 6:
        {
            [upBtnArray addObject:[downBtnArray objectAtIndex:6]];
            [upArray addObject:upBtnArray];
        }
            break;
        case 7:
        {
            [upBtnArray addObject:[downBtnArray objectAtIndex:7]];
            [upArray addObject:upBtnArray];
        }
            break;
            
        default:
            break;
    }
}

- (void)didAddTagClick:(NSString *)tagName
{
    NSLog(@"selectTagName === %@",tagName);
    
    if ([tagName isEqualToString:@"landscape_highlighted"])
    {
        [self buildScene];//取景框切换
    }
    
    if ([tagName isEqualToString:@"flash_highlighted"])
    {
        [self buildFlashView];//闪光灯
    }
    
    if ([tagName isEqualToString:@"switch_highlighted"])
    {
        [self buildLensBtnView];//镜头切换
    }
    
    if ([tagName isEqualToString:@"HDR_highlighted"])
    {
        [self buildHDR];//HDR
    }
    
    if ([tagName isEqualToString:@"voice_highlighted"])
    {
        [self buildVoice];//声音
    }
    
    if ([tagName isEqualToString:@"scan_highlighted"])
    {
        [self buildScan];//二维码
    }
    
    if ([tagName isEqualToString:@"shoot_highlighted"])
    {
        [self buildShoot];//连拍
    }
    
    if ([tagName isEqualToString:@"camera_highlighted"])
    {
        [self buildCamera];//摄像
    }
}

- (void)scale:(UIPinchGestureRecognizer *)sender
{
    sender.scale=sender.scale-_lastScale+1;
    
    sceneViewOne.transform=sceneViewOne.transform=CGAffineTransformScale(sceneViewOne.transform, sender.scale,sender.scale);
    
    _lastScale=sender.scale;
}

/**
 *  镜头切换
 */
- (void)buildLensBtnView
{
    lensBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lensBtn.frame = CGRectMake(190, 170, 50, 50);
    [lensBtn setImage:[UIImage imageNamed:@"switch_highlighted"] forState:UIControlStateNormal];
    [lensBtn addTarget:self action:@selector(lensDragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [lensBtn addTarget:self action:@selector(lensDragEnded:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.x = 0;
    [self.view addSubview:lensBtn];
    
    UIButton * lensCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lensCloseBtn.frame = CGRectMake(0, 0, 15, 15);
    [lensCloseBtn setImage:[UIImage imageNamed:@"ZDBtn3"] forState:UIControlStateNormal];
    [lensCloseBtn addTarget:self action:@selector(lensCloseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [lensBtn addSubview:lensCloseBtn];
}

- (void)lensDragMoving:(UIControl *)c withEvent:ev
{
    self.x=1;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}

- (void)lensCloseBtnClick:(UIButton *)btn
{
    [lensBtn removeFromSuperview];
}

- (void)lensDragEnded: (UIControl *)c withEvent:ev
{
    if (self.x==0)
    {
        WS(weak);
        [lensBtn addActionBlock:^(id sender) {
            UIButton *bu = sender;
            bu.enabled = NO;
            bu.selected = !bu.selected;
            [weak.manager switchCamera:bu.selected didFinishChanceBlock:^{
                bu.enabled = YES;
            }];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    self.x=0;
}

/**
 *  闪光灯
 */
- (void)buildFlashView
{
    flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    flashBtn.frame = CGRectMake(190, 170, 50, 50);
    [flashBtn setImage:[UIImage imageNamed:@"flash_highlighted"] forState:UIControlStateNormal];
    [flashBtn addTarget:self action:@selector(flashDragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [flashBtn addTarget:self action:@selector(flashBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.x = 0;
    [self.view addSubview:flashBtn];
    
    UIButton * flashCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    flashCloseBtn.frame = CGRectMake(0, 0, 15, 15);
    [flashCloseBtn setImage:[UIImage imageNamed:@"ZDBtn3"] forState:UIControlStateNormal];
    [flashCloseBtn addTarget:self action:@selector(flashCloseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [flashBtn addSubview:flashCloseBtn];
}

- (void)flashDragMoving:(UIControl *)c withEvent:ev
{
    self.x = 1;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}

- (void)flashCloseBtnClick:(UIButton *)btn
{
    [flashBtn removeFromSuperview];
}

- (void)flashBtnAction:(UIButton *)btn
{
    if (self.x==0)
    {
        WS(weak);
        [flashBtn addActionBlock:^(id sender) {
            [weak.manager switchFlashMode:sender];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    self.x = 0;
}

/**
 *  取景框切换
 */
- (void)buildScene
{
    sceneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sceneBtn.frame = CGRectMake(100, 170, 50, 50);
    [sceneBtn setImage:[UIImage imageNamed:@"landscape_highlighted"] forState:UIControlStateNormal];
    [sceneBtn addTarget:self action:@selector(sceneDragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [sceneBtn addTarget:self action:@selector(sceneBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.x = 0;
    [self.view addSubview:sceneBtn];
    
    UIButton * sceneCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sceneCloseBtn.frame = CGRectMake(0, 0, 15, 15);
    [sceneCloseBtn setImage:[UIImage imageNamed:@"ZDBtn3"] forState:UIControlStateNormal];
    [sceneCloseBtn addTarget:self action:@selector(sceneCloseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [sceneBtn addSubview:sceneCloseBtn];
}

- (void)sceneDragMoving:(UIControl *)c withEvent:ev
{
    self.x = 1;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}

- (void)sceneCloseBtnClick:(UIButton *)btn
{
    [sceneBtn removeFromSuperview];
}

- (void)sceneBtnAction:(UIButton *)btn
{
    if (self.x == 0)
    {
        if (t==1)
        {
            self.view.backgroundColor = [UIColor blackColor];
            [sceneViewOne removeFromSuperview];
            [sceneViewThree removeFromSuperview];
            
            sceneViewTwo = [[UIView alloc]initWithFrame:CGRectMake(50, 20, AppWidth-100,AppWidth)];
            
            [self.view addSubview:sceneViewTwo];
            [self.view bringSubviewToFront:downView];
            [self.view bringSubviewToFront:upView];
            DJCameraManager *manager = [[DJCameraManager alloc] init];
            // 传入View的frame 就是摄像的范围
            [manager configureWithParentLayer:sceneViewTwo];
            manager.delegate = self;
            self.manager = manager;
            
//            UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
//            [pinchRecognizer setDelegate:self];
//            [sceneViewTwo addGestureRecognizer:pinchRecognizer];
            
            t=2;
            return;
        }
        
        if (t==2)
        {
            self.view.backgroundColor = [UIColor blackColor];
            [sceneViewTwo removeFromSuperview];
            [sceneViewThree removeFromSuperview];
            
            sceneViewOne = [[UIView alloc]initWithFrame:CGRectMake(0, 20, AppWidth, 200)];
            
            [self.view addSubview:sceneViewOne];
            [self.view bringSubviewToFront:downView];
            [self.view bringSubviewToFront:upView];
            DJCameraManager *manager = [[DJCameraManager alloc] init];
            // 传入View的frame 就是摄像的范围
            [manager configureWithParentLayer:sceneViewOne];
            manager.delegate = self;
            self.manager = manager;
            
//            UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
//            [pinchRecognizer setDelegate:self];
//            [sceneViewOne addGestureRecognizer:pinchRecognizer];
            
            t=3;
            return;
        }
        
        if (t==3)
        {
            self.view.backgroundColor = [UIColor blackColor];
            [sceneViewOne removeFromSuperview];
            [sceneViewTwo removeFromSuperview];
            sceneViewThree = [[UIView alloc]initWithFrame:CGRectMake(0, 20, AppWidth, AppWidth)];
            
            [self.view addSubview:sceneViewThree];
            [self.view bringSubviewToFront:downView];
            [self.view bringSubviewToFront:upView];
            DJCameraManager *manager = [[DJCameraManager alloc] init];
            // 传入View的frame 就是摄像的范围
            [manager configureWithParentLayer:sceneViewThree];
            manager.delegate = self;
            self.manager = manager;
            
//            UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
//            [pinchRecognizer setDelegate:self];
//            [sceneViewThree addGestureRecognizer:pinchRecognizer];
            
            t=1;
            return;
        }
    }
    self.x = 0;
}

/**
 *  HDR
 */
- (void)buildHDR
{
    hdrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hdrBtn.frame = CGRectMake(125, 170, 50, 50);
    [hdrBtn setImage:[UIImage imageNamed:@"HDR_highlighted"] forState:UIControlStateNormal];
    [hdrBtn addTarget:self action:@selector(hdrDragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    self.x = 0;
    [hdrBtn addTarget:self action:@selector(hdrBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hdrBtn];
    
    UIButton * hdrCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hdrCloseBtn.frame = CGRectMake(0, 0, 15, 15);
    [hdrCloseBtn setImage:[UIImage imageNamed:@"ZDBtn3"] forState:UIControlStateNormal];
    [hdrCloseBtn addTarget:self action:@selector(hdrCloseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [hdrBtn addSubview:hdrCloseBtn];
}

- (void)hdrDragMoving:(UIControl *)c withEvent:ev
{
    self.x = 1;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}

- (void)hdrCloseBtnClick:(UIButton *)btn
{
    [hdrBtn removeFromSuperview];
}

- (void)hdrBtnAction:(UIButton *)btn
{
    if (self.x == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此功能暂未实现，敬请期待!" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"关闭", nil];
        [alert show];
    }
    self.x = 0;
}
/**
 *  二维码
 */
- (void)buildScan
{
    qrcodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qrcodeBtn.frame = CGRectMake(145, 170, 50, 50);
    [qrcodeBtn setImage:[UIImage imageNamed:@"scan_highlighted"] forState:UIControlStateNormal];
    [qrcodeBtn addTarget:self action:@selector(qrcodeDragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    self.x = 0;
    [qrcodeBtn addTarget:self action:@selector(qrcodeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qrcodeBtn];
    
    UIButton * qrcodeCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qrcodeCloseBtn.frame = CGRectMake(0, 0, 15, 15);
    [qrcodeCloseBtn setImage:[UIImage imageNamed:@"ZDBtn3"] forState:UIControlStateNormal];
    [qrcodeCloseBtn addTarget:self action:@selector(qrcodeCloseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [qrcodeBtn addSubview:qrcodeCloseBtn];
}

- (void)qrcodeDragMoving:(UIControl *)c withEvent:ev
{
    self.x = 1;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}

- (void)qrcodeCloseBtnClick:(UIButton *)btn
{
    [qrcodeBtn removeFromSuperview];
}

/**
 *   二维码
 */
- (void)qrcodeBtnAction:(UIButton *)btn
{
    if (self.x == 0)
    {
        ScanViewController * scanVC = [[ScanViewController alloc] init];
        [self.navigationController pushViewController:scanVC animated:YES];
    }
    self.x = 0;
}
/**
 *  声音
 */
- (void)buildVoice
{
    voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBtn.frame = CGRectMake(100, 190, 50, 50);
    [voiceBtn setImage:[UIImage imageNamed:@"voice_highlighted"] forState:UIControlStateNormal];
    [voiceBtn addTarget:self action:@selector(voiceDragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    self.x = 0;
    [voiceBtn addTarget:self action:@selector(voiceBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:voiceBtn];
    
    UIButton * voiceCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceCloseBtn.frame = CGRectMake(0, 0, 15, 15);
    [voiceCloseBtn setImage:[UIImage imageNamed:@"ZDBtn3"] forState:UIControlStateNormal];
    [voiceCloseBtn addTarget:self action:@selector(voiceCloseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [voiceBtn addSubview:voiceCloseBtn];
}

- (void)voiceDragMoving:(UIControl *)c withEvent:ev
{
    self.x = 1;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}

- (void)voiceCloseBtnClick:(UIButton *)btn
{
    [voiceBtn removeFromSuperview];
}

- (void)voiceBtnAction:(UIButton *)btn
{
    if (self.x == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此功能暂未实现，敬请期待!" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"关闭", nil];
        [alert show];
    }
    self.x = 0;
}

- (IBAction)cameraBtn:(UITapGestureRecognizer *)sender
{
    //将我们的storyBoard实例化，“Main”为StoryBoard的名称
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //将第二个控制器实例化，"SecondViewController"为我们设置的控制器的ID
    WCLRecordVideoVC *recordVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"WCLRecordVideoVC"];
    
    //跳转事件
    [self.navigationController pushViewController:recordVC animated:YES];
    
}
/**
 *  摄像
 */
- (void)buildCamera
{
    cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame = CGRectMake(100, 230, 50, 50);
    [cameraBtn setImage:[UIImage imageNamed:@"camera_highlighted"] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(cameraDragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    self.x = 0;
    [cameraBtn addTarget:self action:@selector(cameraBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraBtn];
    
    UIButton * cameraCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraCloseBtn.frame = CGRectMake(0, 0, 15, 15);
    [cameraCloseBtn setImage:[UIImage imageNamed:@"ZDBtn3"] forState:UIControlStateNormal];
    [cameraCloseBtn addTarget:self action:@selector(cameraCloseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [cameraBtn addSubview:cameraCloseBtn];
}

- (void)cameraDragMoving:(UIControl *)c withEvent:ev
{
    self.x = 1;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}

- (void)cameraCloseBtnClick:(UIButton *)btn
{
    [cameraBtn removeFromSuperview];
}

- (void)cameraBtnAction:(UIButton *)btn
{
    if (self.x == 0)
    {
        WechatShortVideoController *wechatShortVideoController = [[WechatShortVideoController alloc] init];
        wechatShortVideoController.delegate = self;
        [self presentViewController:wechatShortVideoController animated:YES completion:^{}];
    }
    self.x = 0;
}
/**
 *  连拍
 */
- (void)buildShoot
{
    shootButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shootButton.frame = CGRectMake(150, 260, 50, 50);
    [shootButton setImage:[UIImage imageNamed:@"shoot_highlighted"] forState:UIControlStateNormal];
    [shootButton addTarget:self action:@selector(shootDragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    self.x = 0;
    [shootButton addTarget:self action:@selector(shootBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shootButton];
    
    UIButton * shootCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shootCloseBtn.frame = CGRectMake(0, 0, 15, 15);
    [shootCloseBtn setImage:[UIImage imageNamed:@"ZDBtn3"] forState:UIControlStateNormal];
    [shootCloseBtn addTarget:self action:@selector(shootCloseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [shootButton addSubview:shootCloseBtn];
}

- (void)shootDragMoving:(UIControl *)c withEvent:ev
{
    self.x = 1;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}

- (void)shootCloseBtnClick:(UIButton *)btn
{
    [shootButton removeFromSuperview];
}

- (void)shootBtnAction:(UIButton *)btn
{
    if (self.x == 0)
    {
        WS(weak);
        [shootButton addActionBlock:^(id sender)
         {
             [weak.manager takePhotoWithImageBlock:^(UIImage *originImage, UIImage *scaledImage, UIImage *croppedImage)
              {
                  if (croppedImage)
                  {
                      cameraImage.image = croppedImage;
                      
                      UITapGestureRecognizer * ImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoLibraryClick:)];
                      [ImageTap setNumberOfTapsRequired:1];
                      ImageTap.delegate = self;
                      [cameraImage addGestureRecognizer:ImageTap];
                      
                      for (int i =0; i<3; i++)
                      {
                          //保存到本地的相册里面(暂定为连拍次数)
                          UIImageWriteToSavedPhotosAlbum(croppedImage, self, @selector(imagePickerController:didFinishPickingImage:editingInfo:), NULL);
                      }
                      
                  }
              }];
         } forControlEvents:UIControlEventTouchUpInside];
    }
    self.x = 0;
}

- (void)photoLibraryClick:(UITapGestureRecognizer *)tap
{
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

- (void)downMenuButtonClick:(UIButton *)button
{
    if (upArray.count > 7)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"最多只能添加8个标签" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"关闭", nil];
        [alert show];
        
        return;
    }
    //    viewHeight += 50;
    //  常用标签
    favoriteview = [[labelView alloc] init];
    
    viewHeight = 50;
    
    switch (button.tag)
    {
        case 0:
        {
            if ([upBtnArray containsObject:[downBtnArray objectAtIndex:0]])
            {
                return;
            }
            else
            {
                [upBtnArray removeAllObjects];
                [upBtnArray addObject:[downBtnArray objectAtIndex:0]];
                
                NSSet * set = [NSSet setWithArray:upBtnArray];
                upBtnArray = [NSMutableArray arrayWithArray:[set allObjects]];
                [upArray addObjectsFromArray:upBtnArray];
                
                if(upArray.count == 0)
                {
                    favoriteview.frame = CGRectZero;
                }
                else
                {
                    favoriteview.frame = CGRectMake(0, viewHeight, 320, 220);
                    [favoriteview createViewFrame:upArray title:@""];
                }
                favoriteview.addTagDelegate = self;
                [upView addSubview:favoriteview];
                viewHeight += favoriteview.bounds.size.height;
                
            }
        }
            break;
        case 1:
        {
            if ([upBtnArray containsObject:[downBtnArray objectAtIndex:1]])
            {
                return;
            }
            else
            {
                [upBtnArray removeAllObjects];
                [upBtnArray addObject:[downBtnArray objectAtIndex:1]];
                
                NSSet * set = [NSSet setWithArray:upBtnArray];
                upBtnArray = [NSMutableArray arrayWithArray:[set allObjects]];
                [upArray addObjectsFromArray:upBtnArray];
                
                if(upArray.count == 0)
                {
                    favoriteview.frame = CGRectZero;
                }
                else
                {
                    favoriteview.frame = CGRectMake(0, viewHeight, 320, 220);
                    [favoriteview createViewFrame:upArray title:@""];
                }
                favoriteview.addTagDelegate = self;
                [upView addSubview:favoriteview];
                viewHeight += favoriteview.bounds.size.height;
                
            }
        }
            break;
        case 2:
        {
            if ([upBtnArray containsObject:[downBtnArray objectAtIndex:2]])
            {
                return;
            }
            else
            {
                [upBtnArray removeAllObjects];
                
                [upBtnArray addObject:[downBtnArray objectAtIndex:2]];
                
                NSSet * set = [NSSet setWithArray:upBtnArray];
                upBtnArray = [NSMutableArray arrayWithArray:[set allObjects]];
                [upArray addObjectsFromArray:upBtnArray];
                
                
                if(upArray.count == 0)
                {
                    favoriteview.frame = CGRectZero;
                }
                else
                {
                    favoriteview.frame = CGRectMake(0, viewHeight, 320, 220);
                    [favoriteview createViewFrame:upArray title:@""];
                }
                favoriteview.addTagDelegate = self;
                [upView addSubview:favoriteview];
                viewHeight += favoriteview.bounds.size.height;
                
            }
        }
            break;
        case 3:
        {
            if ([upBtnArray containsObject:[downBtnArray objectAtIndex:3]])
            {
                return;
            }
            else
            {
                [upBtnArray removeAllObjects];
                [upBtnArray addObject:[downBtnArray objectAtIndex:3]];
                NSSet * set = [NSSet setWithArray:upBtnArray];
                upBtnArray = [NSMutableArray arrayWithArray:[set allObjects]];
                [upArray addObjectsFromArray:upBtnArray];
                
                if(upArray.count == 0)
                {
                    favoriteview.frame = CGRectZero;
                }
                else
                {
                    favoriteview.frame = CGRectMake(0, viewHeight, 320, 220);
                    [favoriteview createViewFrame:upArray title:@""];
                }
                favoriteview.addTagDelegate = self;
                [upView addSubview:favoriteview];
                viewHeight += favoriteview.bounds.size.height;
                
            }
        }
            break;
        case 4:
        {
            if ([upBtnArray containsObject:[downBtnArray objectAtIndex:4]])
            {
                return;
            }
            else
            {
                [upBtnArray removeAllObjects];
                [upBtnArray addObject:[downBtnArray objectAtIndex:4]];
                NSSet * set = [NSSet setWithArray:upBtnArray];
                upBtnArray = [NSMutableArray arrayWithArray:[set allObjects]];
                [upArray addObjectsFromArray:upBtnArray];
                
                if(upArray.count == 0)
                {
                    favoriteview.frame = CGRectZero;
                }
                else
                {
                    favoriteview.frame = CGRectMake(0, viewHeight, 320, 220);
                    [favoriteview createViewFrame:upArray title:@""];
                }
                favoriteview.addTagDelegate = self;
                [upView addSubview:favoriteview];
                viewHeight += favoriteview.bounds.size.height;
                
            }
        }
            break;
        case 5:
        {
            if ([upBtnArray containsObject:[downBtnArray objectAtIndex:5]])
            {
                return;
            }
            else
            {
                [upBtnArray removeAllObjects];
                [upBtnArray addObject:[downBtnArray objectAtIndex:5]];
                NSSet * set = [NSSet setWithArray:upBtnArray];
                upBtnArray = [NSMutableArray arrayWithArray:[set allObjects]];
                [upArray addObjectsFromArray:upBtnArray];
                
                if(upArray.count == 0)
                {
                    favoriteview.frame = CGRectZero;
                }
                else
                {
                    favoriteview.frame = CGRectMake(0, viewHeight, 320, 220);
                    [favoriteview createViewFrame:upArray title:@""];
                }
                favoriteview.addTagDelegate = self;
                [upView addSubview:favoriteview];
                viewHeight += favoriteview.bounds.size.height;
                
            }
        }
            break;
        case 6:
        {
            if ([upBtnArray containsObject:[downBtnArray objectAtIndex:6]])
            {
                return;
            }
            else
            {
                [upBtnArray removeAllObjects];
                [upBtnArray addObject:[downBtnArray objectAtIndex:6]];
                NSSet * set = [NSSet setWithArray:upBtnArray];
                upBtnArray = [NSMutableArray arrayWithArray:[set allObjects]];
                [upArray addObjectsFromArray:upBtnArray];
                
                if(upArray.count == 0)
                {
                    favoriteview.frame = CGRectZero;
                }
                else
                {
                    favoriteview.frame = CGRectMake(0, viewHeight, 320, 220);
                    [favoriteview createViewFrame:upArray title:@""];
                }
                favoriteview.addTagDelegate = self;
                [upView addSubview:favoriteview];
                viewHeight += favoriteview.bounds.size.height;
                
            }
        }
            break;
        case 7:
        {
            if ([upBtnArray containsObject:[downBtnArray objectAtIndex:7]])
            {
                return;
            }
            else
            {
                [upBtnArray removeAllObjects];
                [upBtnArray addObject:[downBtnArray objectAtIndex:7]];
                NSSet * set = [NSSet setWithArray:upBtnArray];
                upBtnArray = [NSMutableArray arrayWithArray:[set allObjects]];
                [upArray addObjectsFromArray:upBtnArray];
                
                if(upArray.count == 0)
                {
                    favoriteview.frame = CGRectZero;
                }
                else
                {
                    favoriteview.frame = CGRectMake(0, viewHeight, 320, 220);
                    [favoriteview createViewFrame:upArray title:@""];
                }
                favoriteview.addTagDelegate = self;
                [upView addSubview:favoriteview];
                viewHeight += favoriteview.bounds.size.height;
                
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"取消");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo
{
    if (_picker == picker)
    {//这里的条件随便你自己定义了
        //**主要就是下面这句话，会让你继续回到take camera的页面
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/**
 *  拍照按钮
 */

- (void)initPickButton
{
    static CGFloat buttonW = 50;
    
    takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    takePhotoBtn.frame = CGRectMake(AppWidth/2-buttonW/2, AppWidth+120+(AppHeigt-AppWidth-150)/2 - buttonW/2, buttonW, buttonW);
    [takePhotoBtn setImage:[UIImage imageNamed:@"takePhoto_highlighted"] forState:UIControlStateNormal];
    [takePhotoBtn addTarget:self action:@selector(takePhotoDragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [takePhotoBtn addTarget:self action:@selector(takePhotoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.x = 0;
    [self.view addSubview:takePhotoBtn];
}

- (void)takePhotoDragMoving:(UIControl *)c withEvent:ev
{
    self.x = 1;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}
/**
 *   二维码
 */
- (void)takePhotoBtnAction:(UIButton *)btn
{
    if (self.x == 0)
    {
        WS(weak);
        [takePhotoBtn addActionBlock:^(id sender)
         {
             [weak.manager takePhotoWithImageBlock:^(UIImage *originImage, UIImage *scaledImage, UIImage *croppedImage)
              {
                  if (croppedImage)
                  {
                      PhotoViewController * photoVC = [[PhotoViewController alloc] init];
                      photoVC.image = croppedImage;
                      [self.navigationController pushViewController:photoVC animated:YES];
                  }
              }];
         } forControlEvents:UIControlEventTouchUpInside];
    }
    self.x = 0;
}

- (void)initDismissButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(AppWidth-75, AppWidth+120+(AppHeigt-AppWidth-140)/2, 40, 22);
    [button setImage:[UIImage imageNamed:@"close_cha"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonClick
{
    [self.navigationController popViewControllerAnimated:NO];
}

/**
 *  点击对焦
 *
 *  @param touches
 *  @param event
 */

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    [self.manager focusInPoint:point];
}

- (UIButton*)buildButton:(CGRect)frame
            normalImgStr:(NSString*)normalImgStr
         highlightImgStr:(NSString*)highlightImgStr
          selectedImgStr:(NSString*)selectedImgStr
              parentView:(UIView*)parentView
{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (normalImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:normalImgStr] forState:UIControlStateNormal];
    }
    if (highlightImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:highlightImgStr] forState:UIControlStateHighlighted];
    }
    if (selectedImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:selectedImgStr] forState:UIControlStateSelected];
    }
    [parentView addSubview:btn];
    return btn;
}

#pragma -mark DJCameraDelegate
- (void)cameraDidFinishFocus
{
    NSLog(@"对焦结束了");
}

- (void)cameraDidStareFocus
{
    NSLog(@"开始对焦");
}

@end