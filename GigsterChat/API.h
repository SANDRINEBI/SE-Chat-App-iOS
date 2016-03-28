//
//  API.h
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/23/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void (^APIBlock)(id response, NSError *error);

@interface API : NSObject

@property (nonatomic, retain) AFHTTPSessionManager *manager;
@property (nonatomic, retain) NSString *baseURL;
@property (nonatomic, retain) id currentUser;

+ (API*)shared;
- (void)saveCurrentUser:(id)currentUser;
- (void)login:(NSString*)email withPassword:(NSString*)password callback:(APIBlock)cb;
- (void)logout;
- (void)getMe:(APIBlock)cb;
- (void)getGigs:(APIBlock)cb;
- (void)saveDeviceToken:(NSString*)token callback:(APIBlock)cb;
- (void)sendMessage:(NSString*)text toGig:(NSString*)gigId callback:(APIBlock)cb;

@end
