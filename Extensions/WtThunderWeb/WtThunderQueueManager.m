//
//  WtThunderQueueManager.m
//  Pods
//
//  Created by wtfan on 2017/8/29.
//
//

#import "WtThunderQueueManager.h"

@implementation WtThunderQueueManager
+ (NSOperationQueue *)connectionQueue {
    static NSOperationQueue *_connectionQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _connectionQueue = [[NSOperationQueue alloc] init];
        _connectionQueue.name = @"com.wtfan.WtThunderQueue.Connection";
        _connectionQueue.maxConcurrentOperationCount = 10;
        _connectionQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    });
    
    return _connectionQueue;
}

+ (void)dispatchInConnectionQueue:(dispatch_block_t)block {
    if (!block) return;
    
    if ([[NSThread currentThread].name isEqualToString:[self connectionQueue].name]) {
        block();
    }else {
        NSBlockOperation *blkOP = [NSBlockOperation blockOperationWithBlock:block];
        [[self connectionQueue] addOperation:blkOP];
    }
}
@end
