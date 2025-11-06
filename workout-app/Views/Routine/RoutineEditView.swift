import SwiftUI
import UniformTypeIdentifiers

struct RoutineEditView: View {
@State private var list1 = ["Item 1-1", "Item 1-2", "Item 1-3"]
@State private var list2 = ["Item 2-1", "Item 2-2", "Item 2-3"]
@State private var list3 = ["Item 3-1", "Item 3-2", "Item 3-3"]

struct DragPayload: Codable {
let value: String
let source: String
}

private func makeJSONItemProvider(value: String, source: String) -> NSItemProvider {
        let payload = DragPayload(value: value, source: source)
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(payload) else {
            return NSItemProvider()
        }
        let provider = NSItemProvider()
        provider.registerDataRepresentation(
            forTypeIdentifier: UTType.json.identifier,
            visibility: .all
        ) { completion in
            completion(data, nil)
            return nil
        }
        return provider
    }

    private func decodeDraggedString(from providers: [NSItemProvider],
                                     onDecoded: @escaping (DragPayload) -> Void) {
        guard let provider = providers.first else { return }
        provider.loadItem(forTypeIdentifier: UTType.json.identifier, options: nil) { item, error in
            guard let data = item as? Data,
                  let payload = try? JSONDecoder().decode(DragPayload.self, from: data) else {
                return
            }
            DispatchQueue.main.async {
                onDecoded(payload)
            }
        }
    }

    private func removePayloadFromSource(_ payload: DragPayload) {
        switch payload.source {
        case "list1":
            if let idx = list1.firstIndex(of: payload.value) { list1.remove(at: idx) }
        case "list2":
            if let idx = list2.firstIndex(of: payload.value) { list2.remove(at: idx) }
        case "list3":
            if let idx = list3.firstIndex(of: payload.value) { list3.remove(at: idx) }
        default:
            break
        }
    }

    var body: some View {
        VStack {
            Text("List 1")
            List {
                ForEach(list1, id: \.self) { item in
                    Text(item)
                        .onDrag {
                            makeJSONItemProvider(value: item, source: "list1")
                        }
                }
                .onMove { from, to in
                    list1.move(fromOffsets: from, toOffset: to)
                }
                .onInsert(of: [UTType.json]) { index, providers in
                    decodeDraggedString(from: providers) { payload in
                        removePayloadFromSource(payload)
                        list1.insert(payload.value, at: index)
                    }
                }
            }

            Text("List 2")
            List {
                ForEach(list2, id: \.self) { item in
                    Text(item)
                        .onDrag {
                            makeJSONItemProvider(value: item, source: "list2")
                        }
                }
                .onMove { from, to in
                    list2.move(fromOffsets: from, toOffset: to)
                }
                .onInsert(of: [UTType.json]) { index, providers in
                    decodeDraggedString(from: providers) { payload in
                        removePayloadFromSource(payload)
                        list2.insert(payload.value, at: index)
                    }
                }
            }

            Text("List 3")
            List {
                ForEach(list3, id: \.self) { item in
                    Text(item)
                        .onDrag {
                            makeJSONItemProvider(value: item, source: "list3")
                        }
                }
                .onMove { from, to in
                    list3.move(fromOffsets: from, toOffset: to)
                }
                .onInsert(of: [UTType.json]) { index, providers in
                    decodeDraggedString(from: providers) { payload in
                        removePayloadFromSource(payload)
                        list3.insert(payload.value, at: index)
                    }
                }
            }
        }
        .environment(\.editMode, .constant(.active))
        }
}