//
//  ExpenseManager.h
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Expense.h"

@interface ExpenseManager : NSObject
-(void)startup;
-(void)shutdown;

-(NSArray*)getExpenses;
-(void)requestExpenses:(BOOL)force success:(void (^)(NSArray*))onSuccess error:(void (^)(NSError*))onError;
-(void)searchExpenses:(NSString*)searchKey success:(void (^)(NSArray*))onSuccess error:(void (^)(NSError*))onError;
    
-(void)searchCategory:(NSString*)searchKey
              success:(void (^)(NSArray*))onSuccess
                error:(void (^)(NSError*))onError;

-(void)submitExpense:(NSString*)desc
                    :(NSString*)category
                    :(NSString*)subcategory
                    :(double)amount
                    :(NSInteger)unixtime
             success:(void (^)(Expense*))onSuccess
               error:(void (^)(NSError*))onError;

-(void)markAllOld;

@end
