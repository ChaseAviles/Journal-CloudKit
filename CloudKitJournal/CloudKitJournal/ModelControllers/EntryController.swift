//
//  EntryController.swift
//  CloudKitJournal
//
//  Created by Johnathan Aviles on 2/1/21.
//  Copyright © 2021 Zebadiah Watson. All rights reserved.
//

import CloudKit


class EntryController {
    static let shared = EntryController()

    var entries: [Entry] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    func createEntryWith(title: String, body: String, completion: @escaping (Result<String, CloudKitError>) -> Void) {
        let newEntry = Entry(title: title, body: body)
        save(entry: newEntry) { (result) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func save(entry: Entry, completion: @escaping (Result<String, CloudKitError>) -> Void) {
        
        let entryRecord = CKRecord.init(entry: entry)
        
        privateDB.save(entryRecord) { (record, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("======== ERROR ========")
                    print("Function: \(#function)")
                    print("Error: \(error)")
                    print(error.localizedDescription)
                    print("======== ERROR ========")
                    return completion(.failure(.ckError(error)))
                }
                
                guard let record = record,
                      let savedEntry = Entry(ckRecord: record) else { return completion(.failure(.unableToUnwrap))}
                self.entries.append(savedEntry)
                completion(.success("Successfully saved a entry."))
            }
            
        }
        
        
        
    }
    
    func fetchEntriesWith(completion: @escaping (Result<String?, CloudKitError>) -> Void) {
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: EntryConstants.recordType, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("======== ERROR ========")
                    print("Function: \(#function)")
                    print("Error: \(error)")
                    print(error.localizedDescription)
                    print("======== ERROR ========")
                    return completion(.failure(.ckError(error)))
                }
                
                guard let records = records else {return completion(.failure(.unableToUnwrap))}
                
                let fetchedHypes = records.compactMap { Entry(ckRecord: $0) }
                self.entries = fetchedHypes
                completion(.success("Successfully fetched all hypes"))
            }
        }
    }
}
