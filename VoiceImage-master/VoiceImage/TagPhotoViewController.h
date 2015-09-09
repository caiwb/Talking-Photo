//
//  TagPhotoViewController.h
//  VoiceImage
//
//  Created by SPG on 7/2/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAudio.h"
#import "iflyMSC/iflyMSC.h"

@class IFlySpeechRecognizer;

@interface TagPhotoViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate,EZAudioPlayerDelegate,EZMicrophoneDelegate,EZRecorderDelegate,IFlySpeechRecognizerDelegate> {
    NSUInteger last;
}
- (IBAction)tagUp:(UIButton *)sender;
- (IBAction)tagDown:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) NSURL* imagePath;
@property (copy, nonatomic) NSString* imageName;
@property (strong, nonatomic) NSData* data;
@property (nonatomic, strong) EZRecorder *recorder;
@property (nonatomic, strong) EZMicrophone *microphone;
@property (weak, nonatomic) IBOutlet EZAudioPlotGL *recordingAudioPlot;
@property (nonatomic, assign) BOOL isRecording;
@property (weak, nonatomic) IBOutlet UIImageView *pressCircle;
@property (weak, nonatomic) IBOutlet UILabel *tagSR;
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象

//识别结果
@property (copy, nonatomic) NSString * desc;
//分词结果
@property (copy, nonatomic) NSString * tag;

//- (IBAction)skipClicked:(UIButton *)sender;
- (void)saveImage;
@end
