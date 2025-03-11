//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import UIKit

struct ConfettiView: UIViewRepresentable {
    var isSpecial: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let confettiLayer = CAEmitterLayer()
        confettiLayer.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)

        let colors: [UIColor] = isSpecial
            ? [.red, .orange, .yellow, .green, .purple]
            : [.blue, .cyan, .systemMint]

        let birthRate: Float = isSpecial ? 5 : 3
        let velocityRange: ClosedRange<CGFloat> = isSpecial ? 100...150 : 60...110
        let lifetime: Float = 1.8
        let cells: [CAEmitterCell] = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = birthRate
            cell.lifetime = lifetime
            cell.velocity = CGFloat.random(in: velocityRange)
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 1.5
            cell.spinRange = 2.5
            cell.color = color.cgColor
            cell.scale = isSpecial ? 0.4 : 0.25
            cell.contents = createColoredImage(systemName: isSpecial ? "star.fill" : "circle.fill", color: color)
            return cell
        }

        confettiLayer.emitterCells = cells
        view.layer.addSublayer(confettiLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    // MARK: - Convert SF Symbol to Colored CGImage
    private func createColoredImage(systemName: String, color: UIColor) -> CGImage? {
        let size = CGSize(width: 15, height: 15)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }

        guard let image = UIImage(systemName: systemName)?
                .withTintColor(color, renderingMode: .alwaysOriginal) else {
            return nil
            }
        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }
}
