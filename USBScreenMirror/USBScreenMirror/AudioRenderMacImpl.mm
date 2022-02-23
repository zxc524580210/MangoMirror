//
//  AudioRenderMacImpl.m
//  USBScreenMirror
//
//  Created by zhanxiaochao on 2022/2/13.
//

#import "AudioRenderMacImpl.h"
#import <AudioToolbox/AudioToolbox.h>
#include <iostream>
#include <list>
#include <mutex>

// Constants
const Float64 kSampleRate = 48000.0;
unsigned int kBufferByteSize = 4096;
std::mutex mtx;
struct AudioData
{
    void * buffer;
    size_t size;
    AudioData(const CMSampleBufferRef sampleBuffer)
    {
        size_t size = CMSampleBufferGetTotalSampleSize(sampleBuffer);
        CMBlockBufferRef blockBuf = CMSampleBufferGetDataBuffer(sampleBuffer);
        buffer = malloc(size);
        CMBlockBufferCopyDataBytes(blockBuf, 0, size,buffer);
        this->size = size;
    }
    ~AudioData()
    {
        if(buffer)
        {
            free(buffer);
        }
    }
};

@interface AudioRenderMacImpl ()
{
    AudioQueueRef outputQueue;
    NSLock *noteLock;
    std::list<std::shared_ptr<AudioData>> audioBuffer;
}
@end
@implementation AudioRenderMacImpl

- (instancetype)init
{
    if (self = [super init]) {
        noteLock = [[NSLock alloc] init];
        [self initAudioEngine:kBufferByteSize];
    }
    return self;
}
void OutputBufferCallback (void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{
    [(__bridge AudioRenderMacImpl *)inUserData processOutputBuffer:inBuffer queue:inAQ];
}
- (void)initAudioEngine:(unsigned int)bufferSize
{
    OSStatus err;
    int i;
    
    // Set up stream format fields
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = kSampleRate;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    streamFormat.mBitsPerChannel = 16;
    streamFormat.mChannelsPerFrame = 2;
    streamFormat.mBytesPerPacket = 4 ;
    streamFormat.mBytesPerFrame = 4;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mReserved = 0;


    // New output queue ---- PLAYBACK ----
    err = AudioQueueNewOutput (&streamFormat, OutputBufferCallback, (__bridge void * _Nullable)(self), nil, nil, 0, &outputQueue);
    if (err != noErr) NSLog(@"AudioQueueNewOutput() error: %d", err);
    
    // Enqueue buffers
    AudioQueueBufferRef buffer;
    for (i=0; i<3; i++) {
        err = AudioQueueAllocateBuffer (outputQueue, bufferSize, &buffer);
        if (err == noErr) {
            [self fillAudioBuffer:buffer];
            err = AudioQueueEnqueueBuffer (outputQueue, buffer, 0, nil);
            if (err != noErr) NSLog(@"AudioQueueEnqueueBuffer() error: %d", err);
        } else {
            NSLog(@"AudioQueueAllocateBuffer() error: %d", err);
            return;
        }
    }
        

}
- (void)start{
    OSStatus err;
    // Start queue
    err = AudioQueueStart(outputQueue, nil);
    if (err != noErr) NSLog(@"AudioQueueStart() error: %d", err);
}
- (void)stop{
    OSStatus err;

    err = AudioQueueStop(outputQueue, YES);
    if (err != noErr) NSLog(@"AudioQueueDispose() error: %d", err);
    outputQueue = nil;
}
- (void)destroy{
    OSStatus err;
    err = AudioQueueDispose(outputQueue, true);
}
- (void) processOutputBuffer: (AudioQueueBufferRef) buffer queue: (AudioQueueRef) queue
{
    //Fill Buffer
    [self fillAudioBuffer:buffer];
    // Re-enqueue buffer.
    OSStatus err = AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
    if (err != noErr)
        NSLog(@"AudioQueueEnqueueBuffer() error %d", err);
    
}
//Input Audio Buffer
- (void)enqueSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    std::lock_guard<std::mutex> _(mtx);
    size_t size = CMSampleBufferGetTotalSampleSize(sampleBuffer);
    if (size != kBufferByteSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reset:(unsigned int)size];
        });
    }
    audioBuffer.push_back(std::make_shared<AudioData>(sampleBuffer));

}
//Fill Audio Buffer
- (void) fillAudioBuffer: (AudioQueueBufferRef) buffer
{
    std::lock_guard<std::mutex> _(mtx);
    if (audioBuffer.size() > 0) {
        std::shared_ptr<AudioData> cacheBuffer = audioBuffer.front();
        memcpy(buffer->mAudioData, cacheBuffer->buffer, buffer->mAudioDataByteSize);
        audioBuffer.pop_front();
    } else {
        // Fill AudioData zero
        memset(buffer->mAudioData, 0, buffer->mAudioDataBytesCapacity);
    }
    buffer->mAudioDataByteSize = buffer->mAudioDataBytesCapacity;
}
- (void)reset:(unsigned int)bufferSize
{
    [self stop];
    [self destroy];
    [self initAudioEngine:bufferSize];
    [self start];
}


@end
