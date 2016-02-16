//
//  ApiManager.h
//  BeyondVerbal API Sample
//
//  Created by BeyondVerbal on 1/27/16.
//  Copyright © 2016 BeyondVerbal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiManager : NSObject

+ (instancetype)sharedManager;

-(void)getAccessTokenSuccess:(void (^)(NSData *data))success;
-(void)startSessionSuccess:(void (^)(NSData *data))success;
-(void)sendAudioFile:(NSString *)fileName fileType:(NSString *)fileType success:(void (^)(NSData *data))success;
-(void)getAnalysisFromMs:(NSNumber *)fromMs success:(void (^)(NSData *))success;

@end