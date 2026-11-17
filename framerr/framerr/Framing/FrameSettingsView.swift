import SwiftUI

struct FrameSettingsView: View {
    @Binding var settings: FrameSettings

    var body: some View {
        let canvas = settings.ratio.canvasSize

        Form {
            Section("Format") {
                Picker("Ratio", selection: $settings.ratio) {
                    ForEach(AspectRatio.allCases) { ratio in
                        Text(ratio.title).tag(ratio)
                    }
                }
                .accessibilityIdentifier("ratio-picker")

                LabeledContent("Export Size", value: "\(Int(canvas.width)) × \(Int(canvas.height)) px")
            }

            Section {
                Picker("Fill the Gap", selection: $settings.fillGap) {
                    ForEach(FillGapMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .accessibilityIdentifier("fill-gap-picker")

                LabeledContent("Width") {
                    HStack {
                        Slider(value: $settings.borderPercent, in: FrameSettings.borderRange, step: 0.5)
                            .accessibilityIdentifier("border-slider")
                        Text(settings.borderPercent / 100, format: .percent.precision(.fractionLength(0 ... 1)))
                            .monospacedDigit()
                            .frame(minWidth: 44, alignment: .trailing)
                    }
                }
                .disabled(settings.fillGap == .all)

                ColorPicker("Color", selection: $settings.pickerColor, supportsOpacity: false)
            } header: {
                Text("Border")
            } footer: {
                Text(footer)
            }
        }
        .formStyle(.grouped)
    }

    private var footer: LocalizedStringResource {
        switch settings.fillGap {
        case .off: "The border surrounds every photo on every side."
        case .horizontal: "Horizontal photos touch the edges. Other photos get a border on every side."
        case .vertical: "Vertical photos touch the edges. Other photos get a border on every side."
        case .all: "Every photo touches the edges. The border only fills the remaining space."
        }
    }
}

#Preview {
    FrameSettingsView(settings: .constant(FrameSettings()))
}
