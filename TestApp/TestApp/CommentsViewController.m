//
//  CommentsViewController.m
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import "CommentsViewController.h"
#import "DatabaseManager.h"
#import "DataModel.h"
#import "Comment.h"


@interface CommentsViewController ()
{
    // список комментариев - основа таблички
    NSMutableArray* comments;
    
    // преобразователь дат
    NSDateFormatter *dateFormatter;
    
    UILabel* testLabel;
}

- (void)updateComments;
- (void)onRefreshButton:(id)sender;
- (void)onUserChanged:(NSNotification*)notification;
- (void)onCommentsUpdated:(NSNotification*)notification;

@end


@implementation CommentsViewController

@synthesize shotID;

#pragma mark ----- Initialization -----


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        shotID = nil;
    }
    return self;
}


- (void)dealloc
{
    [testLabel release];
    [comments release];
    [commentsTable release];
    [noCommentsLabel release];
    [shotID release];
    [dateFormatter release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // покажем надпись
    noCommentsLabel.hidden = false;
    commentsTable.hidden = true;
    commentsTable.editing = true;
    
    // add update button
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(onRefreshButton:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];
    
    self.navigationItem.title = @"Comments";
    
    // подпишемся на всякие сообщения
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserChanged:)
                                                 name:NOTIFICATION_DBM_UserLoggedIn
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCommentsUpdated:)
                                                 name:NOTIFICATION_DM_CommentsUpdated
                                               object:nil];
    
    // контрол для подсчета нужной высоты ячейки в таблице
    testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, commentsTable.frame.size.width - 40, 10)];
    testLabel.numberOfLines = 0;
    testLabel.font = [UIFont systemFontOfSize:12.0f];
    testLabel.lineBreakMode = NSLineBreakByWordWrapping;
}


#pragma mark ----- Property -----


-(void)setShotID:(NSNumber *)aShotID
{
    [shotID release];
    shotID = [aShotID retain];
    
    // обновим таблицу
    [self updateComments];
}


#pragma mark ----- Events -----


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (shotID != nil)
        [self updateComments];
}


#pragma mark ----- Actions -----


- (void)updateComments
{
    // обновим список
    [comments release];
    comments = [[NSMutableArray alloc] initWithArray:[[DataModel sharedDataModel] getCommentsorderedByDateForShotWithID:shotID]];
    if (comments.count > 0)
    {
        commentsTable.hidden = false;
        noCommentsLabel.hidden = true;
        // перезагузим табличку
        [commentsTable reloadData];
    }
    else
    {
        commentsTable.hidden = true;
        noCommentsLabel.hidden = false;
    }
}


- (void)onRefreshButton:(id)sender
{
    // refresh comments in data model
    [[DataModel sharedDataModel] updateCommentsForShotWithID:shotID];
}


- (void)onUserChanged:(NSNotification *)notification
{
    // пользователь изменился
    // уберемся с глаз долой
    [self.navigationController popViewControllerAnimated:true];
}


- (void)onCommentsUpdated:(NSNotification *)notification
{
    // обновим данные у себя (если это наши данные)
    if ([(NSNumber*)notification.object isEqualToNumber:shotID])
        [self updateComments];
}


#pragma mark ----- UITableViewDataSource, UITableViewDelegate -----


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (comments != nil)
        return comments.count;
    else
        return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment* comment = [comments objectAtIndex:indexPath.row];
    
    testLabel.text = comment.text;
    [testLabel sizeToFit];
    
    return MAX(50.0f, testLabel.frame.size.height + 20.0f);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellReuseIdentifier = @"CommentsCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseIdentifier] autorelease];
        
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    
    // настраиваем ячейку
    Comment* comment = [comments objectAtIndex:indexPath.row];    
    cell.textLabel.text = comment.text;
    cell.detailTextLabel.text = [dateFormatter stringFromDate:comment.date];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return true;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [commentsTable reloadData];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < comments.count)
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Comment* comment = [comments objectAtIndex:indexPath.row];
        [[DataModel sharedDataModel] removeComment:comment fromShotWithID:shotID];
        
        [comments removeObjectAtIndex:indexPath.row];
        [commentsTable reloadData];
    }
}


@end