//
//  API.m
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/23/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#import "API.h"

#import <AFNetworking/AFNetworking.h>

#define BASE_URL @"https://app.gigster.com/"

@implementation API

+ (API*)shared {
    static API *__sharedAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedAPI = [[API alloc] init];
    });
    return __sharedAPI;
}

- (id)init {
    if (self = [super init]) {
        self.manager = [AFHTTPSessionManager manager];
        self.baseURL = @"https://app.gigster.com";
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"currentUser"]) {
            NSString *currentUserStr = [defaults objectForKey:@"currentUser"];
            NSData *currentUserData = [currentUserStr dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *readError;
            id currentUser = [NSJSONSerialization JSONObjectWithData:currentUserData options:0 error:&readError];
            if(!readError) {
                self.currentUser = currentUser;
                NSLog(@"loaded current user from defaults");
            }

        }
        
    }
    return self;
}

- (void)saveCurrentUser:(id)currentUser {
    self.currentUser = currentUser;
    
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:currentUser options:NSJSONWritingPrettyPrinted error:&writeError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if(!writeError) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:jsonString forKey:@"currentUser"];
        [defaults synchronize];
        
        NSLog(@"saved current user");
    } else {
        NSLog(@"error saving current user");
    }
}

- (void)clearCurrentUser {
    self.currentUser = nil;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"currentUser"];
    [defaults synchronize];
}

- (void)POST:(NSString*)urlString parameters:(NSDictionary*)params progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress completion:(APIBlock)completion {
    [self.manager POST:urlString parameters:params progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString *errStr = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSData *errData = [errStr dataUsingEncoding:NSUTF8StringEncoding];
        id errJson = [NSJSONSerialization JSONObjectWithData:errData options:0 error:nil];
        completion(errJson, error);
    }];
}

- (void)GET:(NSString*)urlString parameters:(NSDictionary*)params progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress completion:(APIBlock)completion {
    [self.manager GET:urlString parameters:params progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString *errStr = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSData *errData = [errStr dataUsingEncoding:NSUTF8StringEncoding];
        id errJson = [NSJSONSerialization JSONObjectWithData:errData options:0 error:nil];
        completion(errJson, error);
    }];
}

- (void)login:(NSString*)email withPassword:(NSString*)password callback:(APIBlock)cb {
    NSString *urlString = [NSString stringWithFormat:@"%@/api/session", self.baseURL];
    
    NSDictionary *params = @{@"email": email, @"password": password};
    
    [self POST:urlString parameters:params progress:nil completion:^(id response, NSError *error) {
        if(!error) {
            [self saveCurrentUser:response];
            cb(response, error);
        } else {
            cb(response, error);
        }
    }];
    
//    [self.manager POST:urlString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        self.currentUser = responseObject;
//        
//        cb(responseObject, nil);
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        cb(nil, error);
//        NSLog(@"Error: %@", error);
//    }];
}

- (void)getMe:(APIBlock)cb {
    NSString *urlString = [NSString stringWithFormat:@"%@/api/users/me", self.baseURL];
    
    [self GET:urlString parameters:nil progress:nil completion:cb];
}

- (void)getGigs:(APIBlock)cb {
    NSString *urlString = [NSString stringWithFormat:@"%@/api/gigs/se", self.baseURL];
    
    [self GET:urlString parameters:nil progress:nil completion:cb];
}

- (void)saveDeviceToken:(NSString*)token callback:(APIBlock)cb {
    NSString *userId = self.currentUser[@"_id"];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/users/%@/devices/apns?token=%@", self.baseURL, userId, token];

    [self POST:urlString parameters:nil progress:nil completion:cb];
}

- (void)sendMessage:(NSString*)text toGig:(NSString*)gigId callback:(APIBlock)cb {
//    NSString *userId = self.currentUser[@"_id"];
//    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/users/%@/devices/apns?token=%@", self.baseURL, userId, token];
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager POST:urlString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        cb(responseObject, nil);
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        cb(nil, error);
//        NSLog(@"Error: %@", error);
//    }];
}

- (void)logout {
    [self clearCurrentUser];
    

}

@end
