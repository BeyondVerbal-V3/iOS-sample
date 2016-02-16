//
//  ApiManager.m
//  BeyondVerbal API Sample
//
//  Created by BeyondVerbal on 1/27/16.
//  Copyright © 2016 BeyondVerbal. All rights reserved.
//

#import "ApiManager.h"

NSString *const kMy_API_Key = @"PUT API KEY HERE";
NSString *const kAuth_URL = @"https://token.beyondverbal.com/token";
NSString *const kRecording_URL = @"https://apiv3.beyondverbal.com/v3/recording/";

@interface ApiManager ()
{
    NSString *accessToken;
    NSString *recordingId;
}

@end

@implementation ApiManager

#pragma mark - Singleton Pattern

+ (instancetype)sharedManager {
    static ApiManager *sharedAPIManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAPIManager = [[self alloc] init];
    });
    return sharedAPIManager;
}

#pragma mark - Methods

-(void)getAccessTokenSuccess:(void (^)(NSData *data))success
{
    NSLog(@"getAccessToken started");
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kAuth_URL]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"grant_type=client_credentials&apiKey=%@",kMy_API_Key];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         NSLog(@"getAccessToken responseDictionary:\n%@",responseDictionary);
         accessToken = [responseDictionary objectForKey:@"access_token"];
        
         success(data);
    }];
    
    [dataTask resume];
}


-(void)startSessionSuccess:(void (^)(NSData *data))success
{
    NSLog(@"startSession started");
    NSString *stringURL = [NSString stringWithFormat:@"%@start",kRecording_URL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:stringURL]];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"POST"];
    NSDictionary *bodyDict = @{@"dataFormat":@{@"type":@"WAV"}};
    NSData *bodyJson = [NSJSONSerialization dataWithJSONObject:bodyDict options:kNilOptions error:nil];
    [request setHTTPBody:bodyJson];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         NSLog(@"startSession responseDictionary:\n%@",responseDictionary);
         recordingId = [responseDictionary objectForKey:@"recordingId"];
                                                                         
         success(data);
     }];
    [dataTask resume];
}


-(void)sendAudioFile:(NSString *)fileName fileType:(NSString *)fileType success:(void (^)(NSData *data))success
{
    NSLog(@"sendAudioFile started");
    NSString *stringURL = [NSString stringWithFormat:@"%@%@",kRecording_URL,recordingId];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:stringURL]];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"POST"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [request setHTTPBody:data];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         NSLog(@"sendAudioFile ended, responseDictionary:\n%@",responseDictionary);
                                                                         
         success(data);
     }];
    [dataTask resume];
}


-(void)getAnalysisFromMs:(NSNumber *)fromMs success:(void (^)(NSData *data))success
{
    NSString *stringURL = [NSString stringWithFormat:@"%@%@/analysis?fromMs=%lu",kRecording_URL,recordingId,[fromMs longValue]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:stringURL]];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         success(data);
     }];
    [dataTask resume];
}

@end
