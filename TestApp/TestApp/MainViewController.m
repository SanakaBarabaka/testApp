//
//  MainViewController.m
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "ShotsViewController.h"


@implementation MainViewController


- (id)init
{
    self = [super init];
    if (self)
    {
        // добавим контроллеров самих отображений
        // избранные
        ShotsViewController* favoritesVC = [[ShotsViewController alloc] initWithNibName:@"ShotsView"
                                                                                 bundle:nil];
        favoritesVC.favoritesOnlyMode = true;
        UINavigationController* favoritesNavVC = [[UINavigationController alloc] initWithRootViewController:favoritesVC];
        // картинки
        ShotsViewController* shotsVC = [[ShotsViewController alloc] initWithNibName:@"ShotsView"
                                                                             bundle:nil];
        UINavigationController* shotsNavVC = [[UINavigationController alloc] initWithRootViewController:shotsVC];
        // настройки
        SettingViewController* settingVC = [[SettingViewController alloc] initWithNibName:@"SettingView"
                                                                                   bundle:nil];
        self.viewControllers = [NSArray arrayWithObjects:
                                favoritesNavVC, shotsNavVC, settingVC,
                                nil];
        
        [favoritesVC release];
        [shotsVC release];
        [shotsNavVC release];
        [settingVC release];
    }
    return self;
}


@end
