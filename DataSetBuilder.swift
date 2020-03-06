//
//  DataSetBuilder.swift
//
//  Created by Paul Anguiano on 3/4/20.
//  Copyright © 2020 Gentle Works.
//  Distributed under MIT license, usage is granted freely under those terms (see included LICENSE file).
//  
//  This is not a complete class; merely a static function for one way that you could use the associated
//  CSVDataImporter() to deserialize into an object array.  Although the function was taken from working
//  code, it has not been tested since it was genericized and scrubbed for sharing, so typos may exist.
//  As always, use at your own risk.  :)
//

class DataSetBuilder {

    static func loadEventData() -> [MyDataObject]{
        var dataset = [MyDataObject]()

        let csvData = CSVDataImporter()
        //This matches the types that you want to import, so the data can be parsed into the right values/objects
        let dataColumnType:[String] = ["Int","String","String","String","NSDate","NSDate","String","String","String","String"]
        
        let stringURL = "http://www.mydatasource.org/please/change/this/source.csv"
        guard let stringData = csvData.readStringFromURL(stringURL: stringURL) else {
            print("No csv data items found for import")
            os_log("No csv data items found for Import.", log: OSLog.default, type: .debug)
            return dataset
        }
        let theData = csvData.convertCSV(stringData: stringData, columnType: eventColumnType)

        for index in 1..<theData.count{
            let row = theData[index]
            if (row.isEmpty ) { //sanity check
                continue
            }
            //marshall data so it doesn't crash if something's missing
            //(the rows with else {continue} are those expected to be required by the object init to return a valid object.)
            guard let id = row["ID"] as? Int else {continue}
            guard let name = row["Name"] as? String else {continue}
            let descript = row["Description"] as? String
            guard let category = row["Category"] as? String else {continue}
            guard let startTime = row["Start Date/Time"] as? Date else {continue}
            guard let endTime = row["End Date/Time"] as? Date else {continue}
            let room = row["Location"] as? String
            let people = row["Participants"] as? String
            
            //despite the above checks, the model init might be failable, so must be guarded
            if let newDataObject = MyDataObject(id: id, name: name, descript: descript, category: category, startTime: startTime, endTime: endTime, room: room, people: people) {
                //add new data to array
                dataset += [newDataObject]
            }
        }
    }
}
