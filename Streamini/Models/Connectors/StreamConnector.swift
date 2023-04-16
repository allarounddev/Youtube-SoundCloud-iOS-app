//
//  StreamConnector.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class StreamConnector: Connector {
    
    func streams(_ getGlobal: Bool, success: @escaping (_ live: [Stream], _ recent: [Stream]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = (getGlobal) ? "stream/global" : "stream/followed"
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let liveStreamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.live", statusCodes: statusCode)
        
        let recentStreamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.recent", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(liveStreamResponseDescriptor)
        manager?.addResponseDescriptor(recentStreamResponseDescriptor)        
        
        manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.streams(getGlobal, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                var live: [Stream] = []
                if let l: AnyObject = mappingResult?.dictionary()["data.live"] as AnyObject? {
                    live = l as! [Stream]
                }
                
                var recent: [Stream] = []
                if let r: AnyObject = mappingResult?.dictionary()["data.recent"] as AnyObject? {
                    recent = r as! [Stream]
                }
                
                success(live, recent)
            }
        }, failure: {(operation, error) -> Void in
            failure(error! as NSError)
        })
    }
    
    func search(_ page: UInt, query: String, city: String, success: @escaping (_ streams: [Stream]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/search"
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.streams", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(responseDescriptor)
        
        var params = self.sessionParams()
        params!["p"] = page
        params!["q"] = query
        params!["city"] = city
        
        manager?.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.search(page, query: query, city: city, success: success, failure: failure)
                        }, failure: { () -> () in
                            failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let streams = mappingResult?.dictionary()["data.streams"] as! [Stream]
                success(streams)
            }
        }, failure: {(operation, error) -> Void in
            failure(error! as NSError)
        })
    }
    
    func recent(_ userId: UInt, success: @escaping (_ streams: [Stream]) -> (), failure: @escaping (_ error: NSError) -> ()) {
    let path = ("stream/recent" as NSString).appendingPathComponent("\(userId)")
    
    let streamMapping = StreamMappingProvider.streamResponseMapping()
    let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
    
    let responseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.recent", statusCodes: statusCode)
    
    manager?.addResponseDescriptor(responseDescriptor)
    
    manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
        // success code
        let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
        if !error.status {
        if error.code == kLoginExpiredCode {
            self.relogin({ () -> () in
                self.recent(userId, success: success, failure: failure)
            }, failure: { () -> () in
                failure(error.toNSError())
            })
        } else {
            failure(error.toNSError())
        }
        } else {
        let streams = mappingResult?.dictionary()["data.recent"] as! [Stream]
            success(streams)
        }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }
    
    func my(_ success: @escaping (_ streams: [Stream]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/my"
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.streams", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(responseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.my(success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let streams = mappingResult?.dictionary()["data.streams"] as! [Stream]
                success(streams)
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }
    
    func myplaylist(_ success: @escaping (_ streams: [Stream]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/myplaylist"
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.streams", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(responseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.my(success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let streams = mappingResult?.dictionary()["data.streams"] as! [Stream]
                success(streams)
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }

    func create(_ data: NSDictionary, success: @escaping (_ stream: Stream) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/create"
        
        let requestMapping  = StreamMappingProvider.createStreamRequestMapping()
        let streamMapping   = StreamMappingProvider.streamResponseMapping()
        
        let requestDescriptor = RKRequestDescriptor(mapping: requestMapping, objectClass: NSDictionary.self, rootKeyPath: nil, method: RKRequestMethod.POST)
        manager?.addRequestDescriptor(requestDescriptor)
        
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.POST, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(streamResponseDescriptor)
        
        manager?.post(data, path: path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.create(data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let stream = mappingResult?.dictionary()["data"] as! Stream
                success(stream)
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }
    
    func createWithFile(_ filename: String, fileData: Data, data: NSDictionary, success: @escaping (_ stream: Stream) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/create"
        
        let requestMapping  = StreamMappingProvider.createStreamRequestMapping()
        let streamMapping   = StreamMappingProvider.streamResponseMapping()
        
        let requestDescriptor = RKRequestDescriptor(mapping: requestMapping, objectClass: NSDictionary.self, rootKeyPath: nil, method: RKRequestMethod.POST)
        manager?.addRequestDescriptor(requestDescriptor)
        
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.POST, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(streamResponseDescriptor)
        
        let request =
            manager?.multipartFormRequest(with: data, method: RKRequestMethod.POST, path: path, parameters: self.sessionParams()) { (formData) -> Void in
                formData?.appendPart(withFileData: fileData, name: "image", fileName: filename, mimeType: "image/jpeg")
        }
        
        let operation = manager?.objectRequestOperation(with: request as URLRequest?, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.createWithFile(filename, fileData: fileData, data: data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let stream = mappingResult?.dictionary()["data"] as! Stream
                success(stream)
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
        
        manager?.enqueue(operation)
    }
    
    func close(_ streamId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/close"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.close(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }
    
    func delete(_ streamId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/delete"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.delete(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }

    func join(_ streamId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/join"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.join(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
    }
    
    func leave(_ streamId: UInt, likes: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/leave"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        params!["likes"] = likes
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.leave(streamId, likes: likes, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
    }
    
    func viewers(_ data: NSDictionary, success: @escaping (_ likes: UInt, _ viewers: UInt, _ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let streamId = data["streamId"] as! UInt
        let path = ("stream/viewers" as NSString).appendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.viewersResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(streamResponseDescriptor)
        
        var params = self.sessionParams()
        if let page: UInt = (data["p"] as? UInt) {
            params!["p"] = page
        }
        
        manager?.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.viewers(data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                let data = mappingResult?.dictionary()["data"] as! NSDictionary
                let likes: UInt     = data["likes"] as! UInt
                let viewers: UInt   = data["viewers"] as! UInt
                let users:[User]    = data["users"] as! [User]
                success(likes, viewers, users)
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
    }
    
    func replayViewers(_ data: NSDictionary, success: @escaping (_ likes: UInt, _ viewers: UInt, _ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let streamId = data["streamId"] as! UInt
        let path = ("stream/rviewers" as NSString).appendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.viewersResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(streamResponseDescriptor)
        
        var params = self.sessionParams()
        if let page: UInt = (data["p"] as? UInt) {
            params!["p"] = page
        }
        
        manager?.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.replayViewers(data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                let data = mappingResult?.dictionary()["data"] as! NSDictionary
                let likes: UInt     = data["likes"] as! UInt
                let viewers: UInt   = data["viewers"] as! UInt
                let users:[User]    = data["users"] as! [User]
                success(likes, viewers, users)
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
    }
    
    func get(_ streamId: UInt, success: @escaping (_ stream: Stream) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = ("stream" as NSString).appendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(streamResponseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.get(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let stream = mappingResult?.dictionary()["data"] as! Stream
                success(stream)
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
    }
    
    func report(_ streamId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/report"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.report(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
    }
    
    func share(_ streamId: UInt, usersId: [UInt]?, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/share"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        if let users = usersId {
            params!["users"] = users
        }
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.share(streamId, usersId: usersId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
    }
    
    func ping(_ streamId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/ping"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.ping(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
        
        
    }
    
    func payment(_ ppid: String, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/payment"
        
        var params = self.sessionParams()
        params!["ppid"] = ppid
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.payment(ppid, success: success, failure: failure)
                        }, failure: { () -> () in
                            failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
    }
    
    func cities(_ success: @escaping (_ cities: [String]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/cities"
        
        let mapping = StreamMappingProvider.cityResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: mapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.cities", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(responseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.cities(success, failure: failure)
                        }, failure: { () -> () in
                            failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let cs = mappingResult?.dictionary()["data.cities"] as! [NSDictionary]
                var cities: [String] = []
                for c in cs {
                    cities.append(c["name"] as! String)
                }
                success(cities)
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
        
    }
}
