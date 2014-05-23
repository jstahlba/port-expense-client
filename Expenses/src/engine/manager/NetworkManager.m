//
//  NetworkManager.m
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import "NetworkManager.h"

#import "AFNetworking.h"
#import "Engine.h"

@interface NetworkManager() {
    AFHTTPSessionManager *manager;
}

@end

@implementation NetworkManager
-(void)startup {
    manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
}
-(void)shutdown {
    
}


-(void)getJSON:(NSString*)url success:(void (^)(id))onSuccess error:(void (^)(NSError*))onError {
    NSString * fullUrl = [[Engine getServerURL] stringByAppendingString:url];
    
    [manager GET:fullUrl
      parameters:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             onSuccess(responseObject);
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             // Handle failure
             onError(error);
         }];
}


-(void)postJSON:(NSString*)url data:(NSDictionary*)data success:(void (^)(id))onSuccess error:(void (^)(NSError*))onError {
        NSString * fullUrl = [[Engine getServerURL] stringByAppendingString:url];
    
    [manager POST:fullUrl
       parameters:data
          success:^(NSURLSessionDataTask *task, id responseObject) {
              onSuccess(responseObject);
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              // Handle failure
              onError(error);
          }];
}

@end
