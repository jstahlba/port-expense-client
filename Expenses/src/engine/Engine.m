//
//  Engine.m
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import "NetworkManager.h"
#import "CacheManager.h"
#import "SettingManager.h"
#import "ExpenseManager.h"

#import "Engine.h"
@interface Engine() {
    NetworkManager* network;
    CacheManager* cache;
    SettingManager * setting;
    
    ExpenseManager* expense;
}
@end

@implementation Engine
static Engine *gInstance = NULL;

+ (Engine *)instance {
    @synchronized(self) {
        if (gInstance == NULL)
            gInstance = [[self alloc] init];
    }
    return gInstance ;
}

+(void)startup {
    [[Engine instance] startup];
}
+(void)shutdown {
    [[Engine instance] shutdown];
}

+(NetworkManager*)network {
    return [[Engine instance] network];
}
+(CacheManager*)cache {
    return [[Engine instance] cache];
}
+(SettingManager*)setting {
    return [[Engine instance] setting];
}

+(ExpenseManager*)expense {
    return [[Engine instance] expense];
}

-(void)startup {
    cache = [CacheManager new];
    [cache startup];
    
    network = [NetworkManager new];
    [network startup];
    
    setting = [SettingManager new];
    [setting startup];
    
    expense = [ExpenseManager new];
    [expense startup];
}
-(void)shutdown {
    [expense shutdown];
    expense = nil;
    
    [setting shutdown];
    setting = nil;
    
    
    [network shutdown];
    network = nil;
    
    [cache shutdown];
    cache = nil;
}

-(NetworkManager*)network {
    return network;
}
-(CacheManager*)cache {
    return cache;
}
-(SettingManager*)setting {
    return setting;
}

-(ExpenseManager*)expense {
    return expense;
}

+(NSString*)getServerURL {
    return @"http://localhost:8080/Expense/";
}


@end
