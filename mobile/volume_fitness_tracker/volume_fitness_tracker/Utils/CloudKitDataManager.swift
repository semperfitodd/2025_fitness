import Foundation
import CloudKit

// MARK: - CloudKit Data Manager for iOS and Watch Apps
class CloudKitDataManager: ObservableObject {
    static let shared = CloudKitDataManager()
    
    @Published var userEmail: String?
    @Published var userName: String?
    @Published var isUserLoggedIn: Bool = false
    @Published var lastSyncTime: Date?
    @Published var cloudKitStatus: CloudKitStatus = .unknown
    
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
        print("☁️ CloudKit: iOS app initializing - will use default container")
        #elseif os(watchOS)
        print("☁️ CloudKit: Watch app initializing - will use iOS container explicitly")
        #endif
        
        #if os(iOS)
        print("☁️ CloudKit: Initializing iOS CloudKit Data Manager")
        print("☁️ CloudKit: Container ID: \(container.containerIdentifier ?? "nil")")
        print("☁️ CloudKit: Using private database")
        print("☁️ CloudKit: Record Type: \(recordType)")
        print("☁️ CloudKit: Record ID: \(recordID.recordName)")
        #elseif os(watchOS)
        print("☁️ CloudKit: Initializing Watch App CloudKit Data Manager")
        print("☁️ CloudKit: Container ID: \(container.containerIdentifier ?? "nil")")
        print("☁️ CloudKit: Using private database")
        print("☁️ CloudKit: Record Type: \(recordType)")
        print("☁️ CloudKit: Record ID: \(recordID.recordName)")
        print("☁️ CloudKit: WATCH APP CONTAINER CHECK - NO DASH SHOULD BE HERE!")
        print("☁️ CloudKit: WATCH APP - CONTAINER ID SHOULD BE: iCloud.com.bernsonfamily.volume-fitness-tracker")
        #endif
        
        // Debug CloudKit configuration
        debugCloudKitConfiguration()
        
        // Check account status first
        checkCloudKitStatus()
    }
    
    // MARK: - Save User Data (called from iOS app only)
    func saveUserData(email: String, name: String) {
        #if os(iOS)
        print("☁️ CloudKit: Saving user data - Email: \(email), Name: \(name)")
        
        // First check if we can access CloudKit
        guard cloudKitStatus == .available else {
            print("☁️ CloudKit: Cannot save - CloudKit status: \(cloudKitStatus)")
            return
        }
        
        // Try to fetch existing record first
        privateDatabase.fetch(withRecordID: recordID) { [weak self] existingRecord, error in
            DispatchQueue.main.async {
                let record: CKRecord
                
                if let existingRecord = existingRecord {
                    // Update existing record
                    print("☁️ CloudKit: Updating existing record")
                    record = existingRecord
                } else {
                    // Create new record
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
                            print("☁️ CloudKit: Error details - Code: \((saveError as? CKError)?.code.rawValue ?? 0)")
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
        #else
        print("☁️ CloudKit: Save not available on watchOS")
        #endif
    }
    
    // MARK: - Fetch User Data (called from both apps)
    func fetchUserData() {
        #if os(iOS)
        print("☁️ CloudKit: Fetching user data...")
        #elseif os(watchOS)
        print("☁️ CloudKit: Watch app fetching user data...")
        #endif
        
        // First check if we can access CloudKit
        guard cloudKitStatus == .available else {
            #if os(iOS)
            print("☁️ CloudKit: Cannot fetch - CloudKit status: \(cloudKitStatus)")
            #elseif os(watchOS)
            print("☁️ CloudKit: Watch app - Cannot fetch - CloudKit status: \(cloudKitStatus)")
            #endif
            return
        }
        
        print("☁️ CloudKit: Attempting to fetch record with ID: \(recordID.recordName)")
        privateDatabase.fetch(withRecordID: recordID) { [weak self] record, error in
            DispatchQueue.main.async {
                if let error = error {
                    if let ckError = error as? CKError, ckError.code == .unknownItem {
                        #if os(iOS)
                        print("☁️ CloudKit: No user data found")
                        #elseif os(watchOS)
                        print("☁️ CloudKit: Watch app - No user data found")
                        print("☁️ CloudKit: Watch app - Error code: \(ckError.code.rawValue)")
                        print("☁️ CloudKit: Watch app - Error description: \(ckError.localizedDescription)")
                        #endif
                        self?.userEmail = nil
                        self?.userName = nil
                        self?.isUserLoggedIn = false
                    } else {
                        #if os(iOS)
                        print("☁️ CloudKit: Failed to fetch user data: \(error)")
                        #elseif os(watchOS)
                        print("☁️ CloudKit: Watch app - Failed to fetch user data: \(error)")
                        if let ckError = error as? CKError {
                            print("☁️ CloudKit: Watch app - Error code: \(ckError.code.rawValue)")
                            print("☁️ CloudKit: Watch app - Error description: \(ckError.localizedDescription)")
                        }
                        #endif
                    }
                } else if let record = record {
                    let email = record["email"] as? String
                    let name = record["name"] as? String
                    let lastUpdated = record["lastUpdated"] as? Date
                    
                    #if os(iOS)
                    print("☁️ CloudKit: Fetched user data - Email: \(email ?? "nil"), Name: \(name ?? "nil")")
                    #elseif os(watchOS)
                    print("☁️ CloudKit: Watch app - Fetched user data - Email: \(email ?? "nil"), Name: \(name ?? "nil")")
                    print("☁️ CloudKit: Watch app - Record ID: \(record.recordID.recordName)")
                    print("☁️ CloudKit: Watch app - Record type: \(record.recordType)")
                    #endif
                    
                    self?.userEmail = email
                    self?.userName = name
                    self?.isUserLoggedIn = email != nil && !email!.isEmpty
                    self?.lastSyncTime = lastUpdated
                }
            }
        }
    }
    
    // MARK: - Clear User Data (called on sign out)
    func clearUserData() {
        #if os(iOS)
        print("☁️ CloudKit: Clearing user data...")
        #elseif os(watchOS)
        print("☁️ CloudKit: Watch app - Clearing user data...")
        #endif
        
        // Try to clear from CloudKit
        guard cloudKitStatus == .available else {
            #if os(iOS)
            print("☁️ CloudKit: Cannot clear - CloudKit status: \(cloudKitStatus)")
            #elseif os(watchOS)
            print("☁️ CloudKit: Watch app - Cannot clear - CloudKit status: \(cloudKitStatus)")
            #endif
            return
        }
        
        privateDatabase.delete(withRecordID: recordID) { [weak self] recordID, error in
            DispatchQueue.main.async {
                if let error = error {
                    #if os(iOS)
                    print("☁️ CloudKit: Failed to clear user data: \(error)")
                    #elseif os(watchOS)
                    print("☁️ CloudKit: Watch app - Failed to clear user data: \(error)")
                    #endif
                } else {
                    #if os(iOS)
                    print("☁️ CloudKit: Successfully cleared user data")
                    #elseif os(watchOS)
                    print("☁️ CloudKit: Watch app - Successfully cleared user data")
                    #endif
                }
                self?.userEmail = nil
                self?.userName = nil
                self?.isUserLoggedIn = false
                self?.lastSyncTime = nil
            }
        }
    }
    
    // MARK: - Monitor Changes
    private func startMonitoringChanges() {
        print("☁️ CloudKit: Starting change monitoring...")
        
        // Set up subscription for changes
        let subscription = CKQuerySubscription(
            recordType: recordType,
            predicate: NSPredicate(value: true),
            subscriptionID: "userDataChanges",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        subscription.notificationInfo = notification
        
        privateDatabase.save(subscription) { _, error in
            if let error = error {
                print("☁️ CloudKit: Failed to save subscription: \(error)")
            } else {
                print("☁️ CloudKit: Successfully saved subscription")
            }
        }
    }
    
    // MARK: - Debug CloudKit Configuration
    func debugCloudKitConfiguration() {
        #if os(iOS)
        print("☁️ CloudKit: iOS App Debug Info:")
        #elseif os(watchOS)
        print("☁️ CloudKit: Watch App Debug Info:")
        #endif
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
                    #if os(iOS)
                    print("☁️ CloudKit: Account status error: \(error)")
                    #elseif os(watchOS)
                    print("☁️ CloudKit: Watch app - Account status error: \(error)")
                    #endif
                    self?.cloudKitStatus = .couldNotDetermine
                } else {
                    switch accountStatus {
                    case .available:
                        #if os(iOS)
                        print("☁️ CloudKit: Account available")
                        #elseif os(watchOS)
                        print("☁️ CloudKit: Watch app - Account available")
                        #endif
                        self?.cloudKitStatus = .available
                        self?.fetchUserData()
                    case .noAccount:
                        #if os(iOS)
                        print("☁️ CloudKit: No iCloud account")
                        #elseif os(watchOS)
                        print("☁️ CloudKit: Watch app - No iCloud account")
                        #endif
                        self?.cloudKitStatus = .noAccount
                    case .restricted:
                        #if os(iOS)
                        print("☁️ CloudKit: Account restricted")
                        #elseif os(watchOS)
                        print("☁️ CloudKit: Watch app - Account restricted")
                        #endif
                        self?.cloudKitStatus = .restricted
                    case .couldNotDetermine:
                        #if os(iOS)
                        print("☁️ CloudKit: Could not determine account status")
                        #elseif os(watchOS)
                        print("☁️ CloudKit: Watch app - Could not determine account status")
                        #endif
                        self?.cloudKitStatus = .couldNotDetermine
                    @unknown default:
                        #if os(iOS)
                        print("☁️ CloudKit: Unknown account status")
                        #elseif os(watchOS)
                        print("☁️ CloudKit: Watch app - Unknown account status")
                        #endif
                        self?.cloudKitStatus = .unknown
                    }
                }
            }
        }
    }
}
