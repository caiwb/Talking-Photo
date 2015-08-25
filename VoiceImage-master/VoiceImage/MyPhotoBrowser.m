//
//  MyPhotoBrowser.m
//  VoiceImage
//
//  Created by SPG on 7/3/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import "MyPhotoBrowser.h"
#import "AudioRecorder.h"
#import "global.h"
#import "HttpHelper.h"
#import "PhotoDataProvider.h"
#import "HttpHelper.h"
#import "IATConfig.h"
#import "ISRDataHelper.h"

@implementation MyPhotoBrowser

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.x = 0;
    rect.origin.y = rect.size.height / 2 - 95;
    rect.size.height = 190;
    
    self.recordingAudioPlot = [[EZAudioPlotGL alloc] initWithFrame:rect];
    self.recordingAudioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    UIColor* color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    self.recordingAudioPlot.backgroundColor = color;
    self.recordingAudioPlot.plotType        = EZPlotTypeBuffer;
    self.recordingAudioPlot.shouldFill      = NO;
    self.recordingAudioPlot.shouldMirror    = YES;
    self.recordingAudioPlot.hidden = YES;
    self.recordingAudioPlot.gain = 4.0;
    
    [self.view addSubview:self.recordingAudioPlot];
    
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

- (void)setNavBarAppearance:(BOOL)animated
{
    
}

-(void)startRecord{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DISABLE_GRIDVIEW"
                                                        object:nil];
    
//    [[AudioRecorder sharedInstance] startRecord];
    if (_iFlySpeechRecognizer == nil){
        [self initRecognizer];
    }
    
    self.recordingAudioPlot.hidden = NO;
    [self.view bringSubviewToFront:self.recordingAudioPlot];
    [self.recordingAudioPlot clear];
    [self.microphone startFetchingAudio];
}

-(void)stopRecord{
    self.recordingAudioPlot.hidden = YES;
    [self.microphone stopFetchingAudio];
    [self foldAllPhotos];
    
    NSURL* url = [[AudioRecorder sharedInstance] stopRecord];
    if (url != nil) {
        [HttpHelper search:self withSelector:@selector(searchResponse:) voicePath:[url path] tags:tags];
    }
}

-(void)foldAllPhotos{
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_FOLD_PHOTO_NOTIFICATION object:nil];
}

-(void)searchResponse:(NSData*)data {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ENABLE_GRIDVIEW"
                                                        object:nil];
    
    if (data == nil) {
        return;
    }
    NSError *error2;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error2];
    NSLog(@"%@", jsonDict);
    BOOL suc = [[jsonDict valueForKey:@"Status"] boolValue];
    if (suc) {
        NSArray* imagesList = (NSArray*)[jsonDict valueForKey:@"Images"];
        NSMutableArray* imgs = [[NSMutableArray alloc] init];
        for (NSDictionary* dict in imagesList) {
            [imgs addObject:[dict valueForKey:@"ImageName"]];
        }
//        NSMutableArray* array = [[NSMutableArray alloc] initWithObjects:@"IMG_0006.JPG", @"IMG_0007.JPG",@"IMG_0008.JPG",@"IMG_0009.JPG",nil];
        NSArray* arr = [[NSArray alloc] initWithArray:imgs];
        [[PhotoDataProvider sharedInstance] getPicturesByName:self withSelector:@selector(imagesRetrieved:) names:arr];
    }
    else{
        [PhotoDataProvider sharedInstance].photos = nil;
        [PhotoDataProvider sharedInstance].thumbs = nil;
        [self reloadData];
        [self reloadGridView];
    }
}

-(void)imagesRetrieved:(id)object{
    [self reloadData];
    [self reloadGridView];
}

-(void)startUpdateRecord {
    [[AudioRecorder sharedInstance] startRecord];
    
    self.recordingAudioPlot.hidden = NO;
    [self.recordingAudioPlot clear];
    [self.microphone startFetchingAudio];
}

-(void)scrollToBottom {
    [super scrollToBottom];
}

-(void)stopUpdateRecord:(NSString*)imageName imageData:(NSData*)imageData {
    self.recordingAudioPlot.hidden = YES;
    [self.microphone stopFetchingAudio];
    NSURL* url = [[AudioRecorder sharedInstance] stopRecord];
    
    if (url != nil) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        [array addObject:imageName];
        NSArray* arr = [[NSArray alloc] initWithArray:array];
        [HttpHelper uploadPhoto:self withSelector:@selector(uploadResponse:) imageName:arr imageData:imageData voicePath:[url path] date:nil location: nil];
    }
}

#pragma mark - 需要在此加入分词

-(void)stopUpdateRecordList:(NSArray*)imageName imageData:(NSArray*)imageData {
    //TOOD: upload group of images and one voice to website
    self.recordingAudioPlot.hidden = YES;
    [self.microphone stopFetchingAudio];
    
    NSURL* url = [[AudioRecorder sharedInstance] stopRecord];
    
    if (url != nil) {
        [HttpHelper uploadPhoto:self withSelector:@selector(uploadResponse:) imageName:imageName imageData:nil voicePath:[url path] date:nil location: nil];
    }
}

-(void)uploadResponse:(NSData*)data {
    NSError *error2;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error2];
    NSLog(@"%@", jsonDict);
    BOOL suc = [[jsonDict valueForKey:@"status"] boolValue];
    if (suc) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Voice Image Updated" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [myAlertView show];
    }
}

- (void)   microphone:(EZMicrophone *)microphone
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

#pragma mark - IFlySpeechRecognizerDelegate

/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s",__func__);
    
    if (error.errorCode == 0 ) {
        
    }else {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Not Recoganized" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [myAlertView show];
    }
    
}

/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    self.result = [NSString stringWithFormat:@"%@%@", self.result,resultFromJson];
    
    if (isLast){
        NSLog(@"听写结果(json)：%@测试",  self.result);
    }
}

@end
