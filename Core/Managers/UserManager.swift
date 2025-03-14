//
//  UserManager.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 11/12/24.
//

import Foundation
import Combine
import LocalAuthentication
import AuthenticationServices

enum AuthenticationError: Error {
    case invalidCredentials
    case networkError
    case serverError
    case userExists
    case userNotFound
    case biometricFailure
    case biometricNotAvailable
    case tokenExpired
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "The email or password you entered is incorrect."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .serverError:
            return "Server error. Please try again later."
        case .userExists:
            return "User with this email already exists."
        case .userNotFound:
            return "User not found."
        case .biometricFailure:
            return "Biometric authentication failed."
        case .biometricNotAvailable:
            return "Biometric authentication is not available on this device."
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

class UserManager: ObservableObject {
    // MARK: - Singleton
    
    static let shared = UserManager()
    
    // MARK: - Published Properties
    
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var authError: AuthenticationError?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService.shared
    private let secureKeyManager = SecureKeyManager.shared
    
    // MARK: - Initialization
    
    private init() {
        // Check if user is already authenticated
        checkAuthentication()
    }
    
    // MARK: - Authentication Methods
    
    /// Checks if the user is authenticated with valid tokens
    func checkAuthentication() {
        if secureKeyManager.isAuthenticated() && !secureKeyManager.isAccessTokenExpired() {
            // We have a valid token, try to fetch user details
            fetchCurrentUser()
        } else if secureKeyManager.isAuthenticated() && !secureKeyManager.isRefreshTokenExpired() {
            // Access token expired but refresh token is valid, try to refresh
            Task {
                await refreshAuthenticationToken()
            }
        } else {
            // No valid tokens
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
    
    /// Registers a new user with email and password
    func registerWithEmail(email: String, password: String, name: String?) async throws -> User {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Create registration parameters
            var parameters: [String: Any] = [
                "email": email,
                "password": password
            ]
            
            if let name = name {
                parameters["name"] = name
            }
            
            // Make API request
            let response: RegisterResponse = try await networkService.request(
                endpoint: .register,
                method: .post,
                parameters: parameters,
                requiresAuth: false
            )
            
            // Save tokens
            secureKeyManager.saveTokens(
                accessToken: response.tokens.accessToken,
                refreshToken: response.tokens.refreshToken
            )
            
            // Save user ID
            secureKeyManager.storeUserId(response.user.id)
            
            // Create and store user
            let user = User(
                id: response.user.id,
                email: response.user.email,
                name: response.user.name ?? "User",
                isActive: response.user.isActive,
                createdAt: response.user.createdAt
            )
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            
            return user
        } catch let error as NetworkError {
            switch error {
            case .httpError(let statusCode, _) where statusCode == 409:
                throw AuthenticationError.userExists
            case .unauthorized:
                throw AuthenticationError.invalidCredentials
            case .serverError:
                throw AuthenticationError.serverError
            case .noInternetConnection:
                throw AuthenticationError.networkError
            default:
                throw AuthenticationError.unknown
            }
        } catch {
            throw AuthenticationError.unknown
        }
    }
    
    /// Authenticates a user with email and password
    func authenticateWithEmail(email: String, password: String) async throws -> User {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Create login parameters
            let parameters: [String: Any] = [
                "email": email,
                "password": password
            ]
            
            // Make API request
            let response: LoginResponse = try await networkService.request(
                endpoint: .login,
                method: .post,
                parameters: parameters,
                requiresAuth: false
            )
            
            // Save tokens
            secureKeyManager.saveTokens(
                accessToken: response.tokens.accessToken,
                refreshToken: response.tokens.refreshToken
            )
            
            // Save user ID
            secureKeyManager.storeUserId(response.user.id)
            
            // Create and store user
            let user = User(
                id: response.user.id,
                email: response.user.email,
                name: response.user.name ?? "User",
                isActive: response.user.isActive,
                createdAt: response.user.createdAt
            )
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            
            return user
        } catch let error as NetworkError {
            switch error {
            case .unauthorized:
                throw AuthenticationError.invalidCredentials
            case .serverError:
                throw AuthenticationError.serverError
            case .noInternetConnection:
                throw AuthenticationError.networkError
            default:
                throw AuthenticationError.unknown
            }
        } catch {
            throw AuthenticationError.unknown
        }
    }
    
    /// Authenticates a user with device ID (for anonymous users)
    func authenticateWithDevice(deviceId: String) async throws -> User {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Create device auth parameters
            let parameters: [String: Any] = [
                "deviceId": deviceId
            ]
            
            // Make API request
            let response: LoginResponse = try await networkService.request(
                endpoint: .login,
                method: .post,
                parameters: parameters,
                requiresAuth: false
            )
            
            // Save tokens
            secureKeyManager.saveTokens(
                accessToken: response.tokens.accessToken,
                refreshToken: response.tokens.refreshToken
            )
            
            // Save user ID
            secureKeyManager.storeUserId(response.user.id)
            
            // Create and store user
            let user = User(
                id: response.user.id,
                email: response.user.email,
                name: response.user.name ?? "Guest",
                isActive: response.user.isActive,
                createdAt: response.user.createdAt
            )
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            
            return user
            
        }
    }
}
