//
//  ViewController.m
//  脸部扫描UI效果
//
//  Created by 陈伟杰 on 2018/11/30.
//  Copyright © 2018年 陈伟杰. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCapturePhotoCaptureDelegate>
{
    CAShapeLayer *_maskLayer;
}
@property(nonatomic,strong)AVCaptureSession *session;
@property(nonatomic,strong)AVCaptureDevice *device;
@property(nonatomic,strong)AVCapturePhotoSettings *outputSettings;
@property(nonatomic,strong)AVCaptureDeviceInput *deviceInput;
@property(nonatomic,strong)AVCapturePhotoOutput *photoOutput;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic,strong)UIImageView *photoImageView;

@property(nonatomic,strong)UIView *backView;
@property(nonatomic,strong)UIView *topBackView;
@property(nonatomic,strong)UIImageView *faceImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.session startRunning];
    //    [self loopline];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}

#pragma mark private method
- (void)setUpUI{
    
    if ([self.session canAddInput:self.deviceInput]) {
        [self.session addInput:self.deviceInput];
    }
    
    [self.photoOutput setPhotoSettingsForSceneMonitoring:self.outputSettings];
    [self.session addOutput:self.photoOutput];
    [self.view.layer addSublayer:self.previewLayer];
    [self setUpLayer];
    
    //    [self.view addSubview:self.QRImageView];
    //    [self.view addSubview:self.imageLine];
    //    [self creatAlphaLayer];
    
    [self.view addSubview:self.backView];
    [self.view addSubview:self.topBackView];
    [self.view addSubview:self.faceImageView];
}

- (void)setUpLayer{
    _maskLayer = [CAShapeLayer layer];
    //    _maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds cornerRadius:20].CGPath;
    _maskLayer.fillColor = [UIColor blackColor].CGColor;
    _maskLayer.strokeColor = [UIColor redColor].CGColor;
    _maskLayer.frame = self.backView.bounds;
    //    _maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
    //    _maskLayer.contentsScale = [UIScreen mainScreen].scale;
    _maskLayer.contents = (id)[UIImage imageNamed:@"photoOut"].CGImage;
    
    self.backView.layer.mask = _maskLayer;
    
    CALayer *canvasLayer = [CALayer layer];
    canvasLayer.frame = self.backView.frame;
    canvasLayer.backgroundColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:canvasLayer];
    
    CAShapeLayer *ovalShapeLayer = [CAShapeLayer layer];
    ovalShapeLayer.frame = canvasLayer.bounds;
    ovalShapeLayer.contents = (id)[UIImage imageNamed:@"photoIn"].CGImage;
    canvasLayer.mask = ovalShapeLayer;
    //
    CALayer *coverLayer = [CALayer layer];
    coverLayer.frame = CGRectMake(0, 0 , self.backView.bounds.size.width, 2);
    coverLayer.anchorPoint = CGPointMake(0, 0);
    coverLayer.position = CGPointMake(0, 0);
    coverLayer.backgroundColor = [[UIColor blueColor] CGColor];
    [canvasLayer addSublayer:coverLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position.y";
    animation.fromValue = @(0);
    animation.toValue = @(self.backView.bounds.size.height);
    animation.duration = 5;
    animation.repeatCount = HUGE;
    animation.removedOnCompletion = YES;
    
    [coverLayer addAnimation:animation forKey:nil];
    
}

- (AVCaptureDevice*)cameraWithPosition:(AVCaptureDevicePosition)position{
    AVCaptureDeviceDiscoverySession *deviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
    NSArray *deviceArray = deviceDiscoverySession.devices;
    for (AVCaptureDevice *device in deviceArray) {
        if (device.position == position) {
            return  device;
        }
    }
    return nil;
}

#pragma mark AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error{
}

#pragma mark lazy load
-(AVCaptureSession *)session{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    return _session;
}

-(AVCaptureDevice *)device{
    if (!_device) {
        _device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    }
    return _device;
}

-(AVCapturePhotoSettings *)outputSettings{
    if (!_outputSettings) {
        NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
        _outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    }
    return _outputSettings;
}

-(AVCaptureDeviceInput *)deviceInput{
    if (!_deviceInput) {
        _deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    }
    return _deviceInput;
}

- (AVCapturePhotoOutput *)photoOutput{
    if (!_photoOutput) {
        _photoOutput = [[AVCapturePhotoOutput alloc] init];
    }
    return _photoOutput;
}

-(AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_previewLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }
    return _previewLayer;
}

-(UIImageView *)photoImageView{
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    }
    return _photoImageView;
}

-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.width)];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0.5;
    }
    return _backView;
}

-(UIView *)topBackView{
    if (!_topBackView) {
        _topBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        _topBackView.backgroundColor = [UIColor blackColor];
        _topBackView.alpha = 0.5;
    }
    return _topBackView;
}

-(UIImageView *)faceImageView{
    if (!_faceImageView) {
        _faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 43, self.view.frame.size.width-10, self.view.frame.size.width)];
        [_faceImageView setImage:[UIImage imageNamed:@"photoXian"]];
    }
    return _faceImageView;
}
@end
