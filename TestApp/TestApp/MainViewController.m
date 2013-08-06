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
#import "FavoritesViewController.h"


@implementation MainViewController


- (id)init
{
    self = [super init];
    if (self)
    {
        // добавим контроллеров самих отображений
        // избранные
        FavoritesViewController* favoritesVC = [[FavoritesViewController alloc] initWithNibName:@"FavoritesView"
                                                                                         bundle:nil];
        // картинки
        ShotsViewController* shotsVC = [[ShotsViewController alloc] initWithNibName:@"ShotsView"
                                                                             bundle:nil];
        // настройки
        SettingViewController* settingVC = [[SettingViewController alloc] initWithNibName:@"SettingView"
                                                                                   bundle:nil];
        self.viewControllers = [NSArray arrayWithObjects:
                                favoritesVC, shotsVC, settingVC,
                                nil];
    }
    return self;
}


@end
