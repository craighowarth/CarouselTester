//
//  ViewController.swift
//  CarouselTester
//
//  Created by Howarth, Craig on 1/7/21.
//

import UIKit

class ViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var viewData = ViewData()
    private var dataSource: ViewDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource(collectionView)
        applySnapshot()
    }

    override func viewDidLayoutSubviews() {
        view.colorSubviews()
    }

    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())

        // Replace above line with this for a fix
        //collectionView = FixedCollectionView(frame: .zero, collectionViewLayout: createLayout())

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

// MARK: - Collection View Layout

extension ViewController {
    func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        config.scrollDirection = .vertical
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        return layout
    }

    func sectionProvider(section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        guard let homeSection = getSection(at: section) else { return nil }
        switch homeSection.layoutDirection {
        case .horizontal:
            return horizontalSection(environment: environment)
        case .vertical:
            return verticalSection()
        }
    }

    func verticalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(50)) // the actual height will be ~120
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(50)) // the actual height will be ~120
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        return section
    }

    func horizontalSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(200)) // the actual height will be ~320
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                               heightDimension: .estimated(200)) // the actual height will be ~320

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        return section
    }
}

// MARK: - Data Source

typealias ViewDataSource = UICollectionViewDiffableDataSource<ViewData.Section, ViewData.Item>
typealias ViewSnapshot = NSDiffableDataSourceSnapshot<ViewData.Section, ViewData.Item>

extension ViewController {
    func getSection(at index: Int) -> ViewData.Section? {
        return viewData.sections[index]
    }

    func applySnapshot(animatingDifferences: Bool = true) {
        dataSource.apply(snapshot(forSections: viewData.sections), animatingDifferences: animatingDifferences)
    }

    func snapshot(forSections sections: [ViewData.Section]) -> ViewSnapshot {
        var snapshot = ViewSnapshot()
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        return snapshot
    }

    func configureDataSource(_ collectionView: UICollectionView) {
        let tallCellRegistration = UICollectionView.CellRegistration<TallCell, ViewData.Item> { (cell, indexPath, item) in
            cell.title = item.title
        }
        let squatCellRegistration = UICollectionView.CellRegistration<SquatCell, ViewData.Item> { (cell, indexPath, item) in
            cell.title = item.title
        }

        dataSource = ViewDataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            switch item {
            case .tallCell:
                return collectionView.dequeueConfiguredReusableCell(using: tallCellRegistration, for: indexPath, item: item)
            case .squatCell:
                return collectionView.dequeueConfiguredReusableCell(using: squatCellRegistration, for: indexPath, item: item)
            }
        }
    }
}

struct ViewData {
    enum Item: Hashable {
        case tallCell(String)
        case squatCell(String)

        var title: String {
            switch self {
            case let .tallCell(title): return title
            case let .squatCell(title): return title
            }
        }
    }

    enum LayoutDirection: Hashable {
        case vertical
        case horizontal
    }

    struct Section: Hashable {
        var layoutDirection: LayoutDirection
        var items: [Item]
    }

    var sections: [Section]

    init() {
        sections = [Section]()
        sections.append(.init(layoutDirection: .vertical,
                              items: [
                                .squatCell("First Section, 1st Item"),
                                .squatCell("First Section, 2nd Item"),
                                .squatCell("First Section, 3nd Item"),
                              ])
        )
        sections.append(.init(layoutDirection: .horizontal,
                              items: [
                                .tallCell("Second Section, 1st Item"),
                                .tallCell("Second Section, 2nd Item"),
                                .tallCell("Second Section, 3nd Item"),
                              ])
        )
    }
}

// MARK: - Cells

class TallCell: ViewCell {
    static let reuseIdentifier = "TallCellReuseIdentifier"
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageHeight = 300
        configureCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SquatCell: ViewCell {
    static let reuseIdentifier = "SquatCellReuseIdentifier"
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageHeight = 100
        configureCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewCell: UICollectionViewCell {
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    private let image = UIImageView()
    private let titleLabel = UILabel()
    var imageHeight: CGFloat = 0

    func configureCell() {
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .orange
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(image)
        let heightConstraint = image.heightAnchor.constraint(equalToConstant: imageHeight)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            image.topAnchor.constraint(equalTo: contentView.topAnchor)
            ])
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
    }
}

extension UIView {
    func colorSubviews() {
        layer.borderWidth = 1.0
        if NSStringFromClass(self.classForCoder) == "_UICollectionViewOrthogonalScrollerEmbeddedScrollView" {
            layer.borderColor = UIColor.blue.cgColor
            backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        }
        subviews.forEach { $0.colorSubviews() }
    }
}

// Fix on based on solution found in
// https://stackoverflow.com/questions/65369130/uicollectionviewcompositionallayout-bug-on-ios-14-3
public final class FixedCollectionView: UICollectionView {
    override public func layoutSubviews() {
        super.layoutSubviews()

        if #available(iOS 14.3, *) { return }

        subviews.forEach { subview in
            guard
                let scrollView = subview as? UIScrollView,
                let minY = scrollView.subviews.map(\.frame.origin.y).min(),
                let maxHeight = scrollView.subviews.map(\.frame.height).max(),
                minY > scrollView.frame.minY || maxHeight > scrollView.frame.height
            else { return }

            scrollView.contentInset.top = -minY
            scrollView.frame.origin.y = minY
            scrollView.frame.size.height = maxHeight
        }
    }
}
