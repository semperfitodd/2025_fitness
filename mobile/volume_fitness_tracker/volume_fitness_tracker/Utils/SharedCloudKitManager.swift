import Foundation
import CloudKit

// MARK: - Shared CloudKit Manager for iOS and Watch Apps
// This file should be shared between iOS and watchOS targets
class SharedCloudKitManager: ObservableObject {
    static let shared = SharedCloudKitManager()
    
    @Published var userEmail: String?
    @Published var userName: String?
    @Published var isUserLoggedIn: Bool = false
    @Published var lastSyncTime: Date?
    @Published var cloudKitStatus: CloudKitStatus = .unknown
    
    // Pending save data
    private var pendingSaveEmail: String?
    private var pendingSaveName: String?
    
    var containerIdentifier: String? {
        return container.containerIdentifier
    }
    
    private var container: CKContainer {
        #if os(iOS)
        let container = CKContainer.default()
        print("☁️ CloudKit: iOS using default container: \(container.containerIdentifier ?? "nil")")
        return container
        #elseif os(watchOS)
        let container = CKContainer(identifier: "iCloud.com.bernsonfamily.volume-fitness-tracker")
        print("☁️ CloudKit: Watch using explicit container: \(container.containerIdentifier ?? "nil")")
        return container
        #endif
    }
    
    private var privateDatabase: CKDatabase {
        return container.privateCloudDatabase
    }
    
    private let recordType = "UserData"
    private let recordID = CKRecord.ID(recordName: "currentUser")
    
    enum CloudKitStatus {
        case unknown, available, noAccount, restricted, couldNotDetermine
    }
    
    private init() {
        #if os(iOS)
        print("☁️ CloudKit: iOS app initializing")
        #elseif os(watchOS)
        print("☁️ CloudKit: Watch app initializing")
        #endif
        
        debugCloudKitConfiguration()
        checkCloudKitStatus()
    }
    
    // MARK: - Save User Data (iOS only)
    func saveUserData(email: String, name: String) {
        #if os(iOS)
        print("☁️ CloudKit: Saving user data - Email: \(email), Name: \(name)")
        
        // Store the data to save for later
        pendingSaveEmail = email
        pendingSaveName = name
        
        // If CloudKit status is not available, check it first
        if cloudKitStatus != .available {
            print("☁️ CloudKit: Status not available (\(cloudKitStatus)), checking first...")
            checkCloudKitStatus()
            return
        }
        
        performSave(email: email, name: name)
        #else
        print("☁️ CloudKit: Save not available on watchOS")
        #endif
    }
    
    private func performSave(email: String, name: String) {
        guard cloudKitStatus == .available else {
            print("☁️ CloudKit: Cannot save - CloudKit status: \(cloudKitStatus)")
            return
        }
        
        privateDatabase.fetch(withRecordID: recordID) { [weak self] existingRecord, error in
            DispatchQueue.main.async {
                let record: CKRecord
                
                if let existingRecord = existingRecord {
                    print("☁️ CloudKit: Updating existing record")
                    record = existingRecord
                } else {
                    print("☁️ CloudKit: Creating new record")
                    record = CKRecord(recordType: self?.recordType ?? "UserData", recordID: self?.recordID ?? CKRecord.ID(recordName: "currentUser"))
                }
                
                record["email"] = email
                record["name"] = name
                record["lastUpdated"] = Date()
                
                self?.privateDatabase.save(record) { savedRecord, saveError in
                    DispatchQueue.main.async {
                        if let saveError = saveError {
                            print("☁️ CloudKit: Failed to save user data: \(saveError)")
                            if let ckError = saveError as? CKError {
                                print("☁️ CloudKit: CKError code: \(ckError.code.rawValue)")
                                print("☁️ CloudKit: CKError description: \(ckError.localizedDescription)")
                            }
                        } else {
                            print("☁️ CloudKit: Successfully saved user data")
                            print("☁️ CloudKit: Record saved with ID: \(savedRecord?.recordID.recordName ?? "unknown")")
                            self?.userEmail = email
                            self?.userName = name
                            self?.isUserLoggedIn = true
                            self?.lastSyncTime = Date()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Fetch User Data (both apps)
    func fetchUserData() {
        #if os(iOS)
        print("☁️ CloudKit: iOS fetching user data...")
        #elseif os(watchOS)
        print("☁️ CloudKit: Watch fetching user data...")
        #endif
        
        guard cloudKitStatus == .available else {
            print("☁️ CloudKit: Cannot fetch - CloudKit status: \(cloudKitStatus)")
            return
        }
        
        print("☁️ CloudKit: Attempting to fetch record with ID: \(recordID.recordName)")
        privateDatabase.fetch(withRecordID: recordID) { [weak self] record, error in
            DispatchQueue.main.async {
                if let error = error {
                    if let ckError = error as? CKError, ckError.code == .unknownItem {
                        print("☁️ CloudKit: No user data found")
                        print("☁️ CloudKit: Error code: \(ckError.code.rawValue)")
                        print("☁️ CloudKit: Error description: \(ckError.localizedDescription)")
                        self?.userEmail = nil
                        self?.userName = nil
                        self?.isUserLoggedIn = false
                    } else {
                        print("☁️ CloudKit: Failed to fetch user data: \(error)")
                        if let ckError = error as? CKError {
                            print("☁️ CloudKit: CKError code: \(ckError.code.rawValue)")
                            print("☁️ CloudKit: CKError description: \(ckError.localizedDescription)")
                        }
                    }
                } else if let record = record {
                    let email = record["email"] as? String
                    let name = record["name"] as? String
                    let lastUpdated = record["lastUpdated"] as? Date
                    
                    print("☁️ CloudKit: Fetched user data - Email: \(email ?? "nil"), Name: \(name ?? "nil")")
                    print("☁️ CloudKit: Record ID: \(record.recordID.recordName)")
                    print("☁️ CloudKit: Record type: \(record.recordType)")
                    
                    self?.userEmail = email
                    self?.userName = name
                    self?.isUserLoggedIn = email != nil && !email!.isEmpty
                    self?.lastSyncTime = lastUpdated
                }
            }
        }
    }
    
    // MARK: - Clear User Data (both apps)
    func clearUserData() {
        print("☁️ CloudKit: Clearing user data...")
        
        guard cloudKitStatus == .available else {
            print("☁️ CloudKit: Cannot clear - CloudKit status: \(cloudKitStatus)")
            return
        }
        
        privateDatabase.delete(withRecordID: recordID) { [weak self] recordID, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("☁️ CloudKit: Failed to clear user data: \(error)")
                } else {
                    print("☁️ CloudKit: Successfully cleared user data")
                }
                self?.userEmail = nil
                self?.userName = nil
                self?.isUserLoggedIn = false
                self?.lastSyncTime = nil
            }
        }
    }
    
    // MARK: - Debug CloudKit Configuration
    func debugCloudKitConfiguration() {
        print("☁️ CloudKit: Debug Info:")
        print("☁️ CloudKit: Container ID: \(container.containerIdentifier ?? "nil")")
        print("☁️ CloudKit: Expected Container: iCloud.com.bernsonfamily.volume-fitness-tracker")
        print("☁️ CloudKit: Container Match: \(container.containerIdentifier == "iCloud.com.bernsonfamily.volume-fitness-tracker")")
        print("☁️ CloudKit: Bundle ID: \(Bundle.main.bundleIdentifier ?? "nil")")
    }
    
    // MARK: - Check CloudKit Status
    func checkCloudKitStatus() {
        print("☁️ CloudKit: Checking account status...")
        container.accountStatus { [weak self] accountStatus, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("☁️ CloudKit: Account status error: \(error)")
                    self?.cloudKitStatus = .couldNotDetermine
                } else {
                    switch accountStatus {
                    case .available:
                        print("☁️ CloudKit: Account available")
                        self?.cloudKitStatus = .available
                        self?.fetchUserData()
                        
                        // If there's pending save data, save it now
                        if let pendingEmail = self?.pendingSaveEmail, let pendingName = self?.pendingSaveName {
                            print("☁️ CloudKit: Performing pending save for \(pendingEmail)")
                            self?.performSave(email: pendingEmail, name: pendingName)
                            self?.pendingSaveEmail = nil
                            self?.pendingSaveName = nil
                        }
                    case .noAccount:
                        print("☁️ CloudKit: No iCloud account")
                        self?.cloudKitStatus = .noAccount
                    case .restricted:
                        print("☁️ CloudKit: Account restricted")
                        self?.cloudKitStatus = .restricted
                    case .couldNotDetermine:
                        print("☁️ CloudKit: Could not determine account status")
                        self?.cloudKitStatus = .couldNotDetermine
                    @unknown default:
                        print("☁️ CloudKit: Unknown account status")
                        self?.cloudKitStatus = .unknown
                    }
                }
            }
        }
    }
}
