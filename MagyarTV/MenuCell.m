//
//  MenuCell.m
//  MagyarTV
//
//  Created by GK on 2016.07.09..
//  Copyright © 2016. GKSoftware. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell

- (void)setHighlighted:(BOOL)highlighted {
    self.alpha = highlighted ? 0.5 : 1.f;
}

@end
