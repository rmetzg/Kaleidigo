//
//  PhotoLibraryManager.swift
//  Spindigo
//
//  Created by Alan Metzger on 8/1/25.
//

import Photos
import UIKit

enum PhotoLibraryManager {
    static func saveImageToPhotos(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                completion(false)
                return
            }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            completion(true)
        }
    }
}
