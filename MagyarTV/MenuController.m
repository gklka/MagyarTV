//
//  MenuController.m
//  MagyarTV
//
//  Created by GK on 2016.07.09..
//  Copyright © 2016. GKSoftware. All rights reserved.
//

#import "MenuController.h"
#import "MenuCell.h"
#import "PlayerController.h"

@import SVProgressHUD;
@import AVKit;

@interface MenuController ()

@property (nonatomic, strong) NSArray<UIImage *> *logos;
@property (nonatomic, strong) NSArray<NSString *> *channelNames;

@end


@implementation MenuController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show Channel"]) {
        PlayerController *controller = (PlayerController *)segue.destinationViewController;
        NSURL *liveStreamURL = (NSURL *)sender;
        controller.player = [AVPlayer playerWithURL:liveStreamURL];
    }
}


#pragma mark - Accessors

- (NSArray<UIImage *> *)logos {
    if (!_logos) {
        _logos = @[[UIImage imageNamed:@"m1logo"],
                   [UIImage imageNamed:@"m2logo"],
                   [UIImage imageNamed:@"m4logo"],
                   [UIImage imageNamed:@"dunalogo"],
                   [UIImage imageNamed:@"dunaworldlogo"]];
    }
    
    return _logos;
}

- (NSArray<NSString *> *)channelNames {
    if (!_channelNames) {
        _channelNames = @[@"mtv1",
                          @"mtv2",
                          @"mtv4",
                          @"duna",
                          @"dunaworld"];
    }
    
    return _channelNames;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell.logoImageView setImage:[self.logos objectAtIndex:indexPath.item]];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self openLiveStreamForChannel:[self.channelNames objectAtIndex:indexPath.item]];
}

#pragma mark - Helper

- (NSURL *)urlForChannel:(NSString *)channelName {
    NSString *urlString = [NSString stringWithFormat:@"https://player.mediaklikk.hu/playernew/player.php?video=%@live&noflash=yes&osfamily=iOS&osversion=11.0&browsername=Safari&browserversion=11.0&title=%@&conteintid=%@live&embedded=0", channelName, channelName, channelName];
    return [NSURL URLWithString:urlString];
}

- (void)displayError:(NSString *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Hálózati hiba" message:error preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)openLiveStreamForChannel:(NSString *)channelName {
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSURL *channelURL = [self urlForChannel:channelName];
        [SVProgressHUD dismiss];
        
        NSError *error;
        NSData *htmlData = [NSData dataWithContentsOfURL:channelURL options:0 error:&error];
        if (htmlData) {
            NSString *html = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
            
            NSLog(@"HTML: %@", html);
            
            NSArray *sourceTagSplit = [html componentsSeparatedByString:@"\"playlist\":"];
            if (sourceTagSplit.count > 1) {
                
                NSArray *fileTagSplit = [sourceTagSplit[1] componentsSeparatedByString:@"\"file\": \""];
                if (fileTagSplit.count > 1) {
                    
                    NSLog(@"%@", fileTagSplit[1]);
                
                    NSArray *urlSplit = [fileTagSplit[1] componentsSeparatedByString:@"\",\n"];
                    if (urlSplit.count > 1) {
                        
                        NSLog(@"URL before transforming: %@", urlSplit[0]);
                        
                        NSString *unescapedString = [urlSplit[0] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                        NSString *secureString = [NSString stringWithFormat:@"https:%@", unescapedString];
                        
                        NSURL *liveStreamURL = [NSURL URLWithString:secureString];
                        if (liveStreamURL) {
                            NSLog(@"URL: %@", liveStreamURL);
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self performSegueWithIdentifier:@"Show Channel" sender:liveStreamURL];
                            });
                            
                        } else {
                            [self displayError:@"A csatorna nem tötlhető be. Próbálkozz később!\n\n(A hiba oka: Nem található a csatorna URL-je)"];
                        }
                    } else {
                        [self displayError:@"A csatorna nem tötlhető be. Próbálkozz később!\n\n(A hiba oka: Hibás HTML 03)"];
                        NSLog(@"count: %@, urlSplit: %@", @(urlSplit.count), urlSplit);
                    }
                } else {
                    [self displayError:@"A csatorna nem tötlhető be. Próbálkozz később!\n\n(A hiba oka: Hibás HTML 02)"];
                    NSLog(@"count: %@, fileTagSplit: %@", @(fileTagSplit.count), fileTagSplit);
                }
                
            } else {
                [self displayError:@"A csatorna nem tötlhető be. Próbálkozz később!\n\n(A hiba oka: Hibás HTML 01)"];
                NSLog(@"count: %@, sourceTagSplit: %@", @(sourceTagSplit.count), sourceTagSplit);
            }
            
            
        } else {
            [self displayError:[NSString stringWithFormat:@"A csatorna nem tötlhető be. Próbálkozz később!\n\n(A hiba oka: %@)", [error localizedDescription]]];
        }
    });
}

@end
