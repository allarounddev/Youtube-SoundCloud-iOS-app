//
//  AmazonTool.swift
//  Streamini
//
//  Created by Vasily Evreinov on 01/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol AmazonToolDelegate: class {
    func imageDidUpload()
    func imageUploadFailed(_ error: NSError)
}

let AWSRegionNameUSEast1 = "us-east-1";
let AWSRegionNameUSWest2 = "us-west-2";
let AWSRegionNameUSWest1 = "us-west-1";
let AWSRegionNameEUWest1 = "eu-west-1";
let AWSRegionNameEUCentral1 = "eu-central-1";
let AWSRegionNameAPSoutheast1 = "ap-southeast-1";
let AWSRegionNameAPNortheast1 = "ap-northeast-1";
let AWSRegionNameAPSoutheast2 = "ap-southeast-2";
let AWSRegionNameSAEast1 = "sa-east-1";
let AWSRegionNameCNNorth1 = "cn-north-1";
let AWSRegionNameUSGovWest1 = "us-gov-west-1";

class AmazonTool: NSObject {
    weak var delegate: AmazonToolDelegate?
    
    class var shared : AmazonTool {
        struct Static {
            static let instance : AmazonTool = AmazonTool()
        }
        return Static.instance
    }
    
    class func isAmazonSupported() -> Bool {
        let (accessKeyId, _, _, _, _) = Config.shared.amazon()
        return !accessKeyId.isEmpty
    }
    
    override init () {
        super.init()
        
        // Setup Amazon S3
        AWSLogger.default().logLevel = .error
        
        let (accessKeyId, secretAccessKey, region, _, _) = Config.shared.amazon()
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKeyId, secretKey: secretAccessKey)
        let configuration = AWSServiceConfiguration(region: AmazonTool.regionTypeFromName(region), credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func uploadImage(_ image: UIImage, name: String) {
        uploadImage(image, name: name, uploadProgress: nil)
    }
    
    func uploadImage(_ image: UIImage, name: String, uploadProgress: AWSNetworkingUploadProgressBlock?) {
        let (_, _, _, _, imagesBucket) = Config.shared.amazon()
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.key = name
        uploadRequest?.bucket = imagesBucket
        
        if let progress = uploadProgress {
            uploadRequest?.uploadProgress = progress
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let basePath = paths[0] 
        let filePath = (basePath as NSString).appendingPathComponent(name)
        let binaryImageData = image.jpegData(compressionQuality: 1.0)
        try? binaryImageData!.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
        
        let fileURL = URL(fileURLWithPath: filePath)
        
        uploadRequest?.body = fileURL
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task) -> AnyObject? in
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch _ {
            }
            if let del = self.delegate {
                if let error = task.error {
                    del.imageUploadFailed(error as NSError)
                } else {
                    del.imageDidUpload()
                }
            }
            
            return nil
        })
    }
    
    class func regionTypeFromName(_ regionName: String) -> (AWSRegionType) {
        
        switch (regionName) {
            case AWSRegionNameUSEast1:
                return AWSRegionType.USEast1;
            case AWSRegionNameUSWest2:
                return AWSRegionType.USWest2;
            case AWSRegionNameUSWest1:
                return AWSRegionType.USWest1;
            case AWSRegionNameEUWest1:
                return AWSRegionType.EUWest1;
            case AWSRegionNameEUCentral1:
                return AWSRegionType.EUCentral1;
            case AWSRegionNameAPSoutheast1:
                return AWSRegionType.APSoutheast1;
            case AWSRegionNameAPSoutheast2:
                return AWSRegionType.APSoutheast2;
            case AWSRegionNameAPNortheast1:
                return AWSRegionType.APNortheast1;
            case AWSRegionNameSAEast1:
                return AWSRegionType.SAEast1;
            case AWSRegionNameCNNorth1:
                return AWSRegionType.CNNorth1;
            case AWSRegionNameUSGovWest1:
                return AWSRegionType.USGovWest1;
            default:
                return AWSRegionType.Unknown;
        }
    }
}
