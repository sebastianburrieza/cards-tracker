//  AnimationStack.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI

public struct AnimationStack: View {
    
    private let views: [AnyView]
    
    @State private var animations: [Bool]
    
    let delay: Double
    
    public init<V0: View>(opacity: Bool = true,
                          offSetX: CGFloat = 0,
                          offSetY: CGFloat = 0,
                          delay: Double = 0.1,
                          animation: Animation = .spring.speed(0.7),
                          @ViewBuilder content: @escaping () -> TupleView<(V0)>) {
        let cv = content().value
        self.views = [AnyView(cv)]
        animations = [false]
        self.opacity = opacity
        self.offSetX = offSetX
        self.offSetY = offSetY
        self.delay = delay
        self.animation = animation
    }
    
    public init<Views>(opacity: Bool = true,
                       offSetX: CGFloat = 0,
                       offSetY: CGFloat = 0,
                       delay: Double = 0.1,
                       animation: Animation = .spring.speed(0.7),
                       @ViewBuilder content: @escaping () -> TupleView<Views>) {
        views = content().getViews
        var bools = [Bool]()
        if views.isEmpty {
            bools.append(false)
        } else {
            for _ in views {
                bools.append(false)
            }
        }
        self.animations = bools
        self.opacity = opacity
        self.offSetX = offSetX
        self.offSetY = offSetY
        self.delay = delay
        self.animation = animation
    }
    
    public init<Views>(@ViewBuilder content: @escaping () -> TupleView<Views>) {
        views = content().getViews
        var bools = [Bool]()
        if views.isEmpty {
            bools.append(false)
        } else {
            for _ in views {
                bools.append(false)
            }
        }
        self.animations = bools
        self.opacity = true
        self.offSetX = 0
        self.offSetY = 0
        self.delay = 0.1
        self.animation = .spring.speed(0.7)
    }
    
    @State private var index = 0
    
    let opacity: Bool
    let offSetY: CGFloat
    let offSetX: CGFloat
    let animation: Animation
    
    private func start() {
        guard index < animations.count else {return}
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            animations[index] = true
            index += 1
            start()
        }
    }
    
    public var body: some View {
        ForEach(views.indices, id: \.self) { i in
            views[i]
                .opacity(animations[i] ? 1 : self.opacity ? 0 : 1)
                .offset(y: animations[i] ? 1 : offSetY)
                .offset(x: animations[i] ? 0 : offSetX)
        }
        .animation(animation, value: animations)
        .onAppear(perform: start)
    }
}

extension TupleView {
    
    var getViews: [AnyView] {
        makeArray(from: value)
    }
    
    private struct GenericView {
        let body: Any
        
        var anyView: AnyView? {
            AnyView(_fromValue: body)
        }
    }
    
    private func makeArray<Tuple>(from tuple: Tuple) -> [AnyView] {
        func convert(child: Mirror.Child) -> AnyView? {
            withUnsafeBytes(of: child.value) { ptr -> AnyView? in
                let binded = ptr.bindMemory(to: GenericView.self)
                return binded.first?.anyView
            }
        }
        
        let tupleMirror = Mirror(reflecting: tuple)
        return tupleMirror.children.compactMap(convert)
    }
}
