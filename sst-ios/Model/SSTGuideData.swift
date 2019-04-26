//
//  SSTGuide.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/7/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

let kGuides = "guides"
let kGuideSkipAll = "skipAll"
let kGuideUpdated = "updated"

let kGuideUpdatedKey = "GuideUpdate"

class SSTGuideData {
    
    fileprivate(set) var guides = [SSTGuide]()
    fileprivate(set) var skipAll = 1        // hidden the skip button when 0
    fileprivate(set) var inBundle = true
//    fileprivate(set) var updated = true     // if have updated the local data, then set it true, or false
    
    init() {
        for ind in 0 ..< kGuideDefaultImageNames.count {
            if let guide = SSTGuide(JSON: [
                    kGuideImagePath:validString(kGuideDefaultImageNames.validObjectAtIndex(ind)),
                    kGuideTitle: validString(kGuideDefaultTitles.validObjectAtIndex(ind)),
                    kGuideContent: validString(kGuideDefaultContents.validObjectAtIndex(ind))
                ]) {
                guides.append(guide)
            }
        }
        inBundle = true
        
        if FileOP.fileExists(kGuideFileName) {
            if let data = FileOP.unarchive(kGuideFileName) {
                self.update(data)
                inBundle = false
            }
        }
    }
    
    func update(_ data: AnyObject?) {
        let dict = validDictionary(data)
        
        let arr = validArray(dict[kGuides])
        skipAll = validInt(dict[kGuideSkipAll])
        
        var mGuides = [SSTGuide]()
        for ind in 0 ..< arr.count {
            if let guide = SSTGuide(JSON: validDictionary(arr[ind])) {
                guide.number = ind
                mGuides.append(guide)
            }
        }
        self.guides = mGuides
    }
    
    func findGuideByImageUrl(imgUrl: String) -> Bool {
        for guide in self.guides {
            if guide.imgUrl == imgUrl {
                return true
            }
        }
        return false
    }
    
    func findGuideByTitle(_ title: String) -> Bool {
        for guide in self.guides {
            if guide.title == title {
                return true
            }
        }
        return false
    }
    
    func findGuideByContent(_ content: String) -> Bool {
        for guide in self.guides {
            if guide.content == content {
                return true
            }
        }
        return false
    }
    
    func getImageFromURL(fileUrl: String) -> UIImage? {
        if let mURL = URL(string: fileUrl) {
            if let mData = try? Data(contentsOf: mURL) {
                return UIImage(data: mData)
            }
        }
        return nil
    }
    
    func getNSDataFromURL(fileUrl: String) -> NSData? {
        if let mURL = URL(string: fileUrl) {
            return try? NSData(contentsOf: mURL)
        }
        return nil
    }
    
    func fetchImages() {
        biz.getGuides { data, error in
            if error == nil {
                DispatchQueue.global().async {
//                    printDebug("开始执行异步任务")
                    
                    Thread.sleep(forTimeInterval: 2)
                    var dict = validDictionary(data)
                    
                    var mGuides = [SSTGuide]()
                    
                    var updated = false
                    for dict in validArray(dict[kGuides]) {
                        if let guide = SSTGuide(JSON: validDictionary(dict)) {
                            if !self.findGuideByImageUrl(imgUrl: guide.imgUrl) {
                                if let mNSData = self.getNSDataFromURL(fileUrl: guide.imgUrl) {
                                    _ = FileOP.write(fileName: "guide_\(validString(guide.id))", fileData: mNSData, overwrite: true)
                                    mGuides.append(guide)
                                }
                                updated = true
                            } else if !self.findGuideByTitle(guide.title) {
                                updated = true
                            } else if !self.findGuideByContent(guide.content) {
                                updated = true
                            }
                        }
                    }
                    
                    setUserDefautsData(kGuideUpdatedKey, value: updated)

                    self.guides = mGuides
                    FileOP.archive(kGuideFileName, object: dict)
//                    printDebug("异步任务执行完毕")
                    
//                    DispatchQueue.main.async {
//                        printDebug("回到UI线程")
//                    }
                }
            } else {
                #if DEV
//                    showToastOnlyForDEV("\(error)")
                #endif
            }
        }
    }
}
