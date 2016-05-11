//
//  ViewController.m
//  ExifTest
//
//  Created by CaiZetong on 16/5/11.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>


@interface ViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonAction:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.editing = NO;
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
//    view.backgroundColor = [UIColor redColor];
//    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //通过Image不能获取完整的exif信息.
        self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
        NSData *imageNSData = UIImageJPEGRepresentation(self.imageView.image, 1);
        CGImageSourceRef imgSource = CGImageSourceCreateWithData((__bridge_retained CFDataRef)imageNSData, NULL);
    
        //get all the metadata in the image
        NSDictionary *metadata = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imgSource, 0, NULL);
    
//        NSMutableDictionary *EXIFDictionary = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
    
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Info from UIImage" message:[metadata description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alerView show];
    //    [self.headImageButton setImage:image forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    __block NSDate *date;
    __block CLLocation *location;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
        PHAsset *asset = fetchResult.firstObject;
        
        date = asset.creationDate;
        location = asset.location;
        
        
    }
    else
    {
        NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            
            // try to retrieve gps metadata coordinates
            //        CLLocation* myLocation = [self locationFromAsset:asset];
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            NSLog(@"type:%@",type);
            
            location = [asset valueForProperty:ALAssetPropertyLocation];
            date = [asset valueForProperty:ALAssetPropertyDate];
        } failureBlock:^(NSError *error) {
            NSLog(@"Error");
        }];

    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    UIAlertView *alerView2 = [[UIAlertView alloc] initWithTitle:@"Info from asset" message:[NSString stringWithFormat:@"location=%@ \n date=%@", location, [dateFormatter stringFromDate:date]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alerView2 show];
    
}
@end
