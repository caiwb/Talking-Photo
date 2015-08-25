//
//  AudioRecorder.m
//  VoiceImage
//
//  Created by SPG on 7/6/15.
//  Copyright (c) 2015 SPG. All rights reserved.
//

#import "AudioRecorder.h"

@implementation AudioRecorder

+ (AudioRecorder *)sharedInstance
{
    static AudioRecorder *_sharedInstance = nil;
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      _sharedInstance = [[self alloc] init];
                  });
    
    return _sharedInstance;
}

-(void)prepareAudio{
    if (recorder != nil) {
        return;
    }
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.wav",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSDictionary *settings2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                               [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,// kAudioFormatLinearPCM
                               [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                               [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                               [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,nil];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:settings2 error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

-(void)startRecord{
    [self prepareAudio];
    [recorder record];
}

-(NSURL*)stopRecord{
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    NSURL* file = [recorder url];
    
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo2.wav",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    [[self mergeWavFiles:[NSData dataWithContentsOfURL:file]]
        writeToURL:outputFileURL
        atomically:YES];
    return outputFileURL;
}

-(NSData*)extractRiffChunk:(NSData*)riffData extractId:(UInt32) extractId extractOnlyData:(BOOL) extractOnlyData {
    NSUInteger offset = 0;
    
    while (([riffData length] - offset) >= sizeof(riffChunkHeader_t)) {
        NSData *riffChunkRange = [riffData subdataWithRange:
                                  NSMakeRange(offset, sizeof(riffChunkHeader_t))];
        const riffChunkHeader_t *riffChunk = [riffChunkRange bytes];
        UInt32 riffId = NSSwapBigIntToHost(riffChunk->rsc_id);
        NSUInteger riffSize = NSSwapLittleIntToHost(riffChunk->rsc_size);
        // treat RIFF chunk as a subchunk containing format
        if (riffId == RIFF_ID) {
            riffSize = 4;
        }
        
        if (riffId != extractId) {
            offset += sizeof(riffChunkHeader_t) + riffSize;
            continue;
        }
        
        NSUInteger len;
        if (extractOnlyData) {
            offset += sizeof(riffChunkHeader_t);
            len = riffSize;
        } else {
            len = sizeof(riffChunkHeader_t) + riffSize;
        }
        
        if (([riffData length] - offset) < riffSize) {
            break;
        }
        
        return [riffData subdataWithRange:NSMakeRange(offset, len)];
    }
    
    return nil;
}

-(NSData *)extractRiffChunkAll:(NSData *)riffData extractId:(UInt32) extractId{
    return [self extractRiffChunk:riffData extractId:extractId extractOnlyData:NO];
}

-(NSData *)extractRiffChunkData:(NSData *)riffData extractId:(UInt32) extractId {
    return [self extractRiffChunk:riffData extractId:extractId extractOnlyData:YES];
}

-(NSData *)mergeWavFiles:(NSData *)wavData1 {
    NSMutableData *riffAll = [[self extractRiffChunkAll:wavData1 extractId:RIFF_ID]
                               mutableCopy];
    NSData *fmtAll = [self extractRiffChunkAll:wavData1 extractId:RIFF_FMT_ID];
    
    NSData *file1Data = [self extractRiffChunkData:wavData1 extractId:RIFF_DATA_ID];
    
    
    riffChunkHeader_t riffDataSubChunk;
    riffDataSubChunk.rsc_id = NSSwapHostIntToBig(RIFF_DATA_ID);
    riffDataSubChunk.rsc_size = NSSwapHostIntToLittle((UInt32)[file1Data length]);
    NSData *dataHeader = [NSData dataWithBytes:&riffDataSubChunk
                                        length:sizeof(riffDataSubChunk)];
    
    riffChunkHeader_t *riffChunk = [riffAll mutableBytes];
    riffChunk->rsc_size = NSSwapHostIntToLittle(sizeof(riffChunkHeader_t) +
                                                (UInt32)[fmtAll length] +
                                                (UInt32)[dataHeader length] +
                                                (UInt32)[file1Data length]);
    
    NSMutableData *mergedWav = [NSMutableData data];
    [mergedWav appendData:riffAll];
    [mergedWav appendData:fmtAll];
    [mergedWav appendData:dataHeader];
    [mergedWav appendData:file1Data];
    
    return mergedWav;
}

@end
