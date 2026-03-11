# AGENTS.md - Workout App Code Guidelines

This document provides guidelines for AI assistants to generate high-quality, modern SwiftUI code for the Workout App.

## Core Principles

- **Modern Swift**: Target iOS 18+ exclusively. Use latest Swift 6 features.
- **Performance**: Avoid unnecessary recomputation. Split views into separate SwiftUI structures.
- **Accessibility**: VoiceOver support is non-negotiable. Use proper semantic components.
- **Concurrency**: Use Swift async/await exclusively. Never use `DispatchQueue.main.async`.

## SwiftUI Best Practices

### Deprecated APIs to Avoid

❌ **Never use these:**
- `foregroundColor()` → Use `foregroundStyle()` instead
- `cornerRadius()` → Use `clipShape(.rect(cornerRadius:))` instead
- `onChange(of:perform:)` (single parameter) → Use two-parameter or zero-parameter variant
- `tabItem()` → Use new `Tab` API instead
- `NavigationView` → Use `NavigationStack` instead
- `ObservableObject` + `@Published` → Use `@Observable` macro instead
- `onTapGesture()` → Use `Button` instead (only use gesture for location/count needs)
- `UIGraphicsImageRenderer` → Use `ImageRenderer` instead
- `NavigationLink` (inline destination) → Use `navigationDestination(for:)` instead
- `Task.sleep(nanoseconds:)` → Use `Task.sleep(for:)` with `.seconds()`, `.milliseconds()` etc.
- `String(format:...)` for numbers → Use `Text(..., format:)` with `FormatStyle` instead

### View Structure

✅ **DO:**
- Split complex views into separate `struct` declarations (not computed properties)
- Use `@Observable` for state management
- Implement `Equatable` and `Hashable` on data models as needed
- Compose views from smaller, testable pieces

❌ **DON'T:**
- Put view logic in computed properties when using `@Observable`
- Use `GeometryReader` unless absolutely necessary
- Add fixed `frame()` sizes without justification
- Place multiple types in a single file

### Layout & Styling

✅ **DO:**
- Use Dynamic Type: `.font(.body)`, `.font(.headline)`, etc.
- Use `visualEffect()` and `containerRelativeFrame()` for responsive layouts
- Use `foregroundStyle()` for color/gradient styling
- Use system colors: `Color.blue`, `Color.red`, etc.
- Use `@ScaledMetric` for scaling custom values

❌ **DON'T:**
- Force specific font sizes: `.font(.system(size: 16))` (except in very specific cases)
- Use `fontWeight(.bold)` inconsistently - prefer semantic weights or `bold()` modifier
- Overuse `fontWeight()` modifier
- Use `.font(.system(size:))` for dynamic content

### Buttons & Interactions

✅ **DO:**
- Use `Button("Label", systemImage: "icon", action: { })` syntax
- Use `Button` with proper accessibility labels
- Use `navigationDestination(for:destination:)` for navigation
- Use actual buttons instead of `onTapGesture()`

❌ **DON'T:**
- Create buttons with just `Image` (bad for VoiceOver)
- Use `Label` constructor in buttons when inline syntax is available
- Use `onTapGesture()` for basic tap interactions

### Data Display

✅ **DO:**
- Use `ForEach(x.enumerated(), id: \.element.id)` directly
- Use `@Query` for SwiftData queries
- Use typed array initialization for SwiftData models
- Use proper `List` configurations with `.listStyle()`

❌ **DON'T:**
- Wrap enumerated sequences: `ForEach(Array(x.enumerated()), ...)`
- Use `URL(fileURLWithPath:)` for standard directories - use `URL.documentsDirectory`
- Fetch full collections when querying - use SwiftData predicates

## Architecture

### File Organization

```
workout-app/
├── Views/              # SwiftUI view files
├── Models/             # Data models (SwiftData, structs)
├── Services/           # Business logic, API calls
├── Resources/          # Localizable strings, constants
└── Assets.xcassets/    # Images, colors
```

### Model Requirements

- All `@Model` classes must be final or in sealed hierarchies
- Use `@Transient` for computed or temporary properties
- Implement `@Relationship` with proper cascading rules
- Use `@Attribute(.unique)` carefully - does NOT work with CloudKit

### State Management

- Use `@Observable` for view state
- Use `@Query` for SwiftData persistence queries
- Use `@State` only for simple view-local state
- Use `@Environment` for app-wide values
- Never mark auto-main functions with `@MainActor` (default in iOS 18+)

## Concurrency

✅ **DO:**
- Use `async/await` for all async operations
- Mark async functions appropriately
- Use `Task` for fire-and-forget operations
- Use `withCheckedThrowingContinuation` for legacy closure APIs

❌ **DON'T:**
- Use `DispatchQueue.main.async` - Swift concurrency handles this
- Use completion closures in new code
- Force `@MainActor` unless required
- Mix `Combine` with `@Observable` unless needed

## Performance Checklist

- [ ] Views under 200 lines (split if larger)
- [ ] No computed properties with side effects
- [ ] No unnecessary `@State` or `@Observable` properties
- [ ] Images are optimized for asset catalog
- [ ] Lists use proper cell identification
- [ ] No polling loops or timers without cancellation

## Testing

- Unit tests in `workout-appTests/`
- UI tests in `workout-appUITests/`
- Test view accessibility with VoiceOver
- Mock Services for integration tests

## Accessibility Requirements

- All interactive elements must have labels (visible or via accessibility)
- Use semantic colors for meaning (not just visual)
- Test with VoiceOver enabled
- Ensure minimum 44pt touch targets
- Provide alternative text for images

## Example Patterns

### Observable State Management
```swift
@Observable
final class WorkoutViewModel {
    var workouts: [Workout] = []
    var isLoading = false
    
    func loadWorkouts() async {
        isLoading = true
        defer { isLoading = false }
        workouts = await Service.fetchWorkouts()
    }
}

#Preview {
    WorkoutListView()
        .environment(WorkoutViewModel())
}
```

### Modern Navigation
```swift
NavigationStack(path: $viewModel.navigationPath) {
    List(workouts) { workout in
        NavigationLink(value: workout) {
            WorkoutRow(workout: workout)
        }
    }
    .navigationDestination(for: Workout.self) { workout in
        WorkoutDetailView(workout: workout)
    }
}
```

### Dynamic Type with Scaling
```swift
VStack(alignment: .leading) {
    Text("Workout Title")
        .font(.headline)
    Text("5 exercises")
        .font(.body)
        .foregroundStyle(.secondary)
}
```

### SwiftData Integration
```swift
@Query(sort: \.date, order: .reverse)
var workouts: [Workout]

List(workouts) { workout in
    WorkoutRow(workout: workout)
}
.onDelete(perform: deleteWorkouts)
```

## Code Review Checklist for AI

- [ ] No deprecated APIs used
- [ ] Views are properly composed (no mega-views)
- [ ] Accessibility labels present
- [ ] Proper error handling for async operations
- [ ] Type safety maintained throughout
- [ ] No force unwraps except for literals/constants
- [ ] Dynamic Type respected
- [ ] Performance optimized (no unnecessary re-renders)
