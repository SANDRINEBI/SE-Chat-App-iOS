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
                self.currentUser = [[NSMutableDictionary alloc] initWithDictionary:currentUser];
                NSLog(@"loaded current user from defaults");
            }

        }
        // https://gigster-dev.firebaseio.com/messages/
    }
    return self;
}

- (void)saveCurrentUser:(id)currentUser {
    self.currentUser = [[NSMutableDictionary alloc] initWithDictionary:currentUser];
    
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

- (void)POST:(NSString*)urlString JSON:(id)json progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress completion:(APIBlock)completion {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [manager POST:urlString parameters:json progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void)GETstr:(NSString*)urlString parameters:(NSDictionary*)params progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress completion:(APIBlock)completion {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:urlString parameters:params progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void)getUsers:(NSArray*)userIds callback:(APIBlock)cb {
    NSString *urlString = [NSString stringWithFormat:@"%@/api/users/batch", self.baseURL];
    
    [self POST:urlString JSON:userIds progress:nil completion:cb];
}

- (void)saveDeviceToken:(NSString*)token callback:(APIBlock)cb {
    NSString *userId = self.currentUser[@"_id"];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/users/%@/devices/apns?token=%@", self.baseURL, userId, token];

    [self POST:urlString parameters:nil progress:nil completion:cb];
}

- (void)getFirebaseToken:(APIBlock)cb {
    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/users/firebase-token", self.baseURL];

    [self GETstr:urlString parameters:nil progress:nil completion:^(id response, NSError *error) {
        if(error) {
            cb(nil, error);
        } else {
            NSData *data = (NSData*)response;
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *parsed = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            cb(parsed, nil);
        }
    }];
}

- (void)updateMe:(NSDictionary*)updates callback:(APIBlock)cb {
    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/users/me", self.baseURL];

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/JSON" forHTTPHeaderField:@"Content-Type"];
    
    [manager PATCH:urlString parameters:updates success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"respo %@", responseObject);
        
        cb(responseObject, nil);
        
        // Save the current user
        [updates enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.currentUser setObject:obj forKey:key];
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString *errStr = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSData *errData = [errStr dataUsingEncoding:NSUTF8StringEncoding];
        id errJson = [NSJSONSerialization JSONObjectWithData:errData options:0 error:nil];
        cb(errJson, error);
    }];
}

- (void)sendMessage:(NSDictionary*)params toGig:(NSString*)gigId callback:(APIBlock)cb {
//    /api/v1/gigs/:gig_id/messages
    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/gigs/%@/messages", self.baseURL, gigId];
    
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
//    [self.manager POST:urlString parameters:@{@"type":@"text", @"text": text, @"toClient": @"1"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    [self.manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        cb(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString *errStr = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSData *errData = [errStr dataUsingEncoding:NSUTF8StringEncoding];
        id errJson = [NSJSONSerialization JSONObjectWithData:errData options:0 error:nil];
        cb(errJson, error);
    }];


    
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
