//
//  ExpenseManager.m
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import "ExpenseManager.h"
#import "Engine.h"
#import "EngineGlobal.h"
#import "NetworkManager.h"
#import "Expense.h"
#import "CacheManager.h"

@interface ExpenseManager() {
    dispatch_queue_t queue;
}

@end

@implementation ExpenseManager
-(void)startup {
    queue = dispatch_queue_create("jds.Expense.ExpenseManager.request", NULL);
}
-(void)shutdown {
    
}

-(NSArray*)getExpenses {
    NSArray * data = [[Engine cache] getObject:ENGINE_CACHE_RESULTS peek:YES];
    if(data != nil && ![[Engine cache] isValid:ENGINE_CACHE_RESULTS]) { //NEED to refresh because expired
        [self requestExpenses:NO success:nil error:nil];
    }
    return data;
}
-(void)requestExpenses:(BOOL)force success:(void (^)(NSArray*))onSuccess error:(void (^)(NSError*))onError {
    if(!force && [[Engine cache] isValid:ENGINE_CACHE_RESULTS]) {
        //We have a valid cache version return that;
        dispatch_async(dispatch_get_main_queue(), ^() {
            onSuccess([self getExpenses]);
        });
    }
    dispatch_async(queue, ^() {
        NSString * url = @"list";
        [[Engine network] getJSON:url
                          success:^(id data){
                              @try {
                                  NSArray * newExpenses = data;
                                  NSMutableArray * results = [NSMutableArray new];
                                  for(NSDictionary * rawExpense in newExpenses) {
                                      Expense * newExpense = [[Expense alloc] initWithDictionary:rawExpense];
                                      [self addExpense:newExpense];
                                      
                                      [results addObject:newExpense];
                                  }
                                  
                                  [[Engine cache] putObject:results key:ENGINE_CACHE_RESULTS ttl:5*60];
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^() {
                                      onSuccess(results);
                                      
                                      [[NSNotificationCenter defaultCenter] postNotificationName:ENGINE_NOTIFICATION_EXPENSE_LIST object:self];
                                  });
                              }
                              @catch (NSException *exception) {
                                  [[Engine cache] putObject:[NSArray new] key:ENGINE_CACHE_RESULTS ttl:5*60];
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^() {
                                      onError(nil); //tt
                                  });
                              }
                          } error:^(NSError* err){
                              [[Engine cache] putObject:[NSArray new] key:ENGINE_CACHE_RESULTS ttl:5*60];
                              
                              dispatch_async(dispatch_get_main_queue(), ^() {
                                  onError(err);
                              });
                          }];
        
    });
}
-(void)searchExpenses:(NSString*)searchKey success:(void (^)(NSArray*))onSuccess error:(void (^)(NSError*))onError {
    dispatch_async(queue, ^() {
        NSString * url = [NSString stringWithFormat:@"list?search=%@", searchKey];
        [[Engine network] getJSON:url
                          success:^(id data){
                              @try {
                                  NSArray * newExpenses = data;
                                  NSMutableArray * results = [NSMutableArray new];
                                  for(NSDictionary * rawExpense in newExpenses) {
                                      Expense * newExpense = [[Expense alloc] initWithDictionary:rawExpense];
                                      [self addExpense:newExpense];
                                      
                                      [results addObject:newExpense];
                                  }
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^() {
                                      onSuccess(results);
                                  });
                              }
                              @catch (NSException *exception) {
                                  dispatch_async(dispatch_get_main_queue(), ^() {
                                      onError(nil); //tt
                                  });
                              }
                          } error:^(NSError* err){
                              dispatch_async(dispatch_get_main_queue(), ^() {
                                  onError(err);
                              });
                          }];
        
    });
}

-(void)submitExpense:(NSString*)desc
                    :(NSString*)category
                    :(NSString*)subcategory
                    :(double)amount
                    :(NSInteger)unixtime
             success:(void (^)(Expense*))onSuccess
               error:(void (^)(NSError*))onError {
    
    dispatch_async(queue, ^() {
        NSString * url = @"";
        
        NSMutableDictionary * postData = [NSMutableDictionary new];
        [postData setObject:[NSNumber numberWithDouble:amount] forKey:@"amount"];
        [postData setObject:category forKey:@"category"];
        if(subcategory != nil)
            [postData setObject:subcategory forKey:@"subcategory"];
        [postData setObject:desc forKey:@"desc"];
        [postData setObject:[NSNumber numberWithInteger:unixtime] forKey:@"date"];
        
        [[Engine network] postJSON:url
                              data:postData
                           success:^(id data) {
                               Expense * newExpense = [[Expense alloc] initWithDictionary:data];
                               
                               [newExpense setNew];
                               
                               dispatch_async(queue, ^() { //TT
                                   NSMutableArray * newList = [NSMutableArray arrayWithArray:[self getExpenses]];
                                   [newList addObject:newExpense];
                                   [[Engine cache] putObject:newList key:ENGINE_CACHE_RESULTS ttl:5*60];
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^() {
                                       [[NSNotificationCenter defaultCenter] postNotificationName:ENGINE_NOTIFICATION_EXPENSE_LIST object:self];
                                   });
                               });
                               
                               dispatch_async(dispatch_get_main_queue(), ^() {
                                   if(onSuccess != nil)
                                       onSuccess(newExpense);
                               });
                           }
                             error:^(NSError* error){
                                 dispatch_async(dispatch_get_main_queue(), ^() {
                                     if(onError != nil)
                                         onError(error);
                                 });
                             }];
    });
}

-(void)searchCategory:(NSString*)searchKey
              success:(void (^)(NSArray*))onSuccess
                error:(void (^)(NSError*))onError {
    dispatch_async(queue, ^() {
        NSString * url = [NSString stringWithFormat:@"category/list?search=%@", searchKey];
        [[Engine network] getJSON:url
                          success:^(id data){
                              @try {
                                  NSArray * rawCats = data;
                                  NSMutableArray * results = [NSMutableArray new];
                                  for(NSString * category in rawCats) {
                                      [results addObject:category];
                                  }
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^() {
                                      onSuccess(results);
                                  });
                              }
                              @catch (NSException *exception) {
                                  dispatch_async(dispatch_get_main_queue(), ^() {
                                      onError(nil); //tt
                                  });
                              }
                          } error:^(NSError* err){
                              dispatch_async(dispatch_get_main_queue(), ^() {
                                  onError(err);
                              });
                          }];
        
    });
}


-(void)markAllOld {
    for(Expense *exp in [self getExpenses]) {
        [exp setOld];
    }
}

//internal
-(void)addExpense:(Expense*)expense {
    ;//tt
}

@end
