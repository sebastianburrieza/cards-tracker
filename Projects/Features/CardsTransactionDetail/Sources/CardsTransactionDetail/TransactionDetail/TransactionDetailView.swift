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
                        .background(Palette.backgroundLight.swiftUI)
                        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                }
                .offset(y: isShowing ? 0 : height)
                .opacity(isShowing ? 1 : 0)
                .padding(.bottom, 10)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onAppear {
            withAnimation(.timingCurve(0.45, 0.25, 0.15, 1.05, duration: 0.4)) {
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
                .font(Fonts.bold(size: 24))
                .foregroundStyle(Palette.grayDark.swiftUI)
                .padding(.top, 12)
                .isSkeletonView(viewModel.isLoading)

            // Amount
            Text(viewModel.formattedAmount)
                .font(Fonts.bold(size: 32))
                .foregroundStyle(Palette.black.swiftUI)
                .padding(.top, 8)
                .isSkeletonView(viewModel.isLoading)

            // Date
            Text(viewModel.formattedDate)
                .font(Fonts.medium(size: 16))
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
            actionButton(title: "SHARE".localized, icon: "square.and.arrow.up") {
                viewModel.share()
            }
            .padding(.top, 12)
            .padding(.horizontal, 27)
            .isSkeletonView(viewModel.isLoading)

            // Close button
            actionButton(title: "CLOSE".localized, icon: nil) {
                dismissView()
            }
            .padding(.top, 8)
            .padding(.horizontal, 27)
            .padding(.bottom, 28)
            .isSkeletonView(viewModel.isLoading)
        }
    }

    // MARK: - Category pill

    @ViewBuilder
    private func categoryPill(name: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("CATEGORY".localized)
                    .font(Fonts.medium(size: 17))
                    .foregroundStyle(Palette.grayDark.swiftUI)

                Text(name)
                    .font(Fonts.bold(size: 20))
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
                    .font(Fonts.bold(size: 19))
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
