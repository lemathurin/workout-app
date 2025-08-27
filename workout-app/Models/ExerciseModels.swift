import SwiftData
import Foundation

@Model
class Equipment {
    @Attribute(.unique) var id: String
    var translations: [Translation]
    
    init(id: String, translations: [Translation] = []) {
        self.id = id
        self.translations = translations
    }
}

@Model
class Level {
    @Attribute(.unique) var id: String
    var translations: [Translation]
    
    init(id: String, translations: [Translation] = []) {
        self.id = id
        self.translations = translations
    }
}

@Model
class Force {
    @Attribute(.unique) var id: String
    var translations: [Translation]
    
    init(id: String, translations: [Translation] = []) {
        self.id = id
        self.translations = translations
    }
}

@Model
class Category {
    @Attribute(.unique) var id: String
    var translations: [Translation]
    
    init(id: String, translations: [Translation] = []) {
        self.id = id
        self.translations = translations
    }
}

@Model
class Mechanic {
    @Attribute(.unique) var id: String
    var translations: [Translation]
    
    init(id: String, translations: [Translation] = []) {
        self.id = id
        self.translations = translations
    }
}

@Model
class Muscle {
    @Attribute(.unique) var id: String
    var translations: [Translation]
    
    init(id: String, translations: [Translation] = []) {
        self.id = id
        self.translations = translations
    }
}

@Model
class Translation {
    var languageCode: String
    var text: String
    
    init(languageCode: String, text: String) {
        self.languageCode = languageCode
        self.text = text
    }
}

@Model
class ExerciseTranslation {
    var languageCode: String
    var name: String
    
    init(languageCode: String, name: String) {
        self.languageCode = languageCode
        self.name = name
    }
}

@Model
class Exercise {
    @Attribute(.unique) var id: String
    var forceId: String
    var levelId: String
    var mechanicId: String
    var equipmentId: String
    var categoryId: String
    var primaryMuscleId: String
    var secondaryMuscles: [String]
    var translations: [ExerciseTranslation]
    
    init(id: String, forceId: String, levelId: String, mechanicId: String, equipmentId: String, categoryId: String, primaryMuscleId: String, secondaryMuscles: [String] = [], translations: [ExerciseTranslation] = []) {
        self.id = id
        self.forceId = forceId
        self.levelId = levelId
        self.mechanicId = mechanicId
        self.equipmentId = equipmentId
        self.categoryId = categoryId
        self.primaryMuscleId = primaryMuscleId
        self.secondaryMuscles = secondaryMuscles
        self.translations = translations
    }
    
    func getName(for languageCode: String = "en") -> String {
        return translations.first { $0.languageCode == languageCode }?.name ?? translations.first?.name ?? id
    }
}