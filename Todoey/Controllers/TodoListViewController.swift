//
//  ViewController.swift
//  Todoey
//
//  Created by Keith Gunn on 04/03/2018.
//  Copyright © 2018 Seasalt Digital. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
  
  var itemArray = [Item]()
  var currentCategory : Category? {
    didSet {
      loadData()
    }
  }
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

  }
  
  //MARK - Tableview Datasource methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return itemArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
    
    cell.textLabel?.text = itemArray[indexPath.row].title
    
    cell.accessoryType = itemArray[indexPath.row].done ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
    
    return cell
  
  }
  
  //MARK - Tableview delegate methods
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    // delete code (not used)
    //context.delete(itemArray[indexPath.row]);
    //itemArray.remove(at: indexPath.row)
    
    itemArray[indexPath.row].done = !itemArray[indexPath.row].done
    tableView.deselectRow(at: indexPath, animated: true)
    tableView.reloadData()
    saveData()
  }
  
  //MARK - Add new items
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
      let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
    
    alert.addTextField { (textField) in
      textField.placeholder = "Enter your item"
    }
    
    let submitAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
      // add item to array

      let newItem = Item(context: self.context)
      newItem.title = String(describing: alert.textFields![0].text!)
      newItem.done = false
      newItem.parentCategory = self.currentCategory
      self.itemArray.append(newItem)
      
      self.saveData()
      
      self.tableView.reloadData()
    }
    
    alert.addAction(submitAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  func saveData() {
    
    do {
      try context.save();
    } catch {
      print("Error encoding data \(error)")
    }
  }
  
  func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
    
    // fetch items for the current category
    let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", currentCategory!.name!)
    
    // if we have a predicate add it :)
    if let additionalPredicate = predicate {
      request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
    } else {
      request.predicate = categoryPredicate
    }
    
    do {
      itemArray = try context.fetch(request);
    } catch {
      print("Error fetching data from context \(error)")
    }
    
    tableView.reloadData()
  }

  
}

// MARK: Search bar methods
extension TodoListViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    let request : NSFetchRequest<Item> = Item.fetchRequest()
    
    let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
    
    request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    
    loadData(with: request, predicate: predicate)
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text?.count == 0 {
      loadData()
      DispatchQueue.main.async {
        searchBar.resignFirstResponder()
      }
    }
  }
}

