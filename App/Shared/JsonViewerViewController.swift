//
//  JSONViewerViewController.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/28/20.
//
import UIKit
import SwiftUI

class JSONViewerViewController: UICollectionViewController {
    var dictionary: [String: Any] {
        didSet {
            applySnapshot()
        }
    }
    
    private let sortedKeys: [String]
    
    enum Section {
        case main
    }
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, String> = {
        let cellRegistration =
            UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, key in
                let type = JSONType(value: self.dictionary[key])
                
                var content = cell.defaultContentConfiguration()
                content.text = key
                content.secondaryText = type.value
                cell.contentConfiguration = content
                
                if type.containsSubtype {
                    cell.accessories = [.disclosureIndicator()]
                }
            }
        
        return UICollectionViewDiffableDataSource<Section, String>(collectionView: self.collectionView, cellProvider: {
            collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        })
    }()
    
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
        sortedKeys = dictionary.keys.sorted()
        
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        super.init(collectionViewLayout: layout)
        
        applySnapshot()
    }
    
    init(array: [Any]) {
        sortedKeys = Array(0..<array.count).map(String.init)
        dictionary = zip(sortedKeys, array).reduce(into: [:]) { $0[$1.0] = $1.1 }
    
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        super.init(collectionViewLayout: layout)
        
        applySnapshot()
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(sortedKeys)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sortedKeys.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        itemIsSelectable(at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        itemIsSelectable(at: indexPath)
    }
    
    private func itemIsSelectable(at indexPath: IndexPath) -> Bool {
        let key = sortedKeys[indexPath.row]
        let itemType = JSONType(value: self.dictionary[key])
        
        return itemType.containsSubtype
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let key = sortedKeys[indexPath.row]
        let type = JSONType(value: dictionary[key])

        let jsonReader: JSONViewerViewController
        switch type {
        case .array(let value):
            jsonReader = JSONViewerViewController(array: value)
        case .dictionary(let value):
            jsonReader = JSONViewerViewController(dictionary: value)
        default:
            return
        }

        jsonReader.title = key
        navigationController?.pushViewController(jsonReader, animated: true)
    }
    
    private enum JSONType {
        case bool(Bool)
        case string(String)
        case int(Int)
        case double(Double)
        case array([Any])
        case dictionary([String: Any])
        case data(Data)
        case null
        case unknown(String)
        
        init(value: Any?) {
            switch value {
            case let value as Bool:
                self = .bool(value)
            case let value as String:
                self = .string(value)
            case let value as Int:
                self = .int(value)
            case let value as Double:
                self = .double(value)
            case let value as [Any]:
                self = .array(value)
            case let value as [String: Any]:
                self = .dictionary(value)
            case let value as Date:
                self = .string(value.description)
            case let value as Float:
                self = .double(Double(value))
            case let value as Data:
                self = .data(value)
            case .none:
                self = .null
            default:
                self = .unknown(value.debugDescription)
            }
        }
        
        var value: String {
            switch self {
            case .bool(let value):
                return value.description
            case .string(let value):
                return value
            case .int(let value):
                return value.description
            case .double(let value):
                return value.description
            case .array(let value):
                return "Array of \(value.count) items"
            case .dictionary(let value):
                return "Dictionary of \(value.count) items"
            case .data(let value):
                return "Data of \(value.count) bytes"
            case .null:
                return "null"
            case .unknown(let description):
                return description
            }
        }
        
        var containsSubtype: Bool {
            switch self {
            case .bool, .string, .int, .double, .null, .unknown, .data:
                return false
            case .array, .dictionary:
                return true
            }
        }
    }
}

struct JSONInspectionView: UIViewControllerRepresentable {
    let jsonDict: [String: Any]

    func makeUIViewController(context: Context) -> JSONViewerViewController {
        JSONViewerViewController(dictionary: jsonDict)
    }
    
    func updateUIViewController(_ uiViewController: JSONViewerViewController, context: Context) {
        uiViewController.dictionary = jsonDict
    }
}

struct JSONInspectionView_Previews: PreviewProvider {
    static var previews: some View {
        let json: [String: Any] = ["test": true, "hello": "world!"]
        
        return JSONInspectionView(jsonDict: json)
    }
}
