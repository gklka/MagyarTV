//
//  DetailViewController.h
//  MagyarTVMobile
//
//  Created by GK on 2017.10.04..
//  Copyright © 2017. GKSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

