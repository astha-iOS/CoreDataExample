//
//  ViewController.swift
//  coreDataExample
//
//  Created by WDP on 12/07/20.
//  Copyright © 2020 WDP. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tblView: UITableView!
    
    var people: [NSManagedObject] = []
    var doneToolbar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.tblView.allowsMultipleSelection = false
        addDoneButtonOnKeyboard()
    }
    
    func addDoneButtonOnKeyboard(){
        doneToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        
    }

    //MARK: - toolBarDone Button
    @objc func doneButtonAction(){
        self.resignFirstResponder()
      //  self.view.endEditing(true)
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
          return
      }
      
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "Contacts")
      
      do {
        people = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
        
        print(people)
    }


    //MARK: - add Button
    @IBAction func addAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add New", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Name"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
             textField.placeholder = "Enter Mobile No"
             textField.keyboardType = UIKeyboardType.phonePad
            textField.inputAccessoryView = self.doneToolbar
         }
         
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let secondTextField = alertController.textFields![1] as UITextField
            
            if firstTextField.text?.isEmpty ?? false{
                return
            }else if secondTextField.text?.isEmpty ?? false{
                return
            }else{
            
                self.save(name: firstTextField.text ?? "", mobNo: secondTextField.text ?? "")
                self.tblView.reloadData()
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
 
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Save //MARK: -
    func save(name:String,mobNo:String) {
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      let entity =
        NSEntityDescription.entity(forEntityName: "Contacts",
                                   in: managedContext)!
      
      let person = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      
      person.setValue(name, forKeyPath: "name")
      person.setValue(mobNo, forKeyPath: "mobileno")
      
      do {
        try managedContext.save()
        people.append(person)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }

    //MARK: - Delete
    func deleteContact(index:Int){
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
               NSFetchRequest<NSManagedObject>(entityName: "Contacts")
        
        do{
            let test = try managedContext.fetch(fetchRequest)
            let delete_obj = test[index] //as! NSManagedObject
            managedContext.delete(delete_obj)
            
            
            do{
                try managedContext.save()
            }catch{
                print(error)
            }
            
        }catch{
           print(error)
        }
        
    }
    
    //MARK: - Update
    func updateContact(index:Int,name:String,mobNo:String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
          
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
          
        let fetchRequest =
                 NSFetchRequest<NSManagedObject>(entityName: "Contacts")
          
        do{
            let test = try managedContext.fetch(fetchRequest)
            let update_Obj = test[index] //as! NSManagedObject
            update_Obj.setValue(name, forKey: "name")
            update_Obj.setValue(mobNo, forKey: "mobileno")
                 
            do{
                try managedContext.save()
            }catch{
                print(error)
            }
                 
        }catch{
            print(error)
        }
        
        
    }
    
    //MARK: - uitableviewDelegate datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return people.count
        
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
             let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! listCell
        
        let person = people[indexPath.row]
           
        cell.name?.text = (person as AnyObject).value(forKeyPath: "name") as? String // person["name"] as? String ?? ""
        cell.mobNo?.text = (person as AnyObject).value(forKeyPath: "mobileno") as? String
         
             return cell
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         let person = people[indexPath.row]
        
        let alertController = UIAlertController(title: "Edit", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Name"
            textField.text = (person as AnyObject).value(forKeyPath: "name") as? String
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Mobile No"
            textField.keyboardType = UIKeyboardType.phonePad
            textField.text = (person as AnyObject).value(forKeyPath: "mobileno") as? String
             textField.inputAccessoryView = self.doneToolbar
        }
                 
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
        let firstTextField = alertController.textFields![0] as UITextField
        let secondTextField = alertController.textFields![1] as UITextField
                    
        if firstTextField.text?.isEmpty ?? false{
            return
        }else if secondTextField.text?.isEmpty ?? false{
            return
        }else{
                    
            self.updateContact(index:indexPath.row,name: firstTextField.text ?? "", mobNo: secondTextField.text ?? "")
           self.tblView.reloadData()
        }
                    
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
        (action : UIAlertAction!) -> Void in })
         
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
                
        self.present(alertController, animated: true, completion: nil)
         
     }
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

           if editingStyle == .delete {

               // remove the item from the data model
            people.remove(at: indexPath.row)
            deleteContact(index: indexPath.row)
               // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)

           } else if editingStyle == .insert {
               // Not used in our example, but if you were adding a new row, this is where you would do it.
           }
       }
    
}

