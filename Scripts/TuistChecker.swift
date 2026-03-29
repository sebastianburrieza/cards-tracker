#!/usr/bin/env swift

import Foundation

// MARK: - Models

struct ValidationResult {
    let success: Bool
    let warnings: [String]
    let errors: [String]
    let output: String
    let timedOut: Bool
}

// MARK: - Tuist Checker

class TuistChecker{
    let projectPath: String
    let timeoutSeconds: Int

    init(projectPath: String, timeoutSeconds: Int = 180) {
        self.projectPath = projectPath
        self.timeoutSeconds = timeoutSeconds
    }

    /// Obtiene la versión de tuist
    func getTuistVersion() -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["tuist", "version"]
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        task.environment = ProcessInfo.processInfo.environment

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            let lines = output.components(separatedBy: .newlines)
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.range(of: #"^\d+\.\d+\.\d+"#, options: .regularExpression) != nil {
                    return trimmed
                }
            }
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return "unknown"
        }
    }

    /// Ejecuta tuist generate --no-open y captura output
    func runGenerate() -> ValidationResult {
        let task = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = pipe
        task.standardError = errorPipe
        task.arguments = ["tuist", "generate", "--no-open"]
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        task.environment = ProcessInfo.processInfo.environment

        var outputData = Data()
        var errorData = Data()

        do {
            try task.run()

            let group = DispatchGroup()

            group.enter()
            DispatchQueue.global().async {
                outputData = pipe.fileHandleForReading.readDataToEndOfFile()
                group.leave()
            }

            group.enter()
            DispatchQueue.global().async {
                errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                group.leave()
            }

            let result = group.wait(timeout: .now() + .seconds(timeoutSeconds))

            if result == .timedOut {
                task.terminate()
                return ValidationResult(
                    success: false,
                    warnings: [],
                    errors: ["tuist generate exceeded timeout of \(timeoutSeconds) seconds"],
                    output: "",
                    timedOut: true
                )
            }

            task.waitUntilExit()

            let output = String(data: outputData, encoding: .utf8) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            let fullOutput = output + "\n" + errorOutput

            let (warnings, errors) = parseOutput(fullOutput)

            return ValidationResult(
                success: task.terminationStatus == 0 && warnings.isEmpty && errors.isEmpty,
                warnings: warnings,
                errors: errors,
                output: fullOutput,
                timedOut: false
            )
        } catch {
            return ValidationResult(
                success: false,
                warnings: [],
                errors: ["Failed to execute tuist: \(error)"],
                output: "",
                timedOut: false
            )
        }
    }

    /// Ejecuta tuist inspect implicit-imports
    func runInspectImplicitImports() -> ValidationResult {
        let task = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = pipe
        task.standardError = errorPipe
        task.arguments = ["tuist", "inspect", "implicit-imports"]
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.currentDirectoryURL = URL(fileURLWithPath: projectPath)
        task.environment = ProcessInfo.processInfo.environment

        do {
            try task.run()
            task.waitUntilExit()

            let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

            let output = String(data: outputData, encoding: .utf8) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            let fullOutput = output + "\n" + errorOutput

            let success = task.terminationStatus == 0

            var errors: [String] = []
            if !success {
                if fullOutput.contains("unexpected arguments") && fullOutput.contains("inspect") {
                    return ValidationResult(
                        success: true,
                        warnings: ["tuist inspect not supported in this version - skipping check"],
                        errors: [],
                        output: fullOutput,
                        timedOut: false
                    )
                }

                let lines = fullOutput.components(separatedBy: .newlines)
                for line in lines {
                    if line.contains("implicitly depends on:") {
                        var cleanedLine = line.trimmingCharacters(in: .whitespaces)
                        if cleanedLine.hasPrefix("- ") {
                            cleanedLine = String(cleanedLine.dropFirst(2))
                        }
                        errors.append(cleanedLine)
                    }
                }
            }

            return ValidationResult(
                success: success,
                warnings: [],
                errors: errors,
                output: fullOutput,
                timedOut: false
            )
        } catch {
            return ValidationResult(
                success: false,
                warnings: [],
                errors: ["Failed to execute tuist inspect: \(error)"],
                output: "",
                timedOut: false
            )
        }
    }

    /// Parsea output buscando warnings/errors
    private func parseOutput(_ output: String) -> (warnings: [String], errors: [String]) {
        var warnings: [String] = []
        var errors: [String] = []

        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            let lowercasedLine = line.lowercased()
            if lowercasedLine.contains("warning:") {
                warnings.append(line.trimmingCharacters(in: .whitespaces))
            } else if lowercasedLine.contains("error:") {
                errors.append(line.trimmingCharacters(in: .whitespaces))
            }
        }

        return (warnings, errors)
    }
}

// MARK: - Reporter

class Reporter {
    let isQuiet: Bool
    let isVerbose: Bool

    init(isQuiet: Bool = false, isVerbose: Bool = false) {
        self.isQuiet = isQuiet
        self.isVerbose = isVerbose
    }

    func printHeader() {
        guard !isQuiet else { return }
        print("")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("    TUIST CHECKER - CardsTracker")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")
    }

    func printProgress(_ step: String) {
        guard !isQuiet else { return }
        print("🔨 \(step)...")
        print("")
    }

    func printResult(_ result: ValidationResult, step: String) {
        if result.success && isQuiet { return }

        if !result.success {
            print("")
            print("  ✗ \(step) found issues:")
            print("")

            if result.timedOut {
                print("    Timeout: command exceeded time limit")
                print("")
            }

            if !result.warnings.isEmpty {
                print("    Warnings (\(result.warnings.count)):")
                for warning in result.warnings.prefix(10) {
                    print("      - \(warning)")
                }
                if result.warnings.count > 10 {
                    print("      ... and \(result.warnings.count - 10) more warnings")
                }
                print("")
            }

            if !result.errors.isEmpty {
                print("    Errors (\(result.errors.count)):")
                for error in result.errors.prefix(10) {
                    print("      - \(error)")
                }
                if result.errors.count > 10 {
                    print("      ... and \(result.errors.count - 10) more errors")
                }
                print("")

                if step.contains("Implicit-Imports") {
                    print("    💡 To fix implicit dependencies:")
                    print("       Add the missing module to the dependencies array in the affected Project.swift.")
                    print("       Example: Dependency.utilities (see Dependency enum in ProjectDescriptionHelpers).")
                    print("")
                }
            }

            let isImplicitImportsError = step.contains("Implicit-Imports") && !result.errors.isEmpty
            if isVerbose && !result.output.isEmpty && !isImplicitImportsError {
                print("    📋 Tuist output:")
                print("    ─────────────────────────────────────────")
                for line in result.output.components(separatedBy: .newlines) {
                    if !line.isEmpty { print("    \(line)") }
                }
                print("    ─────────────────────────────────────────")
                print("")
            }
        }
    }
}

// MARK: - Help

func printHelp() {
    print("""
    Tuist Checker - CardsTracker
    Validates tuist generate and checks for implicit dependencies.

    USAGE:
        ./TuistChecker.swift [OPTIONS]

    OPTIONS:
        --path <dir>      Path to the project directory (default: current directory)
        --quiet           Minimal output, only show problems
        --verbose         Show full tuist output when validation fails
        --skip-generate   Skip tuist generate, only run implicit-imports check
        --help            Show this help

    EXAMPLES:
        ./TuistChecker.swift
        ./TuistChecker.swift --verbose
        ./TuistChecker.swift --path /path/to/project
        ./TuistChecker.swift --skip-generate

    CHECKS (run sequentially):
        1. tuist generate --no-open  (timeout: 3 minutes)
        2. tuist inspect implicit-imports  (only if generate succeeds)

    EXIT CODES:
        0 — All checks passed
        1 — One or more checks failed
    """)
}

// MARK: - Main

func main() {
    let args = CommandLine.arguments

    if args.contains("--help") || args.contains("-h") {
        printHelp()
        return
    }

    let isQuiet = args.contains("--quiet")
    let isVerbose = args.contains("--verbose")
    let skipGenerate = args.contains("--skip-generate")

    var projectPath = FileManager.default.currentDirectoryPath
    if let pathIndex = args.firstIndex(of: "--path") {
        let nextIndex = pathIndex + 1
        if nextIndex < args.count {
            projectPath = args[nextIndex]
        }
    }

    let validator = TuistChecker(projectPath: projectPath, timeoutSeconds: 180)
    let reporter = Reporter(isQuiet: isQuiet, isVerbose: isVerbose)

    reporter.printHeader()

    let tuistVersion = validator.getTuistVersion()
    print("📦 Using tuist version: \(tuistVersion)")
    if !isQuiet { print("") }

    let generateResult: ValidationResult
    let inspectResult: ValidationResult

    if skipGenerate {
        generateResult = ValidationResult(success: true, warnings: [], errors: [], output: "Skipped", timedOut: false)
        reporter.printProgress("Running tuist inspect implicit-imports (generate skipped)")
        inspectResult = validator.runInspectImplicitImports()
    } else {
        reporter.printProgress("Running tuist generate --no-open")
        generateResult = validator.runGenerate()

        if generateResult.success {
            reporter.printProgress("Running tuist inspect implicit-imports")
            inspectResult = validator.runInspectImplicitImports()
        } else {
            inspectResult = ValidationResult(
                success: false,
                warnings: [],
                errors: ["Skipped due to generate failure"],
                output: "",
                timedOut: false
            )
        }
    }

    if !skipGenerate { reporter.printResult(generateResult, step: "Tuist Generate") }
    reporter.printResult(inspectResult, step: "Tuist Inspect Implicit-Imports")

    let overallSuccess = generateResult.success && inspectResult.success

    if !isQuiet {
        print("")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("    OVERALL SUMMARY")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")
        if !skipGenerate {
            print("Generate:  \(generateResult.success ? "✓ PASSED" : "✗ FAILED")")
        } else {
            print("Generate:  ⏭ SKIPPED")
        }
        print("Inspect:   \(inspectResult.success ? "✓ PASSED" : "✗ FAILED")")
        print("")
        print(overallSuccess ? "✓ All checks passed" : "✗ Some checks failed")
        print("")
    } else if !overallSuccess {
        print("✗ Tuist validation failed")
    }

    exit(overallSuccess ? 0 : 1)
}

main()
