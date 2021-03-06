//
//  ViewController.swift
//  ListaCoreData
//
//  Created by marco alonso on 23/12/20.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let tableview: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    } ()
    
    private var models = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lista de Pendientes"
        getAllItems()
        view.addSubview(tableview)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc private func didTapAdd(){
        let alert = UIAlertController(title: "Nueva tarea", message: "Ingresa la nueva tarea", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            
            self?.createItem(name: text)
            
        }))
        present(alert, animated: true)
    }
    
    
    //MARK:- TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name //"\(model.name!) - \(model.createdAt!)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "Editar", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Editar", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Editar Tarea", message: "Editar tu tarea", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Guardar", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                
                self?.updateItem(item: item, newName: newName)
                
            }))
            self.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Eliminar", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))
        
        present(sheet, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let eliminarAction = UIContextualAction(style: .destructive, title: "Eliminar") {  (contextualAction, view, boolValue) in
            self.deleteItem(item: self.models[indexPath.row])
        }
        
        let editarAction = UIContextualAction(style: .normal, title: "Editar") {  (contextualAction, view, boolValue) in
            
            let item = self.models[indexPath.row]
            
            let alert = UIAlertController(title: "Editar Tarea", message: "Editar tu tarea", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Guardar", style: .cancel, handler: { [weak self] _ in
                
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                self?.updateItem(item: item, newName: newName)
            }))
            self.present(alert, animated: true)
        }
      let swipeActions = UISwipeActionsConfiguration(actions: [eliminarAction, editarAction])
      return swipeActions
  }
    
    // MARK: - Core Data
    func getAllItems () {
        do {
             models = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        } catch {
            // error
        }
    }
    
    func createItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // error
        }
    }
    
    func deleteItem(item: ToDoListItem) {
        context.delete(item)
        do {
            try context.save()
            getAllItems()
        } catch {
            // error
        }

    }
    
    func updateItem(item: ToDoListItem, newName: String) {
        item.name = newName
        do {
            try context.save()
            getAllItems()
        } catch {
            // error
        }
    }

}

