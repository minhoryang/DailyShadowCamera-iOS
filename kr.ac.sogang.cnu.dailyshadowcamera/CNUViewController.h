//
//  CNUViewController.h
//  kr.ac.sogang.cnu.dailyshadowcamera
//
//  Created by CNU on 11/22/13.
//  Copyright (c) 2013 CNU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CNUViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UISlider *uiSlider;
@property (weak, nonatomic) IBOutlet UIImageView *BringImage;

@end
