//
//  CacheManager.m
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import "CacheManager.h"
#import "CacheObject.h"

@interface CacheManager() {
    NSMutableDictionary* cache;
}
@end

@implementation CacheManager

-(void)startup {
    cache = [NSMutableDictionary new];
}
-(void)shutdown {
    cache = nil;
}



-(void)putObject:(id)data key:(NSString *)key ttl:(NSInteger)ttl {
    CacheObject * newObject = [[CacheObject alloc] initWithData:data :ttl];
    [cache setObject:newObject forKey:key];
}

-(id)getObject:(NSString*)key peek:(BOOL)peek {
    CacheObject * cacheObject = [cache objectForKey:key];
    
    if(peek) {
        return [cacheObject peekData];
    } else {
        return [cacheObject getData];
    }
}
//Exsists and not expired
-(BOOL)isValid:(NSString*)key {
    CacheObject * cacheObject = [cache objectForKey:key];
    if(cacheObject != nil && ![cacheObject isExpired])
        return YES;
    return NO;
}

@end
