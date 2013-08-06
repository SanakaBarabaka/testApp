//
//  SettingViewController.m
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import "SettingViewController.h"
#import "DatabaseManager.h"
#import "LogInViewController.h"
#import "User.h"


@interface SettingViewController ()
{
    bool	updateNeeded;
}

- (void)updateUser;
- (void)onUserChanged;

@end


@implementation SettingViewController


#pragma mark ----- Initialization -----


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // иконки в таббаре
        self.tabBarItem.title = @"Settings";
        self.tabBarItem.image = [UIImage imageNamed:@"box"];
    }
    return self;
}


- (void)dealloc
{
    [logoutButton release];
    [userNameLabel release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    logoutButton.enabled = false;
    
    [self updateUser];
    updateNeeded = false;
    
    // подпишемся на сообщения
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserChanged)
                                                 name:NOTIFICATION_DBM_UserLoggedIn
                                               object:nil];
}


#pragma mark ----- Events -----


- (void)viewWillAppear:(BOOL)animated
{
    // отображение будет показано пользователю
    // обновим инфу
    if (updateNeeded)
        [self updateUser];
}


- (void)onUserChanged
{
    updateNeeded = true;
}


#pragma mark ----- Actions -----


- (void)updateUser
{
    User* currentUser = [DatabaseManager sharedDatabaseManager].currentUser;
    if (currentUser == nil)
    {
        logoutButton.enabled = false;
        userNameLabel.text = @"-- not logged in --";
    }
    else
    {
        logoutButton.enabled = true;
        userNameLabel.text = [NSString stringWithFormat:@"username: %@", currentUser.login];
    }
    updateNeeded = false;
}


- (void)onLogOutButton:(id)sender
{
    // разлогинимся (забудем пользователя)
    [[DatabaseManager sharedDatabaseManager] logoutCurrentUser];
    
    // покажем форму логина
    LogInViewController* loginVC = [[LogInViewController alloc] initWithNibName:@"LogInView"
                                                                         bundle:nil];
    [self.tabBarController presentViewController:loginVC
                                        animated:true
                                      completion:nil];
    [loginVC autorelease];
}


@end