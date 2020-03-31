//
//  ViewController.swift
//  CollectionView Tutorial 2
//
//  Created by Andrew Williams on 3/31/20.
//  Copyright © 2020 Andrew Williams. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var collectionView: UICollectionView! = nil
    
    var dataSource: UICollectionViewDiffableDataSource<String, NSManagedObjectID>! = nil
    
    var fetchedResultsController: NSFetchedResultsController <DateItem>!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    var managedObjectContext : NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureCoreData()
        configureHierarchy()
        configureDataSource()
        configureButtons()
        configureFRC()
    }
    
    func configureCoreData() {
        managedObjectContext = appDelegate.persistentContainer.viewContext
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        let spacing = CGFloat(10)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: DateCell.reuseIdentifier)
        view.addSubview(collectionView)
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<String, NSManagedObjectID>(collectionView: collectionView) {
        (collectionView: UICollectionView, indexPath: IndexPath, itemID: NSManagedObjectID) -> UICollectionViewCell? in
            let item = self.fetchedResultsController.object(at: indexPath)

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DateCell.reuseIdentifier,
                for: indexPath) as? DateCell
                else { fatalError("Cannot create new cell") }
            
            guard let date = item.date_created
                else {fatalError("No date found for item")}

            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .medium
            
            cell.label.text = "\(formatter.string(from:date))"
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
            cell.label.textAlignment = .center
            cell.label.font = UIFont.preferredFont(forTextStyle: .title1)

            return cell
        }

    }
    
    func configureFRC() {
        let fetchRequest = NSFetchRequest<DateItem>(entityName: "DateItem")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date_created", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            fetchedResultsController.delegate = self
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Fetch error: \(fetchError), \(fetchError.userInfo)")
        }
    }
    
    func configureButtons() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newItem))
    }
    
    @objc func newItem() {
        let item = DateItem(context: managedObjectContext)
        item.date_created = Date()
        appDelegate.saveContext()
    }
    
}

extension ViewController : NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard dataSource != nil else { return }
        
        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot, animatingDifferences: true)
    }
    
}

