import ProjectDescription

public extension TargetScript {

    /// Runs SwiftLint as a pre-compilation build phase.
    /// Shows a warning if SwiftLint is not installed instead of failing the build.
    static var swiftLint: TargetScript {
        .pre(
            script: """
            export PATH="$PATH:/opt/homebrew/bin"
            if which swiftlint > /dev/null; then
                swiftlint --config "${SRCROOT}/../../../.swiftlint.yml"
            else
                echo "warning: SwiftLint not installed — run: brew install swiftlint"
            fi
            """,
            name: "SwiftLint",
            basedOnDependencyAnalysis: false
        )
    }
}
