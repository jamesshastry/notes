//
//  FirebaseStorageManager.swift
//  NotesIOSApp
//
//  Created on 2025-01-01.
//

import Foundation
import FirebaseStorage
import UIKit
import UniformTypeIdentifiers

class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    
    private let storage = Storage.storage()
    private var storageRef: StorageReference {
        storage.reference()
    }
    
    private init() {}
    
    // MARK: - Upload Operations
    
    func uploadFile(data: Data, userId: String, fileName: String, contentType: String) async throws -> Attachment {
        let fileExtension = (fileName as NSString).pathExtension
        let uniqueFileName = "\(Date().timeIntervalSince1970)-\(UUID().uuidString).\(fileExtension)"
        let filePath = "notes/\(userId)/\(uniqueFileName)"
        
        let fileRef = storageRef.child(filePath)
        
        // Set metadata
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        // Upload the file
        let _ = try await fileRef.putDataAsync(data, metadata: metadata)
        
        // Get download URL
        let downloadURL = try await fileRef.downloadURL()
        
        return Attachment(
            name: fileName,
            path: filePath,
            size: Int64(data.count),
            type: contentType,
            url: downloadURL.absoluteString
        )
    }
    
    func uploadImage(image: UIImage, userId: String, fileName: String) async throws -> Attachment {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.imageConversionFailed
        }
        
        return try await uploadFile(
            data: imageData,
            userId: userId,
            fileName: fileName,
            contentType: "image/jpeg"
        )
    }
    
    // MARK: - Download Operations
    
    func downloadFile(path: String) async throws -> Data {
        let fileRef = storageRef.child(path)
        
        // Download the file
        let data = try await fileRef.data(maxSize: 50 * 1024 * 1024) // 50MB max
        
        return data
    }
    
    func getDownloadURL(path: String) async throws -> URL {
        let fileRef = storageRef.child(path)
        return try await fileRef.downloadURL()
    }
    
    // MARK: - Delete Operations
    
    func deleteFile(path: String) async throws {
        let fileRef = storageRef.child(path)
        try await fileRef.delete()
    }
    
    func deleteFiles(paths: [String]) async throws {
        for path in paths {
            do {
                try await deleteFile(path: path)
            } catch {
                print("⚠️ Failed to delete file at path: \(path), error: \(error.localizedDescription)")
                // Continue deleting other files even if one fails
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func getContentType(for fileName: String) -> String {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        
        // Use UTType for better type detection
        if let utType = UTType(filenameExtension: fileExtension) {
            return utType.preferredMIMEType ?? "application/octet-stream"
        }
        
        // Fallback to manual mapping
        switch fileExtension {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "pdf":
            return "application/pdf"
        case "txt":
            return "text/plain"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "zip":
            return "application/zip"
        default:
            return "application/octet-stream"
        }
    }
    
    func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

enum StorageError: LocalizedError {
    case imageConversionFailed
    case uploadFailed
    case downloadFailed
    case deletionFailed
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image to data"
        case .uploadFailed:
            return "Failed to upload file to storage"
        case .downloadFailed:
            return "Failed to download file from storage"
        case .deletionFailed:
            return "Failed to delete file from storage"
        }
    }
}

