//
//  CSVDataImporter.swift
//
//  Created by Paul Anguiano on 3/13/18.
//  Copyright © 2018 Gentle Works.
//  Distributed under MIT license, usage is granted freely under those terms (see included license.txt).
//  
//  Adapted from/inspired by https://makeapppie.com/2016/05/30/how-to-read-csv-files-from-the-web-in-swift/
//  with many bug fixes, updates for Swift 4, and refactoring for library use
//  plus a constants section.
//

import UIKit


class CSVDataImporter: NSObject {
    let importDateFormat = "yyyy-MM-dd HH:mm:ss"
    let importDateTimezone = "MDT"
    //let importEncoding = String.Encoding.isoLatin1
    let importEncoding = String.Encoding.windowsCP1252
    
    
    let dateFormatter = DateFormatter()

    //MARK: Initialization

    override init() {
        super.init()
        dateFormatter.dateFormat = importDateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: importDateTimezone)
   }

    func readStringFromURL(stringURL:String)-> String!{
        if let url = URL(string: stringURL) {
            do {
                return try String(contentsOf: url, encoding: importEncoding)
            } catch {
                
                print("Cannot load contents: " + error.localizedDescription)
                return nil
            }
        } else {
            print("String was not a URL")
            return nil
        }
    }
    
    func cleanRows(stringData:String)->[String]{
        var cleanFile = stringData
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        let rawrows = cleanFile.components(separatedBy: "\n")
        
        //line breaks between quotes don't count (!@#) so replace them with pipes (|)
        var newrows = [String]()
        var oldrow = ""
        for row in rawrows {
            if row.isEmpty {continue}
            if oldrow.isEmpty {
                oldrow = row
                continue
            }
            if (oldrow.components(separatedBy: "\"").count - oldrow.components(separatedBy: "\\\"").count) % 2 == 1 {
                oldrow += "|" + row
            } else {
                newrows += [oldrow]
                oldrow = row
            }
        }
        newrows += [oldrow]
        return newrows
    }
    
    //"field1","field2""with internal quote","","field4"
    //splits to field1|,|field2|with internal quote|,|,|field4
    func cleanFields(oldString: String) -> [String] {
        var out = [String]()
        let dequoted = oldString.split(separator: "\"")
        var bufferString = ""
        for s in dequoted {
            if s == "," {
                out += [bufferString]
                bufferString = ""
            } else {
                if bufferString.count>0 {
                    bufferString += "\""
                }
                bufferString += s
            }
        }
        out += [bufferString]
        return out
    }
    
    func convertCSV(stringData:String, columnType:[String]) -> [[String:AnyObject]] {
        var data:[[String:AnyObject]] = []

        let rows = cleanRows(stringData: stringData)
        if rows.count > 0 {
            let columnTitles = cleanFields(oldString: rows.first!)
            for row in rows.dropFirst(){
                let fields = cleanFields(oldString: row)
                if fields.count != columnTitles.count {continue}
                var newRow = [String:AnyObject]()
                for index in 0..<fields.count{
                    let column = columnTitles[index]
                    let field = fields[index]
                    switch columnType[index]{
                    case "Int":
                        newRow[column] = Int(field) as AnyObject
                    case "NSDate":
                        guard let newField = dateFormatter.date(from: field) else {
                            print ("\(field) didn\'t convert")
                            continue
                        }
                        newRow[column] = newField as AnyObject
                    default: //default keeps as string
                        //lots of junk in badly converted input, fix entity values and failed conversions where possible
                        newRow[column] = field.replacingOccurrences(of: "&#8216;", with: "‘").replacingOccurrences(of: "&#8217;", with: "’").replacingOccurrences(of: "&#65533;", with: "’").replacingOccurrences(of: "í", with: "'").replacingOccurrences(of: "|", with: "\n") as AnyObject
                    }
                }
                data.append(newRow)
            }
        } else {
            print("No data in file")
        }
        return data
    }
}


