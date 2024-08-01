import Foundation
import CloudKit

class UserProfileManager {
    static let shared = UserProfileManager()
    private let database: CKDatabase
    private var userProfilesCache = NSCache<NSString, CKRecord>()

    private init() {
        let container = CKContainer(identifier: "iCloud.FainalTest")
        database = container.privateCloudDatabase
    }

    // Fetches a user profile and returns a String nickname or nil
    func fetchUserProfile(completion: @escaping (Result<String?, Error>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        performQuery(query) { result in
            completion(result.map { $0.first?["nickname"] as? String })
        }
    }
    
    // Fetches a user profile by nickname and handles caching
    func fetchUserProfileByNickname(nickname: String, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        if nickname.isEmpty {
            completion(.failure(NSError(domain: "UserProfileError", code: 1005, userInfo: [NSLocalizedDescriptionKey: "The nickname cannot be empty."])))
            return
        }

        let cacheKey = NSString(string: nickname)
        if let cachedRecord = userProfilesCache.object(forKey: cacheKey) {
            completion(.success(cachedRecord))
            return
        }

        let predicate = NSPredicate(format: "nickname == %@", nickname)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        performQuery(query) { [weak self] result in
            switch result {
            case .success(let records):
                if let record = records.first {
                    self?.userProfilesCache.setObject(record, forKey: cacheKey)
                    completion(.success(record))
                } else {
                    completion(.failure(NSError(domain: "UserProfileError", code: 1004, userInfo: [NSLocalizedDescriptionKey: "No user profile found for the given nickname."])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // Creates a new user profile if one doesn't exist
    func createUserProfile(nickname: String, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchUserProfileByNickname(nickname: nickname) { [weak self] result in
            switch result {
            case .success(_):
                completion(.failure(NSError(domain: "UserProfileError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "User already exists"])))
            case .failure(_):
                self?.saveNewUserProfile(nickname: nickname, completion: completion)
            }
        }
    }
    
    // Saves a new user profile to CloudKit
    private func saveNewUserProfile(nickname: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let record = CKRecord(recordType: "UserProfile")
        record["nickname"] = nickname
        
        database.save(record) { [weak self] _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    self?.userProfilesCache.setObject(record, forKey: NSString(string: nickname))
                    completion(.success(()))
                }
            }
        }
    }

    // Generic query execution method
    private func performQuery(_ query: CKQuery, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(records ?? []))
                }
            }
        }
    }
    
    // Deletes a user profile if it exists
    func deleteUserProfile(nickname: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let predicate = NSPredicate(format: "nickname == %@", nickname)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)

        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let recordsToDelete = records, !recordsToDelete.isEmpty else {
                    completion(.failure(NSError(domain: "UserProfileError", code: 1003, userInfo: [NSLocalizedDescriptionKey: "No matching user profile found."])))
                    return
                }

                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordsToDelete.map { $0.recordID })
                operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            // Optionally handle post-deletion logic, such as deleting associated data
                            completion(.success(()))
                        }
                    }
                }
                self?.database.add(operation)
            }
        }
    }
}
