//
//  Engine.h
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NetworkManager;
@class CacheManager;
@class SettingManager;
@class ExpenseManager;

@interface Engine : NSObject

+(NetworkManager*)network;
+(CacheManager*)cache;
+(SettingManager*)setting;

+(ExpenseManager*)expense;


+(void)startup;
+(void)shutdown;

+(NSString*)getServerURL;

@end
