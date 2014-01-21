//
//  ToDoListViewController.m
//  todoapp
//
//  Created by Joey Lin on 1/19/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <objc/runtime.h>
#import "ToDoListViewController.h"
#import "EditableCell.h"

static char indexPathKey;
static NSString * const TODOLIST = @"toDoList";

@interface ToDoListViewController ()

@property (nonatomic, strong) NSMutableArray *taskList;
@property (nonatomic, strong) EditableCell *prototypeCell;

- (void)addNewEntry;
- (void)startEditing;
- (void)stopEditing;
- (void)updateTask:(UITextView *)textView indexPath:(NSIndexPath *)indexPath;
- (void)persistData;

@end

@implementation ToDoListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self.taskList = [[NSMutableArray alloc] init];
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id savedObject = [defaults objectForKey:TODOLIST];
    if (savedObject) {
        self.taskList = savedObject;
    }
    NSLog(@"%@", self.taskList);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"To Do List";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(addNewEntry)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(startEditing)];


    
    UINib *customNib = [UINib nibWithNibName:@"EditableCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"EditableCell"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.taskList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EditableCell";
    EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.showsReorderControl = YES;
    cell.taskView.text = [self.taskList objectAtIndex:indexPath.row];
    //NSLog(@"index path is %i", indexPath.row);
    cell.taskView.delegate = self;
    [cell.taskView setReturnKeyType:UIReturnKeyDone];
    //cell.taskView.clearsOnInsertion = YES;
    objc_setAssociatedObject(cell.taskView, &indexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    
    return cell;
}

- (void)persistData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.taskList forKey:TODOLIST];
    [defaults synchronize];
}

- (void)addNewEntry {
    NSLog(@"adding new line");
    [self.taskList insertObject:@"" atIndex:0];
    NSLog(@"%@", self.taskList);
    [self persistData];
    [self.tableView reloadData];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
     EditableCell *editableCell = (EditableCell* )((id)cell);
    
    [editableCell.taskView becomeFirstResponder];
}

- (void)startEditing {
    [self.tableView setEditing:YES animated:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(stopEditing)];
    [self.tableView reloadData];
}

- (void)stopEditing {
    [self.tableView setEditing:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(startEditing)];
}

- (void)updateTask:(UITextView *)textView indexPath:(NSIndexPath *)indexPath {
    [self.taskList setObject:textView.text atIndexedSubscript:indexPath.row];
    NSLog(@"updating task at row %d", indexPath.row);
    NSLog(@"%@", self.taskList);

    [self persistData];
    [self.tableView reloadData];
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    NSLog(@"calling return delegate");
//    NSIndexPath *indexPath = objc_getAssociatedObject(textField, &indexPathKey);
//    [self updateTask:textField indexPath:indexPath];
//    [textField resignFirstResponder];
//    
//    return YES;
//}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        NSIndexPath *indexPath = objc_getAssociatedObject(textView, &indexPathKey);
        [self updateTask:textView indexPath:indexPath];
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

        self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"EditableCell"];
        self.prototypeCell.taskView.text = [self.taskList objectAtIndex:indexPath.row];
   
    [self.prototypeCell layoutIfNeeded];

    CGFloat height = self.prototypeCell.taskView.contentSize.height;
    NSLog(@"height is: %f", height);
    
    return height;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.taskList removeObjectAtIndex:indexPath.row];
        [self persistData];
        [self.tableView reloadData];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.taskList exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    [self persistData];
    [self.tableView reloadData];
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
