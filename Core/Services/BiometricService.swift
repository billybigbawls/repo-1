//
//  BiometricService.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import LocalAuthentication

class BiometricService {
    enum BiometricType {
        case none
        case faceID
        case touchID
    }
    
    func getBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }
    
    func canUseBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        let canEvaluate = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
        
        return canEvaluate && error == nil
    }
    
    func authenticate(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        let reason = "Unlock Squad"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}
