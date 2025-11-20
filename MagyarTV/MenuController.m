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

@interface MenuController () <AVPlayerViewControllerDelegate>

@property (nonatomic, strong) NSArray<UIImage *> *logos;
@property (nonatomic, strong) NSArray<NSString *> *channelNames;

@end


@implementation MenuController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const playerReferer = @"https://player.mediaklikk.hu/playernew/";

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show Channel"]) {
        PlayerController *controller = (PlayerController *)segue.destinationViewController;
        controller.delegate = self;
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
                   [UIImage imageNamed:@"m5logo"],
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
                          @"mtv5",
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
    return self.channelNames.count;
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

#pragma mark - <AVPlayerViewControllerDelegate>

- (void)playerViewController:(AVPlayerViewController *)playerViewController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    if (self.presentedViewController == nil) {
        [self presentViewController:playerViewController animated:NO completion:nil];
    }
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
    
    NSURL *channelURL = [self urlForChannel:channelName];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:channelURL];
    [request setValue:playerReferer forHTTPHeaderField:@"Referer"];
    
    NSLog(@"Loading URL: %@...", channelURL);
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error || httpResponse.statusCode >= 400 || !data) {
            NSString *reason = [error localizedDescription] ?: [NSString stringWithFormat:@"HTTP %@", @(httpResponse.statusCode)];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [strongSelf displayError:[NSString stringWithFormat:@"A csatorna nem tötlhető be. Próbálkozz később!\n\n(A hiba oka: %@)", reason]];
            });
            return;
        }
        
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
                    
                    NSURL *liveStreamURL = [NSURL URLWithString:unescapedString];
                    if (liveStreamURL) {
                        NSLog(@"URL: %@", liveStreamURL);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            [strongSelf performSegueWithIdentifier:@"Show Channel" sender:liveStreamURL];
                        });
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            [strongSelf displayError:@"A csatorna nem tötlhető be. Próbálkozz később!\n\n(A hiba oka: Nem található a csatorna URL-je)"];
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [strongSelf displayError:@"A csatorna nem tötlhető be. Próbálkozz később!\n\n(A hiba oka: Hibás HTML 03)"];
                    });
                    NSLog(@"count: %@, urlSplit: %@", @(urlSplit.count), urlSplit);
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [strongSelf displayError:@"A csatorna nem tötlhető be. Próbálkozz később!\n\n(A hiba oka: Hibás HTML 02)"];
                });
                NSLog(@"count: %@, fileTagSplit: %@", @(fileTagSplit.count), fileTagSplit);
            }
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [strongSelf displayError:@"A csatorna nem tötlhető be. Próbálkozz később!\n\n(A hiba oka: Hibás HTML 01)"];
            });
            NSLog(@"count: %@, sourceTagSplit: %@", @(sourceTagSplit.count), sourceTagSplit);
        }
    }];
    
    [task resume];
}

@end
