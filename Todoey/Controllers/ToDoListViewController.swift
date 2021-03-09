//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    var itemArray = [Items]()
    var selectedCategory: Categories? {
        didSet{
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //USER DEFAULTS ::
    //let defaults = UserDefaults.standard
    
    //Get the current application running path
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(K.pathConfig) as! URL
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        USER DEFAULTS ::
//        if let items = defaults.array(forKey: K.defaultName) as? [Items] {
//            itemArray = items
//        }
    }
    
    func addItem(title_: String, isDone_: Bool) {
        let newItem = Items(context: context)
        newItem.title = title_
        newItem.isDone = isDone_
        if let safeCategory = selectedCategory {
            newItem.parentCategory = safeCategory
        }
        itemArray.append(newItem)
    }
    
    //MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item =  itemArray[indexPath.row]
        
        //let cell = UITableViewCell(style: .default, reuseIdentifier: K.cellIdentifier)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.isDone ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].isDone.toggle()
        
        tableView.reloadData()
        
        saveItems( )
        
        // Hide the selection color to create a flash animation feel
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let safeData = textField.text{
                //If user didn't enter any Item, then empty string is passed
                if "" != safeData {
                    
                    self.addItem(title_: safeData, isDone_: false)
                    
                    //USER DEFAULTS ::
                    //self.defaults.set(self.itemArray, forKey: K.defaultName)
                    self.saveItems( )
                    
                     //Reload and Update the added Item in UI Table  View
                    self.tableView.reloadData()
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
    
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems( ) {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func loadItems(_ request: NSFetchRequest<Items> = Items.fetchRequest(), predicate_ predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let searchPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, searchPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func removeItems(index: Int) {
        context.delete(itemArray[index])
        itemArray.remove(at: index)
        saveItems()
    }
}

//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let safeText = searchBar.text {
            if "" != safeText {
                let request: NSFetchRequest<Items> = Items.fetchRequest()
                
                request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

                loadItems(request, predicate_: NSPredicate(format: "title CONTAINS[cd] %@", safeText))
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if 0 == searchBar.text?.count{
            
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
