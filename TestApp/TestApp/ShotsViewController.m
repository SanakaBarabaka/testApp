//
//  ShotsViewController.m
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import "ShotsViewController.h"
#import "DatabaseManager.h"
#import "User.h"



//TODO: tasks
/*
 
 Shots - содержит все шоты,  
 
 - На скрине Shots должен быть реализован поиск по шотам.
 
 
 - В случае если шотов нет мы должны видеть надпись No shots available (аналогично
 
 для скрина shots).
 
 - Добавление шотов должно происходить со скрина Shots по нажатию на звездочку.
 
 - На скрине Settings после logOut мы должны попадать на скрин с авторизацией.
 
 - По нажатию на какой либо шот мы должны переходить на скрин с коментариями
 
 этого шота. Коментарии могут удаляться локально.
 
 */



@interface ShotsViewController ()
{
    bool	updateNeeded;
}

- (void)updateShots;

@end


@implementation ShotsViewController


#pragma mark ----- Initialization -----


- (void)dealloc
{
    [noShotsLabel release];
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // картинку в таббар
        self.tabBarItem.image = [UIImage imageNamed:@"box"];
        self.tabBarItem.title = @"Shots";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


#pragma mark ----- Events -----


- (void)viewWillAppear:(BOOL)animated
{
    // обновим данные, если нужно
    if (updateNeeded)
        [self updateShots];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //TODO: dispose of images
    
    updateNeeded = true;
}


#pragma mark ----- Actions -----


- (void)updateShots
{
    // получим текущего пользователя
    User* currentUser = [DatabaseManager sharedDatabaseManager].currentUser;
    if (currentUser != nil)
    {
        //TODO: - (void)updateShots
        // посмтрим, сколько у пользователя картинок
        currentUser.shots == nil;
    }

}


@end