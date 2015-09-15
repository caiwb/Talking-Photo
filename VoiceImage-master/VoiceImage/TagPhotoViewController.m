//
//  TagPhotoViewController.m
//  VoiceImage
//
//  Created by SPG on 7/2/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import "TagPhotoViewController.h"
#import <UIKit/UIKit.h>
#import "HttpHelper.h"
#import <AVFoundation/AVFoundation.h>
#include <AssetsLibrary/AssetsLibrary.h>
#import "CompleteViewController.h"
#import "global.h"
#import "IATConfig.h"
#import "ISRDataHelper.h"
#import "AFNetworking.h"
#import "DataBaseHelper.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "RectangleView.h"

#define FACE_RECT_TAG 1
#define FACE_LABEL_TAG 2
#define angelToRandian(x) ((x)/180.0*M_PI)

@interface TagPhotoViewController () <CLLocationManagerDelegate, HttpProtocol>

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (weak, nonatomic) IBOutlet UIButton *deleteDescBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UIImageView *topBar;
@property (weak, nonatomic) IBOutlet UIButton *faceDetectBtn;
@property (strong , nonatomic) NSMutableArray * faceList;
@property (strong , nonatomic) NSMutableArray * squareArray;
@property (copy, nonatomic) NSString * completeResult;

/** namingFaceTag
/           -1: 对照片tag
            其他: 对相应的face tag
 */
@property (assign , nonatomic) int namingFaceTag;

@end

@implementation TagPhotoViewController

-(NSMutableArray *)faceList
{
    if (!_faceList) {
        _faceList = [[NSMutableArray alloc] init];
    }
    return _faceList;
}

-(NSMutableArray *)squareArray
{
    if (!_squareArray) {
        _squareArray = [[NSMutableArray alloc] init];
    }
    return _squareArray;
}

-(NSString *)completeResult
{
    if (!_completeResult) {
        _completeResult = [[NSString alloc] init];
    }
    return _completeResult;
}

-(void)initRecognizer
{
    NSLog(@"%s",__func__);
    
    //单例模式，无UI的实例
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    }
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        
        //设置最长录音时间
        [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //网络等待时间
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //设置采样率，推荐使用16K
        [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            //设置语言
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //设置方言
            [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        //设置是否返回标点符号
        [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.imageView setImage:self.image];
    
    [self saveImage];
    self.desc = @"";
    self.tagSR.text = @"";
    [self.deleteDescBtn setImage:[UIImage imageNamed:@"Dzst_delect_desc"] forState:UIControlStateNormal];
    self.deleteDescBtn.hidden = YES;
    self.uploadBtn.hidden = YES;
    
    //face detect
    self.faceDetectBtn.hidden = YES;
    [HttpHelper sharedHttpHelper].delegate = self;
    _namingFaceTag = -1;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }
    
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    self.recordingAudioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    UIColor * color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    self.recordingAudioPlot.backgroundColor = color;
    self.topBar.backgroundColor = color;
    self.topBar.hidden = NO;
    self.recordingAudioPlot.plotType        = EZPlotTypeBuffer;
    self.recordingAudioPlot.shouldFill      = NO;
    self.recordingAudioPlot.shouldMirror    = YES;
    self.recordingAudioPlot.gain = 4.0;
//    UIColor * labelColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Dzst_take-photo_upbg.png"]];
    [_tagSR setBackgroundColor:color];
    self.tagSR.hidden = YES;
    self.deleteDescBtn.hidden = YES;
    self.recordingAudioPlot.hidden = YES;
    self.pressCircle.hidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tagUp:(UIButton *)sender {
    //TODO: http post the image and voice to server
    self.recordingAudioPlot.hidden = YES;
    self.pressCircle.hidden = YES;
    [self.pressCircle.layer removeAllAnimations];
    [self.microphone stopFetchingAudio];
    [_iFlySpeechRecognizer stopListening];
}

- (IBAction)tagDown:(UIButton *)sender {
    //TODO: start record the voice
    self.pressCircle.hidden = NO;
    [self runSpinAnimationOnView:self.pressCircle duration:1.0f rotations:1.0f repeat:1000];
//    [[AudioRecorder sharedInstance] startRecord];
    
    self.tagSR.hidden = YES;
    self.deleteDescBtn.hidden = YES;
    self.tagSR.text = @"";
    self.recordingAudioPlot.hidden = NO;
    [self.recordingAudioPlot clear];
    [self.microphone startFetchingAudio];
    
    if (_iFlySpeechRecognizer == nil){
        [self initRecognizer];//初始化识别对象
    }
    //start SR interface
    [_iFlySpeechRecognizer cancel];
    //设置音频来源为麦克风
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    //设置听写结果格式为json
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    [_iFlySpeechRecognizer setDelegate:self];
    BOOL ret = [_iFlySpeechRecognizer startListening];
    if (ret == NO){
        NSLog(@"failed");
    }
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (IBAction)skipClicked:(UIButton *)sender {
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    if ([r currentReachabilityStatus]==NotReachable) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"无网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

#pragma -----test
//    self.desc = @"这是我在北京微软大厦拍的照片";
    self.view.userInteractionEnabled = NO;
    
    NSString * imagePathString = [self.imagePath absoluteString];
    NSMutableDictionary * insertParams = [NSMutableDictionary dictionary];
    insertParams[@"imageName"] = self.imageName;
    insertParams[@"imagePath"] = imagePathString;
    insertParams[@"desc"] = self.desc;

    [[HttpHelper sharedHttpHelper] AFNetworkingForVoiceTag:self.desc forInserting:insertParams orSearching:nil];
    
    CompleteViewController *complete = [[CompleteViewController alloc] init];
    [self.navigationController pushViewController:complete animated:YES];
}

- (IBAction)faceDetect:(id)sender {
    if ([self.faceList count] != 0) {
        return;
    }
    [[HttpHelper sharedHttpHelper] AFNetworingForFaceDetectWithImage:self.image imageName:self.imageName];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        _namingFaceTag = (int)gesture.view.tag - FACE_RECT_TAG;
        self.completeResult = @"";
        UILabel * label = (UILabel *)[self.view viewWithTag:_namingFaceTag + FACE_LABEL_TAG];
        label.text = @"";
        
        //人脸方框抖动效果
        CAKeyframeAnimation* anim = [CAKeyframeAnimation animation];
        anim.keyPath = @"transform.rotation";
        anim.values = @[@(angelToRandian(-5)),@(angelToRandian(5)),@(angelToRandian(-5))];
        anim.repeatCount = MAXFLOAT;
        anim.duration = 0.2;
        [gesture.view.layer addAnimation:anim forKey:nil];
        
        //TODO: start record the voice
        self.pressCircle.hidden = NO;
        [self runSpinAnimationOnView:self.pressCircle duration:1.0f rotations:1.0f repeat:1000];
        //    [[AudioRecorder sharedInstance] startRecord];
        
        self.tagSR.hidden = YES;
        self.deleteDescBtn.hidden = YES;
        self.tagSR.text = @"";
        self.recordingAudioPlot.hidden = NO;
        [self.recordingAudioPlot clear];
        [self.microphone startFetchingAudio];
        
        if (_iFlySpeechRecognizer == nil){
            [self initRecognizer];//初始化识别对象
        }
        //start SR interface
        [_iFlySpeechRecognizer cancel];
        //设置音频来源为麦克风
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        //设置听写结果格式为json
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        [_iFlySpeechRecognizer setDelegate:self];
        BOOL ret = [_iFlySpeechRecognizer startListening];
        if (ret == NO){
            NSLog(@"failed");
        }
        
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        [gesture.view.layer removeAllAnimations];
        
        //TODO: stop record the voice
        self.recordingAudioPlot.hidden = YES;
        self.pressCircle.hidden = YES;
        [self.pressCircle.layer removeAllAnimations];
        [self.microphone stopFetchingAudio];
        [_iFlySpeechRecognizer stopListening];
    }

    
    NSLog(@"---------------------------------%d",_namingFaceTag);
}

#pragma mark -- http‘s face detect done delegate method
-(void)isFaceDetectDone:(BOOL)suc faceList:(NSArray *)faceList
{
    self.faceList = [NSMutableArray arrayWithArray:faceList];

    for (int i=0; i<faceList.count; i++) {
        RectangleView * faceRect = [[RectangleView alloc] initWithFrame:CGRectMake([faceList[i][2][0] floatValue], [faceList[i][2][1] floatValue], [faceList[i][2][2] floatValue], [faceList[i][2][3] floatValue])];
        faceRect.backgroundColor = [UIColor clearColor];
        [self.view addSubview:faceRect];
        faceRect.tag = FACE_RECT_TAG+i;
        CGRect labelRect = CGRectMake(faceRect.frame.origin.x-50+faceRect.frame.size.width/2, faceRect.frame.origin.y-50, 100, 40);
        UILabel * faceLabel = [[UILabel alloc] initWithFrame:labelRect];
        [faceLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]];
        faceLabel.text = faceList[i][1];
        faceLabel.textColor = [UIColor whiteColor];
        [faceLabel setTextAlignment:NSTextAlignmentCenter];
        faceLabel.tag = FACE_LABEL_TAG+i;
        [self.view addSubview:faceLabel];
        [self.squareArray addObject:faceRect];
        //给脸框添加长按手势
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressRecognizer.allowableMovement = 30;
        [faceRect addGestureRecognizer:longPressRecognizer];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void) saveImage{
//    UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Request to save the image to camera roll
    [library writeImageToSavedPhotosAlbum:[self.image CGImage] orientation:(ALAssetOrientation)[self.image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"error");
        } else {
            NSLog(@"url %@", assetURL);
            self.imagePath = assetURL;
            [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation* representation = [asset defaultRepresentation];
                
                // Retrieve the image orientation from the ALAsset
                UIImageOrientation orientation = UIImageOrientationUp;
                NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
                if (orientationValue != nil) {
                    orientation = [orientationValue intValue];
                }
                
                self.imageName =[representation filename];
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:5];
                self.uploadBtn.hidden = NO;
                self.faceDetectBtn.hidden = NO;
                [UIView commitAnimations];
                
                UIImage *imageToUpload = [UIImage imageWithCGImage:[representation fullResolutionImage] scale:1 orientation:orientation];
                NSData *imageData = UIImageJPEGRepresentation(imageToUpload, 0);
                self.data = imageData;
                NSLog(@"new image saved %@", self.imageName);
                
            } failureBlock:^(NSError *error) {
                
            }];
        }
    }];
    
}

- (void) microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as an array of float buffer arrays. What does that mean? Because the audio is coming in as a stereo signal the data is split into a left and right channel. So buffer[0] corresponds to the float* data for the left channel while buffer[1] corresponds to the float* data for the right channel.
    NSUInteger now = [[NSDate date] timeIntervalSince1970] * 1000;
    if (now - last > 50) {
        float sum = 0;
        for (int i = 0; i < bufferSize; i++) {
            float b = buffer[0][i];
            if (b > 0) {
                sum += b;
            }
        }
        
        sum /= bufferSize;
        if (sum < 0.001) {
            for (int i = 0; i < bufferSize; i++) {
                buffer[0][i] = 0;
            }
        }
        
        // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
        __weak typeof (self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
            [weakSelf.recordingAudioPlot updateBuffer:buffer[0]
                                       withBufferSize:bufferSize];
        });
        
        last = now;
    }
}

//------------------------------------------------------------------------------

- (void) microphone:(EZMicrophone *)microphone
        hasBufferList:(AudioBufferList *)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block. This will keep appending data to the tail of the audio file.
    if (self.isRecording)
    {
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
}

//------------------------------------------------------------------------------
#pragma mark - EZRecorderDelegate
//------------------------------------------------------------------------------

- (void)recorderDidClose:(EZRecorder *)recorder
{
    recorder.delegate = nil;
}

//------------------------------------------------------------------------------

- (void)recorderUpdatedCurrentTime:(EZRecorder *)recorder
{
    
}


/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
#pragma mark - IFlySpeechRecognizerDelegate

- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s",__func__);
    
    if (error.errorCode == 0 ) {
        
    }else {
        self.tagSR.text = @"识别错误，请重试！";
        self.tagSR.hidden = NO;
        self.deleteDescBtn.hidden = NO;
    }
    
}

/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
#pragma mark - IFlySpeechRecognizerDelegate

- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{

    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSString * resultFromJson = [ISRDataHelper stringFromJson:resultString];
    self.completeResult = [NSString stringWithFormat:@"%@%@",self.completeResult,resultFromJson];
    self.desc = [NSString stringWithFormat:@"%@%@", self.desc,resultFromJson];
    
    if (isLast) {
        
        // -1表示为照片tag
        // 其他数字表示为响应人脸tag
        if (_namingFaceTag != -1) {
            
            NSLog(@"%@",resultFromJson);
            UILabel * label = (UILabel *)[self.view viewWithTag:_namingFaceTag + FACE_LABEL_TAG];
            label.text = self.completeResult;
            NSLog(@"%@",label.text);
            _namingFaceTag = -1;
        }
        else {
            
            self.tagSR.text = self.desc;
            if ([self.desc isEqualToString:@""]) {
                self.tagSR.text = @"大嘴没听清！";
            }
            self.tagSR.hidden = NO;
            self.deleteDescBtn.hidden = NO;
        }
    }
}


- (IBAction)deleteDesc:(id)sender {
    self.desc = @"";
    self.tagSR.text = @"";
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
    //UIStatusBarStyleDefault = 0 黑色文字，浅色背景时使用
    //UIStatusBarStyleLightContent = 1 白色文字，深色背景时使用
}


@end
