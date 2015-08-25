//
//  AudioRecorder.h
//  VoiceImage
//
//  Created by SPG on 7/6/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define RIFF_ID 0x52494646 // "RIFF"
#define RIFF_FMT_ID 0x666d7420 // "fmt "
#define RIFF_DATA_ID 0x64617461 // "data"

typedef struct riffChunkHeader {
    UInt32 rsc_id; // big endian
    UInt32 rsc_size; // little endian
} riffChunkHeader_t;

@interface AudioRecorder : NSObject<AVAudioRecorderDelegate> {
    AVAudioRecorder *recorder;
}

+ (AudioRecorder *)sharedInstance;
-(void)startRecord;
-(NSURL*)stopRecord;
@end
