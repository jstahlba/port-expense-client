//
//  ExpenseTableViewCell.m
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-21.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import "ExpenseTableViewCell.h"

@interface ExpenseTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *subCategory;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIView *seperator;

@end

@implementation ExpenseTableViewCell

-(void)setExpense:(Expense*)expense  {
    if([expense isNew]) {
        self.contentView.backgroundColor = [UIColor colorWithRed:155/255.0 green:205/255.0 blue:235/255.0 alpha:1.0];
    } else {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    self.desc.text = [expense getDesc];
    self.category.text = [expense getCategory];
    self.subCategory.hidden = [expense getSubCategory] == nil;
    self.subCategory.text = [expense getSubCategory];
    self.amount.text = [expense getFormattedAmount];
    self.date.text = [expense getFormattedDate];
}

-(void)setIndexPath:(NSIndexPath*)path :(NSUInteger)numberOfCells {
    self.seperator.hidden = path.row == numberOfCells - 1;
}

@end
