//
//  ApiHandler.swift
//
//  Created by Hardik Hadwani on 19/06/18.
//  Copyright © 2018 Hardik Hadwani. All rights reserved.
// Copyright © 2018 Hardik. All rights reserved.
//

import Foundation
import MobileCoreServices
let BaseURL  = ""//TODO:Add You Base URL Here
class ApiHandler: NSObject {

    static func GetAPI(apiURL :String,apiName :String,parameters:Dict = ["":"" as AnyObject],withWalletId:Bool = true,postCompleted: @escaping ResponseAsDict)
    {

        var items = [URLQueryItem]()
        for (key,value) in parameters {
            items.append(URLQueryItem(name: key, value: value as? String))
        }
        var url = "\(apiURL)\(apiName)"
        let urlComp =   NSURLComponents(string: "\(url)")!
        items = items.filter{!$0.name.isEmpty}
        if !items.isEmpty {
            urlComp.queryItems = items
        }
        var request = URLRequest(url: urlComp.url!)
        request.httpMethod = "GET"// Compose a query string
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                postCompleted(false, ["error":error!.localizedDescription as AnyObject])
                return
            }
            else{
                //Let's convert response sent from a server side script to a NSDictionary object:
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    if let status = json["status"]{
                        if(status as! Bool == false){
                            if let error = json["error"]{
                                postCompleted(false, ["error":error as AnyObject])
                                return
                            }else{
                                postCompleted(false, ["error":"There is some problem in connecting the API. Please try after some time." as AnyObject]);
                                return
                            }
                        }else{
                            postCompleted(true, json)
                            return
                        }
                    }
                    else {
                        if let data = json["data"]{
                            postCompleted(true, ["data" : data])
                        }
                        else if let data = json["results"]{
                            postCompleted(true, data as! Dict)
                        }
                        else if json.count > 0 {
                            postCompleted(true, json)
                        }
                        else{
                            postCompleted(false, ["error":"There is some problem in connecting the API. Please try after some time." as AnyObject]);
                            return
                        }
                    }
                } catch {
                    print(error)
                    postCompleted(false, ["error":"There is some problem in connecting the API. Please try after some time." as AnyObject])
                }
            }
        }
        task.resume()
    }
    static func PostAPI(apiName :String,parameters:Dict,postCompleted: @escaping ResponseAsDict )
    {
        guard let serviceUrl = URL(string: "\(BaseURL)\(apiName)") else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if error != nil{
                postCompleted(false, ["error":error!.localizedDescription as AnyObject])
                return
            }
            else{
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
                        if(json["status"] as! Bool == false){
                            if let error = json["error"]{
                                postCompleted(false, ["error":error as AnyObject])
                                return
                            }else{
                                postCompleted(false, ["error":"There is some problem in connecting the API. Please try after some time." as AnyObject]);return}
                            
                        }else{
                            postCompleted(true, json)
                            return
                        }
                    }catch {
                        print(error)
                        postCompleted(false, ["error":error.localizedDescription as AnyObject])
                        return;
                    }
                }
            }
            }.resume()
    }
   
}
