//
//  MyPhotoBrowser.h
//  VoiceImage
//
//  Created by SPG on 7/3/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import "MWPhotoBrowser.h"
#import "EZAudio.h"
#import "iflyMSC/iflyMSC.h"
#import "PhotoDataProvider.h"

@interface MyPhotoBrowser : MWPhotoBrowser <EZAudioPlayerDelegate,
EZMicrophoneDelegate,
EZRecorderDelegate,
IFlySpeechRecognizerDelegate,
PhotoDataProtocol>{
    NSArray* tags;
    NSUInteger last;
}

@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, strong) NSString * result;
@property (nonatomic, strong) EZAudioPlotGL *recordingAudioPlot;
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象

@property (strong, nonatomic) UIBarButtonItem * refresh;
@property (strong, nonatomic) UIBarButtonItem * trash;

-(void)setNavBarAppearance:(BOOL)animated;
-(void)startRecord;
-(void)stopRecord;

-(void)startUpdateRecord;
-(void)stopUpdateRecord:(NSString*)imageName imageData:(NSData*)imageData;
-(void)scrollToBottom;
@end
