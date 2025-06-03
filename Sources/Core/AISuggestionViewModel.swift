import Foundation
import Combine
import SwiftUI
import AppKit

public class AISuggestionViewModel: ObservableObject {
    // MARK: - Types
    
    public enum SuggestionType: String {
        case general = "一般"
        case translation = "翻译"
        case correction = "修正"
        case completion = "补全"
        case suggestion = "建议"
        case summary = "总结"
        
        public var description: String {
            return self.rawValue
        }
        
        public var color: Color {
            switch self {
            case .general:
                return .gray
            case .translation:
                return .blue
            case .correction:
                return .red
            case .completion:
                return .green
            case .suggestion:
                return .orange
            case .summary:
                return .purple
            }
        }
    }
    
    public struct Suggestion: Equatable {
        public let type: SuggestionType
        public let content: String
        
        public init(type: SuggestionType, content: String) {
            self.type = type
            self.content = content
        }
        
        public static func == (lhs: Suggestion, rhs: Suggestion) -> Bool {
            return lhs.type == rhs.type && lhs.content == rhs.content
        }
    }
    
    // MARK: - Properties
    
    @Published public private(set) var suggestions: [Suggestion] = []
    @Published public private(set) var currentIndex: Int = -1
    @Published public private(set) var scrollPosition: CGFloat = 0
    @Published public private(set) var isLoading: Bool = false
    
    private let maxBufferSize = 10
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    public var currentSuggestion: Suggestion? {
        guard currentIndex >= 0 && currentIndex < suggestions.count else {
            return nil
        }
        return suggestions[currentIndex]
    }
    
    public var color: Color {
        currentSuggestion?.type.color ?? .blue
    }
    
    public var currentType: SuggestionType {
        currentSuggestion?.type ?? .translation
    }
    
    // MARK: - Public Methods
    
    public init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $suggestions
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    public func addSuggestion(_ content: String, type: SuggestionType) {
        let suggestion = Suggestion(type: type, content: content)
        addSuggestion(suggestion)
    }
    
    public func addSuggestion(_ suggestion: Suggestion) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.suggestions.append(suggestion)
            if self.suggestions.count > self.maxBufferSize {
                self.suggestions.removeFirst()
            }
            if self.currentIndex == -1 {
                self.currentIndex = 0
            }
        }
    }
    
    public func clearSuggestions() {
        DispatchQueue.main.async { [weak self] in
            self?.suggestions.removeAll()
            self?.currentIndex = -1
        }
    }
    
    // MARK: - Navigation Methods
    
    public func nextSuggestion() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.currentIndex < self.suggestions.count - 1 {
                self.currentIndex += 1
            }
        }
    }
    
    public func previousSuggestion() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.currentIndex > 0 {
                self.currentIndex -= 1
            }
        }
    }
    
    // MARK: - Scrolling Methods
    
    public func scrollUp() {
        previousSuggestion()
    }
    
    public func scrollDown() {
        nextSuggestion()
    }
    
    public func pageUp() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.scrollPosition = max(0, self.scrollPosition - 300)
        }
    }
    
    public func pageDown() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.scrollPosition += 300
        }
    }
    
    public func scrollToStart() {
        DispatchQueue.main.async { [weak self] in
            self?.currentIndex = 0
        }
    }
    
    public func scrollToEnd() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentIndex = self.suggestions.count - 1
        }
    }
    
    // MARK: - Action Methods
    
    public func copyCurrentSuggestion() {
        guard let suggestion = currentSuggestion else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(suggestion.content, forType: .string)
    }
    
    public func dismissSuggestion() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.currentIndex >= 0 && self.currentIndex < self.suggestions.count {
                self.suggestions.remove(at: self.currentIndex)
                if self.suggestions.isEmpty {
                    self.currentIndex = -1
                } else if self.currentIndex >= self.suggestions.count {
                    self.currentIndex = self.suggestions.count - 1
                }
            }
        }
    }
    
    // MARK: - Loading State
    
    public func startLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
    }
    
    public func stopLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
    }
} 