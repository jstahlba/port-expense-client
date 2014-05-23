//
//  MainViewController.m
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-21.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import "MainViewController.h"

#import "SearchTableViewCell.h"
#import "ExpenseTableViewCell.h"

#import "Engine.h"
#import "EngineGlobal.h"
#import "ExpenseManager.h"

#import "SettingManager.h"

#import "Util.h"

@interface MainViewController () {
    NSArray * expenses;
    
    CGFloat baseHeaderHeight;
    BOOL headerOpen;
    
    UITapGestureRecognizer * closeReconizer;
    
    NSMutableArray * categorySuggestions;
    NSMutableArray * subCategorySuggestions;
    
    NSInteger sortOption;
    
    NSString * searchString;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *headerButton;
@property (weak, nonatomic) IBOutlet UIView *dialogContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (strong, nonatomic) IBOutlet UIView *addDialog;
@property (strong, nonatomic) IBOutlet UIView *sortDialog;
@property (strong, nonatomic) IBOutlet UIView *searchDialog;


//add form
@property (weak, nonatomic) IBOutlet UITextField *amount;
@property (weak, nonatomic) IBOutlet UITextField *desc;
@property (weak, nonatomic) IBOutlet UITextField *category;
@property (weak, nonatomic) IBOutlet UITextField *subcategory;
@property (weak, nonatomic) IBOutlet UITextField *date;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UITableView *categoryTable;
@property (weak, nonatomic) IBOutlet UITableView *subCategoryTable;

@property (weak, nonatomic) IBOutlet UITextField *searchField;


@property (strong, nonatomic) IBOutlet UITableViewCell *emptyCell;

@end

#define kCellIdentifier @"ExpenseCell"

#define kSearchCellIdentifier @"SearchCell"

@implementation MainViewController

-(void)loadView {
    categorySuggestions = [NSMutableArray new];
    subCategorySuggestions = [NSMutableArray new];
    
    sortOption = 0;
    
    [[NSBundle mainBundle] loadNibNamed:@"MainView" owner:self options:nil];
    
    baseHeaderHeight = self.header.frame.size.height;
    
    [self.table registerNib:[UINib nibWithNibName:@"ExpenseCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCellIdentifier];
    
    [self.categoryTable registerNib:[UINib nibWithNibName:@"SearchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kSearchCellIdentifier];
    [self.subCategoryTable registerNib:[UINib nibWithNibName:@"SearchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kSearchCellIdentifier];
    
    [self loadExpenseList:NO];
    
    
    closeReconizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListUpdate:)
                                                 name:ENGINE_NOTIFICATION_EXPENSE_LIST
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (IBAction)onSort:(id)sender {
    for(UIButton * headerButton in self.headerButton) {
        headerButton.enabled = headerButton != sender;
    }
    [self openHeader:self.sortDialog];
}
- (IBAction)onSearch:(id)sender {
    for(UIButton * headerButton in self.headerButton) {
        headerButton.enabled = headerButton != sender;
    }
    [self openHeader:self.searchDialog];
}
- (IBAction)onAdd:(id)sender {
    for(UIButton * headerButton in self.headerButton) {
        headerButton.enabled = headerButton != sender;
    }
    [self openHeader:self.addDialog];
}

-(void)startLoadingAnimation {
    [self.loadingSpinner startAnimating];
    [self.loadingSpinner setHidden:NO];
}
-(void)stopLoadingAnimation {
    [self.loadingSpinner setHidden:YES];
    [self.loadingSpinner stopAnimating];
}

-(void)loadExpenseList:(BOOL)force {
    [self stopLoadingAnimation];
    
    NSArray * data = [[Engine expense] getExpenses];
    if(data == nil) {
        [self startLoadingAnimation];
        [[Engine expense] requestExpenses:force success:^(NSArray* data){
            [self stopLoadingAnimation];
        }error:^(NSError*err){
            [self stopLoadingAnimation];
            [Util alertForKey:@"alert.unknown.error"];
        }];
    } else {
        expenses = data;
        [self sortExpenses];
        [self.table reloadData];
    }
}

-(void)onListUpdate:(NSNotification*)notice {
    [self loadExpenseList:NO];
}

-(void)onBackground:(NSNotification*)notice {
    [[Engine expense] markAllOld];
    [self.table reloadData];
}

-(void)cancelAction {
    [self closeHeader:nil];
    
    for(UIButton * headerButton in self.headerButton) {
        headerButton.enabled = YES;
    }
}
-(void)closeHeader:(void (^)(void))complete{
    self.header.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35
                     animations:^(){
                         [Util setHeight:baseHeaderHeight view:self.header];
                         [Util setHeight:0 view:self.dialogContainer];
                         
                         CGRect tableFrame = CGRectMake(0,baseHeaderHeight,
                                                        self.view.frame.size.width,
                                                        self.view.frame.size.height - baseHeaderHeight);
                         self.table.frame = tableFrame;
                     }completion:^(BOOL finish){
                         [self.table removeGestureRecognizer:closeReconizer];
                         
                         self.header.userInteractionEnabled = YES;
                         headerOpen = NO;
                         
                         for(UIView * view in self.dialogContainer.subviews) {
                             [view removeFromSuperview];
                         }
                         
                         if(complete != nil)
                             complete();
                     }];
    
}

-(void)openHeader:(UIView*)dialog{
    [self closeHeader:^() {
        self.header.userInteractionEnabled = NO;
        
        [Util setHeight:0 view:self.dialogContainer];
        [self.dialogContainer addSubview:dialog];
        
        [UIView animateWithDuration:0.35
                         animations:^(){
                             [Util setHeight:baseHeaderHeight + dialog.frame.size.height view:self.header];
                             [Util setHeight:dialog.frame.size.height view:self.dialogContainer];
                             
                             CGRect tableFrame = CGRectMake(0,baseHeaderHeight + dialog.frame.size.height,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height - baseHeaderHeight - dialog.frame.size.height);
                             self.table.frame = tableFrame;
                             
                         }completion:^(BOOL finish){
                             [self.table addGestureRecognizer:closeReconizer];
                             
                             self.header.userInteractionEnabled = YES;
                             headerOpen = YES;
                         }];
    }];
}

#pragma mark
#pragma mark UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.table) {
        if([expenses count] <= 0)
            return 1;
        return [expenses count];
    }
    if(tableView == self.categoryTable)
        return [categorySuggestions count];
    if(tableView == self.subCategoryTable)
        return [subCategorySuggestions count];
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.table)
        return  60;
    if(tableView == self.categoryTable || tableView == self.subCategoryTable)
        return 30;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(tableView == self.table)
        return 2; //padding at the top
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(tableView == self.table)
        return [UIView new];
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.table) {
        if([expenses count] <= 0)
            return self.emptyCell;
        
        ExpenseTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        if(cell == nil) {
            NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"ExpenseCell" owner:self options:nil];
            cell = [views objectAtIndex:0];
        }
        
        Expense * expense = [expenses objectAtIndex:indexPath.row];
        [cell setExpense:expense];
        [cell setIndexPath:indexPath :[expenses count]];
        return cell;
    }
    if(tableView == self.categoryTable || tableView == self.subCategoryTable) {
        NSArray * dataSet = categorySuggestions;
        if(tableView == self.subCategoryTable)
            dataSet = subCategorySuggestions;
        
        SearchTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kSearchCellIdentifier];
        if(cell == nil) {
            NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:self options:nil];
            cell = [views objectAtIndex:0];
        }
        
        NSString * category  = [dataSet objectAtIndex:indexPath.row];
        [cell setCategoryName:category];
        [cell setIndexPath:indexPath :[dataSet count]];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.categoryTable || tableView == self.subCategoryTable) {
        NSArray * dataSet = categorySuggestions;
        if(tableView == self.subCategoryTable)
            dataSet = subCategorySuggestions;
        
        UITextField * dataField = self.category;
        if(tableView == self.subCategoryTable)
            dataField = self.subcategory;
        
        dataField.text = [dataSet objectAtIndex:indexPath.row];
        [dataField resignFirstResponder];
        
        [self closeCatTables];
    }
}


#pragma mark
#pragma mark UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView  numberOfRowsInComponent:(NSInteger)component {
    NSArray * sortOptions = [[Engine setting] objectForKey:@"arr.sort.options"];
    return [sortOptions count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray * sortOptions = [[Engine setting] objectForKey:@"arr.sort.options"];
    return [sortOptions objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    sortOption = row;
    [self cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self sortExpenses];
        [self.table reloadData];
    });
}


- (IBAction)onSave:(id)sender {
    if([self checkForm:YES]) {
        
        NSString * amount = self.amount.text;
        NSString * desc = self.desc.text;
        NSString * category = self.category.text;
        NSString * subcategory = self.subcategory.text;
        NSString * date = self.date.text;
        
        NSNumber * formattedAmount = [formatter numberFromString:amount];
        NSDate * formattedDate = [[Expense getDateFormat] dateFromString:date];
        
        [sender setEnabled:NO];
        
        [[Engine expense] submitExpense:desc
                                       :category
                                       :subcategory
                                       :[formattedAmount doubleValue]
                                       :[formattedDate timeIntervalSince1970]
                                success:^(Expense * expense) {
                                    [self clearForm];
                                    [self closeHeader:nil];
                                    [sender setEnabled:YES];
                                } error:^(NSError* err){
                                    [Util alertForKey:@"alert.unknown.error"];
                                    [sender setEnabled:YES];
                                }];
    }
}

static NSNumberFormatter * formatter;
-(BOOL)checkForm:(BOOL)showError {
    if(formatter == nil)
        formatter = [NSNumberFormatter new];
    
    NSString * amount = self.amount.text;
    NSString * desc = self.desc.text;
    NSString * category = self.category.text;
    NSString * subcategory = self.subcategory.text;
    NSString * date = self.date.text;
    
    NSNumber * formattedAmount = [formatter numberFromString:amount];
    NSDate * formattedDate = [[Expense getDateFormat] dateFromString:date];
    
    if(amount == nil || [amount length] <= 0) {
        if(showError) {
            self.errorLabel.text = [[Engine setting] stringForKey:@"txt.error.amount.empty"];
        }
        return NO;
    }
    if(formattedAmount == nil) {
        if(showError) {
            self.errorLabel.text = [[Engine setting] stringForKey:@"txt.error.amount.format"];
        }
        return NO;
    }
    if(desc == nil || [desc length] <= 0) {
        if(showError) {
            self.errorLabel.text = [[Engine setting] stringForKey:@"txt.error.desc.empty"];
        }
        return NO;
    }
    if(category == nil || [category length] <= 0) {
        if(showError) {
            self.errorLabel.text = [[Engine setting] stringForKey:@"txt.error.category.empty"];
        }
        return NO;
    }
    if([category length] > 255) {
        if(showError) {
            self.errorLabel.text = [[Engine setting] stringForKey:@"txt.error.category.length"];
        }
        return NO;
    }
    if([subcategory length] > 255) {
        if(showError) {
            self.errorLabel.text = [[Engine setting] stringForKey:@"txt.error.subcategory.length"];
        }
        return NO;
    }
    
    if(date == nil || [date length] <= 0) {
        if(showError) {
            self.errorLabel.text = [[Engine setting] stringForKey:@"txt.error.date.empty"];
        }
        return NO;
    }
    
    long unixtime = [formattedDate timeIntervalSince1970];
    if(formattedDate == nil || unixtime < 0) {
        if(showError) {
            self.errorLabel.text = [[Engine setting] stringForKey:@"txt.error.date.format"];
        }
        return NO;
    }
    
    return YES;
}

-(void)clearForm {
    self.amount.text = @"";
    self.desc.text = @"";
    self.category.text = @"";
    self.subcategory.text = @"";
    self.date.text = @"";
    
    self.errorLabel.text = @"";
    
    [self closeCatTables];
}



#pragma mark
#pragma mark UITextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self closeCatTables];
    if(textField == self.category) {
        [self categorySearch:@"" :textField :self.categoryTable :categorySuggestions];
    }
    if(textField == self.subcategory) {
        [self categorySearch:@"" :textField :self.subCategoryTable :subCategorySuggestions];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //DO search
    
    if(textField == self.category) {
        NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self categorySearch:searchStr :textField :self.categoryTable :categorySuggestions];
    }
    if(textField == self.subcategory) {
        NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self categorySearch:searchStr :textField :self.subCategoryTable :subCategorySuggestions];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //Go to next
    if(textField == self.searchField) {
        [self onDoSearch:nil];
    }
    return YES;
}

-(void)categorySearch:(NSString*)searchStr :(UITextField*)textField :(UITableView*)table :(NSMutableArray*)targetArray{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        [[Engine expense] searchCategory:searchStr
                                 success:^(NSArray * result){
                                     if([searchStr isEqualToString:textField.text]) {
                                         [targetArray removeAllObjects];
                                         for(int i = 0; i < [result count] && i < 3; i++) {
                                             [targetArray addObject:[result objectAtIndex:i]];
                                         }
                                         
                                         [table reloadData];
                                         [UIView animateWithDuration:0.35 animations:^(){
                                             [Util setHeight:30*[targetArray count] view:table];
                                         }];
                                     }
                                 }
                                   error:^(NSError* err){
                                       //TT
                                   }];
    });
}



- (IBAction)onDoSearch:(id)sender {
    [self startLoadingAnimation];
    
    [[Engine expense] searchExpenses:self.searchField.text
                             success:^(NSArray * results) {
                                 [self stopLoadingAnimation];
                                 expenses = results;
                                 [self sortExpenses];
                                 [self.table reloadData];
                                 [self closeHeader:nil];
                             }
                               error:^(NSError * err){
                                   [self stopLoadingAnimation];
                                   [Util alertForKey:@"alert.unknown.error"];
                                   
                                   
                               }];
}


-(void)closeCatTables {
    [categorySuggestions removeAllObjects];
    [subCategorySuggestions removeAllObjects];
    [UIView animateWithDuration:0.35 animations:^() {
        [Util setHeight:0 view:self.categoryTable];
        [Util setHeight:0 view:self.subCategoryTable];
    }];
}



-(void)sortExpenses {
    expenses = [expenses sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        Expense *first = (Expense*)a;
        Expense *second = (Expense*)b;
        switch (sortOption) {
            case 0: //<string>Time: Newest</string>
                return [[second getDate] compare:[first getDate]];
            case 1: //<string>Time: Oldest</string>
                return [[first getDate] compare:[second getDate]];
            case 2: //<string>Category: A -&gt; Z</string>
                if([[first getCategory] isEqualToString:[second getCategory]])
                    return [[first getSubCategory] compare:[second getSubCategory]];
                return [[first getCategory] compare:[second getCategory]];
            case 3: //<string>Category: Z -&gt; A</string>
                if([[first getCategory] isEqualToString:[second getCategory]])
                    return [[second getSubCategory] compare:[first getSubCategory]];
                return [[second getCategory] compare:[first getCategory]];
            case 4: //<string>Description: A -&gt; Z</string>
                return [[first getDesc] compare:[second getDesc]];
            case 5: //<string>Description: Z -&gt; A</string>
                return [[second getDesc] compare:[first getDesc]];
            case 6: //<string>Amount: low heigh</string>
                return [first getAmount] > [second getAmount];
            case 7: //<string>Amount high lowZ -&gt; A</string>
                return [second getAmount] > [first getAmount];
        }
        
        return 0;
    }];
}
@end
