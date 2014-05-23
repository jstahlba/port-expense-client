//
//  CacheObject.m
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import "CacheObject.h"

@interface CacheObject() {
    id data;
    NSInteger ttl;
    NSDate * cacheDate;
}

@end

@implementation CacheObject


-(id)initWithData:(id)d :(NSInteger)t {
    self = [super init];
    if(self != nil) {
        data = d;
        ttl = t;
        cacheDate = [NSDate new];
    }
    return self;
}

-(id)peekData {
    return data;
}
-(id)getData {
    if([self isExpired])
        return nil;
    return data;
}
-(BOOL)isExpired {
    NSTimeInterval secondsBetween = [[NSDate new] timeIntervalSinceDate:cacheDate];
    
    if(secondsBetween > ttl) {
        return YES ;
    }
    return NO;
}

@end
