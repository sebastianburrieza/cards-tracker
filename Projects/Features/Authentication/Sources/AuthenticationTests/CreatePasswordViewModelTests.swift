//  CreatePasswordViewModelTests.swift

import XCTest
import Factory
import CoreAuth
@testable import Authentication

final class CreatePasswordViewModelTests: XCTestCase {

    var viewModel: CreatePasswordViewModel!
    var mockAuthService: MockAuthServiceForCreatePassword!
    var mockDelegate: MockCreatePasswordDelegate!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthServiceForCreatePassword()
        Container.shared.authService.register { self.mockAuthService }
        viewModel = CreatePasswordViewModel()
        mockDelegate = MockCreatePasswordDelegate()
        viewModel.delegate = mockDelegate
    }

    override func tearDown() {
        super.tearDown()
        Container.shared.authService.reset()
        viewModel = nil
        mockAuthService = nil
        mockDelegate = nil
    }

    // MARK: - Too Short Password Tests

    func test_createPassword_tooShort_setsIsError() {
        viewModel.password = "abc"
        viewModel.confirmPassword = "abc"

        viewModel.createPassword()

        XCTAssertTrue(viewModel.isError)
    }

    func test_createPassword_tooShort_doesNotCallAuthService() {
        viewModel.password = "abc"
        viewModel.confirmPassword = "abc"

        viewModel.createPassword()

        XCTAssertEqual(mockAuthService.saveCredentialsCallCount, 0)
    }

    // MARK: - Boundary Tests

    func test_createPassword_exactlyFourChars_doesNotSetError() {
        viewModel.password = "abcd"
        viewModel.confirmPassword = "abcd"

        viewModel.createPassword()

        XCTAssertFalse(viewModel.isError)
        XCTAssertEqual(mockAuthService.saveCredentialsCallCount, 1)
    }

    // MARK: - Mismatch Tests

    func test_createPassword_mismatch_setsIsError() {
        viewModel.password = "password1"
        viewModel.confirmPassword = "password2"

        viewModel.createPassword()

        XCTAssertTrue(viewModel.isError)
    }

    func test_createPassword_mismatch_doesNotCallAuthService() {
        viewModel.password = "password1"
        viewModel.confirmPassword = "password2"

        viewModel.createPassword()

        XCTAssertEqual(mockAuthService.saveCredentialsCallCount, 0)
    }

    // MARK: - Success Tests

    func test_createPassword_success_callsDelegate() {
        viewModel.password = "securepassword"
        viewModel.confirmPassword = "securepassword"

        viewModel.createPassword()

        XCTAssertEqual(mockDelegate.passwordCreatedCallCount, 1)
    }

    func test_createPassword_success_savesCorrectPassword() {
        viewModel.password = "securepassword"
        viewModel.confirmPassword = "securepassword"

        viewModel.createPassword()

        XCTAssertEqual(mockAuthService.capturedPassword, "securepassword")
    }

    func test_createPassword_success_setsIsLoading() {
        viewModel.password = "securepassword"
        viewModel.confirmPassword = "securepassword"

        viewModel.createPassword()

        XCTAssertTrue(viewModel.isLoading)
    }

    // MARK: - Save Failure Tests

    func test_createPassword_saveFails_setsIsError() {
        mockAuthService.shouldThrow = true
        viewModel.password = "securepassword"
        viewModel.confirmPassword = "securepassword"

        viewModel.createPassword()

        XCTAssertTrue(viewModel.isError)
    }

    func test_createPassword_saveFails_resetsIsLoading() {
        mockAuthService.shouldThrow = true
        viewModel.password = "securepassword"
        viewModel.confirmPassword = "securepassword"

        viewModel.createPassword()

        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - No Delegate Tests

    func test_createPassword_noDelegate_doesNotCrash() {
        viewModel.delegate = nil
        viewModel.password = "securepassword"
        viewModel.confirmPassword = "securepassword"

        viewModel.createPassword()

        XCTAssertEqual(mockAuthService.saveCredentialsCallCount, 1)
        XCTAssertTrue(viewModel.isLoading)
    }
}

// MARK: - MockAuthServiceForCreatePassword

final class MockAuthServiceForCreatePassword: AuthServiceProtocol, @unchecked Sendable {

    var saveCredentialsCallCount = 0
    var capturedPassword: String?
    var shouldThrow: Bool = false

    var isLoggedIn: Bool = false

    func hasCredentials() -> Bool { false }

    func login(password: String) -> Bool { false }

    func saveCredentials(password: String) throws {
        saveCredentialsCallCount += 1
        capturedPassword = password
        if shouldThrow {
            throw MockSaveError.saveFailed
        }
    }

    func logout() {}
}

// MARK: - MockCreatePasswordDelegate

final class MockCreatePasswordDelegate: CreatePasswordNavigationDelegate {

    var passwordCreatedCallCount = 0

    func passwordCreated() {
        passwordCreatedCallCount += 1
    }
}

// MARK: - MockSaveError

private enum MockSaveError: Error {
    case saveFailed
}
