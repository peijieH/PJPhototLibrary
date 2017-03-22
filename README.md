# PJPhototLibrary

PJPhotoLibrary is a lightweight and pure Swift implemented library for viewing and selecting image from the device photo library. You can select some images that you want conveniencely thought a few line code.For more details, please see the WeChat's photo library.


## Features

- [x] Use less memory when load the photo library
- [x] The photo libaray have a good performance

```swift
viewController.showPJPhotoAlbum() //load the photo library
let count = PJPhotoAlbum.shareCenter.count //select image num
PJPhotoAlbum.shareCenter.getImage(for index: Int, resultHandler: @escaping (UIImage?) -> Void) //callback
```

## Requirements

- iOS 8.0+ 
- Swift 3.0+

### Future

The cocoapods and swift manager Will  be supported soon

### Contact
Send the mail to hhpeijie@163.com

### License

PJPhotoLibrary is released under the MIT license. See LICENSE for details.

