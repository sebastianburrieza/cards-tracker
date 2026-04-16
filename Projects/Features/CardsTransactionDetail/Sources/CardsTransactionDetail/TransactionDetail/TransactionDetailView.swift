//  TransactionDetailView.swift
//  Created by Sebastian Burrieza on 12/04/2026.

import SwiftUI
import ResourcesUI
import ComponentsUI

struct TransactionDetailView: View {

    var viewModel: TransactionDetailViewModel

    @State private var isShowing = false

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let height = geometry.size.height

                // MARK: - Shadow background

                Color.black
                    .opacity(isShowing ? 0.5 : 0)
                    .ignoresSafeArea()
                    .onTapGesture { dismissView() }

                // MARK: - Bottom sheet

                VStack {
                    Spacer()

                    dataContent
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                }
                .offset(y: isShowing ? 0 : height)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onAppear {
            withAnimation(.timingCurve(0.45, 0.25, 0.15, 1.05, duration: 0.5)) {
                isShowing = true
            }
        }
    }

    // MARK: - Data content

    @ViewBuilder
    private var dataContent: some View {
        VStack(spacing: 0) {
            // Category icon
            if let icon = viewModel.categoryIcon {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(viewModel.categoryColor)
                    .padding(.top, 28)
                    .isSkeletonView(viewModel.isLoading)
            }

            // Merchant name
            Text(viewModel.merchantName)
                .font(Fonts.bold(size: 24) as Font)
                .foregroundStyle(Color(hex: 0x19191B))
                .padding(.top, 12)
                .isSkeletonView(viewModel.isLoading)

            // Amount
            Text(viewModel.formattedAmount)
                .font(Fonts.bold(size: 32) as Font)
                .foregroundStyle(Palette.staticBlack.swiftUI)
                .padding(.top, 8)
                .isSkeletonView(viewModel.isLoading)

            // Date
            Text(viewModel.formattedDate)
                .font(Fonts.medium(size: 16) as Font)
                .foregroundStyle(Palette.grayMedium.swiftUI)
                .padding(.top, 4)
                .isSkeletonView(viewModel.isLoading)

            // Category pill
            if let categoryName = viewModel.categoryName {
                categoryPill(name: categoryName)
                    .padding(.top, 20)
                    .padding(.horizontal, 27)
                    .isSkeletonView(viewModel.isLoading)
            }

            // Share button
            actionButton(title: "Compartir", icon: "square.and.arrow.up") {
                viewModel.share()
            }
            .padding(.top, 12)
            .padding(.horizontal, 27)
            .isSkeletonView(viewModel.isLoading)

            // Close button
            actionButton(title: "Cerrar", icon: nil) {
                dismissView()
            }
            .padding(.top, 8)
            .padding(.horizontal, 27)
            .padding(.bottom, 28)
            .isSkeletonView(viewModel.isLoading)
        }
    }

    // MARK: - Skeleton content

    @ViewBuilder
    private var skeletonContent: some View {
        VStack(spacing: 0) {
            // Icon placeholder
            skeletonPill(width: 40, height: 40)
                .clipShape(Circle())
                .padding(.top, 28)

            // Merchant name placeholder
            skeletonPill(width: 140, height: 20)
                .padding(.top, 14)

            // Amount placeholder
            skeletonPill(width: 200, height: 28)
                .padding(.top, 12)

            // Date placeholder
            skeletonPill(width: 160, height: 14)
                .padding(.top, 8)

            // Category pill placeholder
            skeletonPill(width: .infinity, height: 60)
                .padding(.top, 20)
                .padding(.horizontal, 27)

            // Button placeholder
            skeletonPill(width: .infinity, height: 50)
                .padding(.top, 12)
                .padding(.horizontal, 27)

            // Button placeholder
            skeletonPill(width: .infinity, height: 50)
                .padding(.top, 8)
                .padding(.horizontal, 27)
                .padding(.bottom, 28)
        }
    }

    @ViewBuilder
    private func skeletonPill(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
            .fill(Palette.grayUltraLight.swiftUI)
            .frame(maxWidth: width == .infinity ? .infinity : width, minHeight: height, maxHeight: height)
            .shimmer()
    }

    // MARK: - Category pill

    @ViewBuilder
    private func categoryPill(name: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Categoría")
                    .font(Fonts.medium(size: 17) as Font)
                    .foregroundStyle(Palette.grayDark.swiftUI)

                Text(name)
                    .font(Fonts.bold(size: 20) as Font)
                    .foregroundStyle(viewModel.categoryColor)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(viewModel.categoryColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(viewModel.categoryColor.opacity(0.1))
                .shadow(color: .purple.opacity(0.03), radius: 2, x: 0, y: 3)
        )
    }

    // MARK: - Action button

    @ViewBuilder
    private func actionButton(title: String, icon: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(Fonts.bold(size: 19) as Font)
            }
            .foregroundStyle(Palette.green.swiftUI)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Palette.grayUltraLight.swiftUI)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Dismiss

    private func dismissView() {
        withAnimation(.timingCurve(0.45, 0.35, 0.25, 1.05, duration: 0.5)) {
            isShowing = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.dismissView()
        }
    }
}

// MARK: - Color hex helper

private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

// MARK: - Shimmer modifier

private struct ShimmerModifier: ViewModifier {

    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.4), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: phase * geo.size.width)
                }
                .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

private extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Loading") {
    TransactionDetailView(
        viewModel: TransactionDetailViewModel(transactionId: "mock-1")
    )
}

#Preview("Loaded") {
    TransactionDetailView(
        viewModel: {
            let vm = TransactionDetailViewModel(transactionId: "mock-1")
            vm.merchantName = "Pedidos Ya"
            vm.formattedAmount = "$ 37.230,00"
            vm.formattedDate = "2 de marzo de 2026"
            vm.categoryName = "Delivery"
            vm.categoryIcon = "scooter"
            vm.categoryColor = .red
            vm.isLoading = false
            return vm
        }()
    )
}
#endif
