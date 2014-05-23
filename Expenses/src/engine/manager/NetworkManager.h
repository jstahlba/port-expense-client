//
//  NetworkManager.h
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject
-(void)startup;
-(void)shutdown;

-(void)getJSON:(NSString*)url success:(void (^)(id))onSuccess error:(void (^)(NSError*))onError;
-(void)postJSON:(NSString*)url data:(NSDictionary*)data success:(void (^)(id))onSuccess error:(void (^)(NSError*))onError;
@end
