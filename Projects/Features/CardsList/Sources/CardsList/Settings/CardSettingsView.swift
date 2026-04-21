//  CardSettingsView.swift
//  Created by Sebastian Burrieza on 21/04/2026.

import SwiftUI
import ResourcesUI
import ComponentsUI
import CoreModels

struct CardSettingsView: View {

    @State var viewModel: CardSettingsViewModel

    var body: some View {
        ZStack {
            Palette.backgroundMedium.swiftUI
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    cardInfoRow
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .padding(.bottom, 8)

                    VStack(spacing: 12) {
                        pauseRow
                        reportRow
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            headerView
        }
        .popup(icon: Image(systemName: "checkmark.circle.fill"),
               text: viewModel.popupText,
               duration: 2.0,
               isPresented: $viewModel.showPopup,
               completion: { viewModel.showPopup = false
        })
        .toastErrorView(title: viewModel.errorTitle ?? "",
                        message: viewModel.errorMessage,
                        duration: 3,
                        isPresented: $viewModel.isError)
    }

    // MARK: Header

    @ViewBuilder
    private var headerView: some View {
        NavigationBarView(
            leftView: LeftButtonView(type: .back, action: {
                viewModel.delegate?.navigateToPrevious()
            }),
            middleView:
                Text("SETTINGS_TITLE".localized)
                    .font(Fonts.regular(size: 24))
                    .foregroundColor(Palette.backgroundLight.swiftUI)
            , rightView: Color.clear.frame(width: 40, height: 40)
        )
        .padding(.bottom, 12)
        .background(
            Palette.yellow.swiftUI
                .ignoresSafeArea(edges: .top)
                .shadow(color: Palette.staticBlack.swiftUI.opacity(0.1), radius: 4, x: 0, y: 4)
        )
    }

    // MARK: Card info

    @ViewBuilder
    private var cardInfoRow: some View {
        HStack(spacing: 16) {
            cardView
                .frame(width: 117, height: 74)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.card.bankName)
                    .font(Fonts.medium(size: 20))
                    .foregroundColor(Palette.black.swiftUI)

                Text(viewModel.typeLabel)
                    .font(Fonts.regular(size: 17))
                    .foregroundColor(Palette.grayUltraDark.swiftUI)

                Text(viewModel.formattedLastFourDigits)
                    .font(Fonts.regular(size: 17))
                    .foregroundColor(Palette.black.swiftUI)
            }

            Spacer()
            
            activeBadge
        }
    }
    
    // MARK: Card thumbnail

    @ViewBuilder
    private var cardView: some View {
        CardView(
            type: viewModel.card.type,
            brand: viewModel.card.brand,
            color: viewModel.card.color,
            hexa: viewModel.card.hexa,
            size: 110,
            isShadow: false
        )
        .frame(width: 110, height: 70)
    }

    // MARK: Action rows

    @ViewBuilder
    private var pauseRow: some View {
        Button(action: {
            Task { await viewModel.pauseCard() }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "pause.fill")
                    .font(Fonts.regular(size: 26))
                    .foregroundColor(Palette.yellow.swiftUI)
                    .frame(width: 35, height: 35)

                VStack(alignment: .leading, spacing: 4) {
                    Text("SETTINGS_PAUSE_TITLE".localized)
                        .font(Fonts.medium(size: 17))
                        .foregroundColor(Palette.black.swiftUI)

                    Text("SETTINGS_PAUSE_SUBTITLE".localized)
                        .font(Fonts.regular(size: 13))
                        .foregroundColor(Palette.grayMedium.swiftUI)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Palette.backgroundLight.swiftUI)
                    .shadow(color: Palette.staticBlack.swiftUI.opacity(0.1), radius: 5, x: 0, y: 3)
            )
        }
        .disabled(viewModel.isSubmitting)
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var reportRow: some View {
        Button(action: {
            Task { await viewModel.reportCard() }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(Fonts.regular(size: 26))
                    .foregroundColor(Palette.red.swiftUI)
                    .frame(width: 35, height: 35)

                VStack(alignment: .leading, spacing: 4) {
                    Text("SETTINGS_REPORT_TITLE".localized)
                        .font(Fonts.medium(size: 17))
                        .foregroundColor(Palette.black.swiftUI)

                    Text("SETTINGS_REPORT_SUBTITLE".localized)
                        .font(Fonts.regular(size: 13))
                        .foregroundColor(Palette.grayMedium.swiftUI)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Palette.backgroundLight.swiftUI)
                    .shadow(color: Palette.staticBlack.swiftUI.opacity(0.1), radius: 5, x: 0, y: 3)
            )
        }
        .disabled(viewModel.isSubmitting)
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var activeBadge: some View {
        let isActive = !viewModel.isPaused
        Text(viewModel.activeBadgeLabel)
            .font(Fonts.regular(size: 16))
            .foregroundColor(isActive ? Palette.green.swiftUI : Palette.grayMedium.swiftUI)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Palette.green.swiftUI.opacity(0.2) : Palette.grayMedium.swiftUI.opacity(0.2))
            )
    }
}
