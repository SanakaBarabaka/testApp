//
//  ShotsViewController.m
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import "ShotsViewController.h"
#import "DataModel.h"
#import "ShotsCell.h"
#import "Shot.h"
#import "DatabaseManager.h"
#import "CommentsViewController.h"


@interface ShotsViewController () <ShotsCellDelegate>
{
    // сингдетон
    DataModel*	sharedDataModel;
    
    // 
    bool	updateNeeded;
    // количество картинок
    NSMutableArray*	shotsList;
    
    // заготовка, из который мы будем создавать нуши кастомные ячейки для таблицы
    UINib*	customCellNib;
    
    bool	shown;
    
    UIBarButtonItem* refreshButton;
    
    bool	isIPad;
}

- (void)updateShots;
- (void)onRefreshButton:(id)sender;
- (void)onImageDownloaded:(NSNotification*)notification;
- (void)onShotsUpdated:(NSNotification*)notification;
- (void)onFavoritesUpdated:(NSNotification*)notification;
- (void)onUserChanged:(NSNotification*)notification;

@end


@implementation ShotsViewController

@synthesize favoritesOnlyMode;
@synthesize cellEtalon;

#pragma mark ----- Initialization -----


- (void)dealloc
{
    [searchBar release];
    [customCellNib release];
    [refreshButton release];
    [shotsList release];
    [shotsTable release];
    [noShotsLabel release];
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //--defaults--
        favoritesOnlyMode = false;
        shotsList = nil;
        shown = true;
        
        // картинку в таббар
        self.tabBarItem.image = [UIImage imageNamed:@"box"];
        self.tabBarItem.title = @"Shots";
        self.navigationItem.title = @"Shots";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    sharedDataModel = [DataModel sharedDataModel];
    
    // добавим кнопку обновить
    refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                  target:self
                                                                  action:@selector(onRefreshButton:)];
    if (!favoritesOnlyMode)
        self.navigationItem.rightBarButtonItem = refreshButton;
    
    // подгрузим ячейку
    isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    if (isIPad)
        customCellNib = [[UINib nibWithNibName:@"ShotsCellView-iPad" bundle:nil] retain];
    else
        customCellNib = [[UINib nibWithNibName:@"ShotsCellView" bundle:nil] retain];
    
    // покажем надпись
    noShotsLabel.hidden = false;
    updateNeeded = true;
    shotsTable.hidden = true;
    
    // подпишемся на сообщение об обновлении списка картинок
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onShotsUpdated:)
                                                 name:NOTIFICATION_DM_ShotsUpdated
                                               object:nil];
    // и на "картинка скачалась"
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onImageDownloaded:)
                                                 name:NOTIFICATION_DM_ImageDownloaded
                                               object:nil];
    // пользователь изменился
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserChanged:)
                                                 name:NOTIFICATION_DBM_UserLoggedIn
                                               object:nil];
}


- (void)setFavoritesOnlyMode:(bool)aFavoritesOnlyMode
{
    if (favoritesOnlyMode == aFavoritesOnlyMode)
        return;
    favoritesOnlyMode = aFavoritesOnlyMode;
    if (favoritesOnlyMode)
    {
        // картинку в таббар
        self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1] autorelease];
        self.navigationItem.title = @"Favorites";
        
        self.navigationItem.rightBarButtonItem = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onFavoritesUpdated:)
                                                     name:NOTIFICATION_DM_FavoritesChanged
                                                   object:nil];
    }
    else
    {
        // картинку в таббар
        self.tabBarItem.image = [UIImage imageNamed:@"box"];
        self.tabBarItem.title = @"Shots";
        self.navigationItem.title = @"Shots";
        
        self.navigationItem.rightBarButtonItem = refreshButton;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NOTIFICATION_DM_FavoritesChanged
                                                      object:nil];
    }
    updateNeeded = true;
}


#pragma mark ----- Events -----


- (void)viewWillAppear:(BOOL)animated
{
    shown = true;
    // обновим данные, если нужно
    if (updateNeeded)
        [self updateShots];
    
    [super viewWillAppear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    shown = false;
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // dispose of images
    [[DataModel sharedDataModel] clearCache];
}


- (void)onImageDownloaded:(NSNotification*)notification
{
    // если это наша картинка, то обновим ячейку с этой картинкой
    NSNumber* shotID = notification.object;
    int cellIndex = [shotsList indexOfObject:shotID];
    if (cellIndex >= 0 && shotsList != nil)
    {
        [shotsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:cellIndex inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)onFavoritesUpdated:(NSNotification*)notification
{
    [self onShotsUpdated:notification];
}


- (void)onShotsUpdated:(NSNotification *)notification
{
    if (shown)
        [self updateShots];
    else
        updateNeeded = true;
}


- (void)onUserChanged:(NSNotification*)notification
{
    [self onShotsUpdated:notification];
}


#pragma mark ----- Actions -----


- (void)updateShots
{
    // посмотрим, сколько у пользователя картинок
    [shotsList release];
    shotsList = [[NSMutableArray alloc] initWithArray:[sharedDataModel getShotsFavoritesOnly:favoritesOnlyMode titleSearch:searchBar.text]];
    if (shotsList.count == 0)
    {
        shotsTable.hidden = true;
        noShotsLabel.hidden = false;
    }
    else
    {
        shotsTable.hidden = false;
        noShotsLabel.hidden = true;
        [shotsTable reloadData];
    }
    updateNeeded = false;
}


- (void)onRefreshButton:(id)sender
{
    [sharedDataModel refreshUserShots];
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
    if (shotsList != nil)
        return shotsList.count;
    else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"ShotsCell";
    ShotsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        [customCellNib instantiateWithOwner:self options:nil];
        cell = cellEtalon;
        self.cellEtalon = nil;
    }
    // настраиваем ячейку
    NSNumber* shotID = [shotsList objectAtIndex:indexPath.row];
    
    Shot* shot = [sharedDataModel getShot:shotID];
    UIImage* img = [sharedDataModel getImageForShot:shot];
    
    [cell fillWithImage:img
                  title:shot.title
              shotIndex:shotID
               delegate:self];
    cell.favorite = shot.favorite;
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isIPad)
        return 400.0f;
    else
        return 320.0f;
}


#pragma mark ----- ShotsCellDelegate -----


- (void)changeFavoriteOfShot:(NSNumber *)shotID to:(bool)favFlag
{
    [sharedDataModel setFavorite:favFlag forShot:shotID];
    // удалим картинку из списка, если она больше не любимая, а мы показываем только любимые
    if (favoritesOnlyMode && !favFlag)
    {
        [shotsList removeObject:shotID];
        [shotsTable reloadData];
    }
}


- (void)showCommentForShot:(NSNumber *)shotIndex
{
    CommentsViewController* commentsVC = [[CommentsViewController alloc] initWithNibName:@"CommentsView"
                                                                                  bundle:nil];
    commentsVC.shotID = shotIndex;
    [self.navigationController pushViewController:commentsVC animated:true];
    [commentsVC autorelease];
}


#pragma mark ----- UISearchBarDelegate -----


- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    // called when keyboard search button pressed
    
    // нужно обновить список картинок
    [self updateShots];
    
    // и убрать клавиатуру
    [aSearchBar resignFirstResponder];
}


- (void)searchBarCancelButtonClicked:(UISearchBar*)aSearchBar
{
    // called when cancel button pressed
    
    // опять обновить список и убрать клавиатуру
    [self searchBarSearchButtonClicked:aSearchBar];
}


@end