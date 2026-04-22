//  LoginViewModelTests.swift

import XCTest
import Factory
import CoreAuth
@testable import Authentication

final class LoginViewModelTests: XCTestCase {

    var viewModel: LoginViewModel!
    var mockAuthService: MockAuthServiceForLogin!
    var mockDelegate: MockLoginDelegate!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthServiceForLogin()
        Container.shared.authService.register { self.mockAuthService }
        viewModel = LoginViewModel()
        mockDelegate = MockLoginDelegate()
        viewModel.delegate = mockDelegate
    }

    override func tearDown() {
        super.tearDown()
        Container.shared.authService.reset()
        viewModel = nil
        mockAuthService = nil
        mockDelegate = nil
    }

    // MARK: - Empty Password Tests

    func test_login_emptyPassword_setsIsError() {
        viewModel.password = ""

        viewModel.login()

        XCTAssertTrue(viewModel.isError)
    }

    func test_login_emptyPassword_incrementsShakeAttempts() {
        viewModel.password = ""

        viewModel.login()

        XCTAssertEqual(viewModel.shakeAttempts, 1)
    }

    func test_login_emptyPassword_doesNotCallAuthService() {
        viewModel.password = ""

        viewModel.login()

        XCTAssertEqual(mockAuthService.loginCallCount, 0)
    }

    func test_login_emptyPassword_doesNotSetIsLoading() {
        viewModel.password = ""

        viewModel.login()

        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Wrong Password Tests

    func test_login_wrongPassword_setsIsError() {
        mockAuthService.loginReturn = false
        viewModel.password = "wrongpassword"

        viewModel.login()

        XCTAssertTrue(viewModel.isError)
    }

    func test_login_wrongPassword_incrementsShakeAttempts() {
        mockAuthService.loginReturn = false
        viewModel.password = "wrongpassword"

        viewModel.login()

        XCTAssertEqual(viewModel.shakeAttempts, 1)
    }

    func test_login_wrongPassword_resetsIsLoading() {
        mockAuthService.loginReturn = false
        viewModel.password = "wrongpassword"

        viewModel.login()

        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Correct Password Tests

    func test_login_correctPassword_callsDelegate() {
        mockAuthService.loginReturn = true
        viewModel.password = "correctpassword"

        viewModel.login()

        XCTAssertEqual(mockDelegate.loginDidSucceedCallCount, 1)
    }

    func test_login_correctPassword_setsIsLoading() {
        mockAuthService.loginReturn = true
        viewModel.password = "correctpassword"

        viewModel.login()

        XCTAssertTrue(viewModel.isLoading)
    }

    func test_login_correctPassword_doesNotSetError() {
        mockAuthService.loginReturn = true
        viewModel.password = "correctpassword"

        viewModel.login()

        XCTAssertFalse(viewModel.isError)
        XCTAssertEqual(viewModel.shakeAttempts, 0)
    }

    // MARK: - Multiple Attempts Tests

    func test_login_multipleWrongAttempts_shakeIncrementsEachTime() {
        mockAuthService.loginReturn = false
        viewModel.password = "wrongpassword"

        viewModel.login()
        viewModel.login()
        viewModel.login()

        XCTAssertEqual(viewModel.shakeAttempts, 3)
        XCTAssertEqual(mockAuthService.loginCallCount, 3)
    }

    // MARK: - No Delegate Tests

    func test_login_noDelegate_doesNotCrash() {
        viewModel.delegate = nil
        mockAuthService.loginReturn = true
        viewModel.password = "correctpassword"

        viewModel.login()

        XCTAssertTrue(viewModel.isLoading)
        XCTAssertEqual(mockAuthService.loginCallCount, 1)
    }
}

// MARK: - MockAuthServiceForLogin

final class MockAuthServiceForLogin: AuthServiceProtocol, @unchecked Sendable {

    var loginCallCount = 0
    var capturedPassword: String?
    var loginReturn: Bool = false

    var isLoggedIn: Bool = false

    func hasCredentials() -> Bool { false }

    func login(password: String) -> Bool {
        loginCallCount += 1
        capturedPassword = password
        return loginReturn
    }

    func saveCredentials(password: String) throws {}

    func logout() {}
}

// MARK: - MockLoginDelegate

final class MockLoginDelegate: LoginNavigationDelegate {

    var loginDidSucceedCallCount = 0

    func loginDidSucceed() {
        loginDidSucceedCallCount += 1
    }
}
