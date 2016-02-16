//
//  ViewController.m
//  BeyondVerbal API Sample
//
//  Created by BeyondVerbal on 1/27/16.
//  Copyright © 2016 BeyondVerbal. All rights reserved.
//

#import "ViewController.h"
#import "ApiManager.h"

@interface ViewController ()
{
    BOOL fileBeingSent;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. Call getAccessToken
    [[ApiManager sharedManager] getAccessTokenSuccess:^(NSData *data) {
        
        // When successful:
        // 2. Call startSession
        [[ApiManager sharedManager] startSessionSuccess:^(NSData *data) {
            
            // When successful:
            // BOOL fileBeingSent is used to stop sending Analysis requests after send file is finished
            fileBeingSent = YES;
            
            // 3. Call sendAudioFile with sample.wav
            [[ApiManager sharedManager] sendAudioFile:@"sample" fileType:@"wav" success:^(NSData *data) {
                fileBeingSent = NO;
            }];
            
            // 4. Call sendForAnalysis for the 1st time after 3 seconds
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(sendForAnalysis) withObject:nil afterDelay:3];
            });
        }];
    }];
}

-(void)sendForAnalysis
{
    if(fileBeingSent == YES)
    {
        NSLog(@"getAnalysis started");
        [[ApiManager sharedManager] getAnalysisFromMs:[NSNumber numberWithLong:0] success:^(NSData *data) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"getAnalysis responseDictionary:\n%@",responseDictionary);
            
            // Call sendForAnalysis after 1 second until send file is finished
            if(fileBeingSent == YES)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(sendForAnalysis) withObject:nil afterDelay:1];
                });
        }];
    }
}

@end
