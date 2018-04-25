//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Keith Gunn on 24/04/2018.
//  Copyright © 2018 Seasalt Digital. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
  
  var categories = [Category]()
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadData()
  }
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
    
    alert.addTextField { (textField) in
      textField.placeholder = "Enter your category"
    }
    
    let submitAction = UIAlertAction(title: "Add Category", style: .default) { (action) in
      // add item to array
      
      let newCategory = Category(context: self.context)
      newCategory.name = String(describing: alert.textFields![0].text!)
      self.categories.append(newCategory)
      
      self.saveData()
      
      self.tableView.reloadData()
    }
    
    alert.addAction(submitAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  //MARK: TableView Datasource methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    
    cell.textLabel?.text = categories[indexPath.row].name
    
    return cell
  }
  
  //MARK: Data methods
  func loadData(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
    do {
      categories = try context.fetch(request);
    } catch {
      print("Error fetching Category data from context \(error)")
    }
    
    tableView.reloadData()
  }
  
  func saveData() {
    do {
      try context.save();
    } catch {
      print("Error encoding Category data \(error)")
    }
  }
  
  //MARK: TableView Delegate methods
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "goToItems", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! TodoListViewController
    
    if let indexPath = tableView.indexPathForSelectedRow {
      destinationVC.currentCategory = categories[indexPath.row]
    }
  }

}
