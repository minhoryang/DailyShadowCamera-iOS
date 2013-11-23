//
//  CNUViewController.h
//  kr.ac.sogang.cnu.dailyshadowcamera
//
//  Created by CNU on 11/22/13.
//  Copyright (c) 2013 CNU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface CNUViewController : UIViewController <UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UISlider *uiSlider;
@property (weak, nonatomic) IBOutlet UIImageView *BringImage;


@end
