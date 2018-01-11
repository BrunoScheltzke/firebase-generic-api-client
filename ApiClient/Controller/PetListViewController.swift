//
//  PetListViewController.swift
//  ApiClient
//
//  Created by Bruno Scheltzke on 2018-01-10.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class PetListViewController: UIViewController {

    @IBOutlet weak var tableOfPets: UITableView!
    let reusableCell = "petCell"
    
    let petInfoSegue = "petInfoSegue"
    
    var currentUser: Person = LoginManager.shared.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableOfPets.delegate = self
        tableOfPets.dataSource = self
        
        //this should be a decent login, ignore it :)
        LoginManager.shared.login { (result) in
            if case .success(_) = result {
                for pet in self.currentUser.pets {
                    PetManager.shared.ifNeeded(pet, completion: { (result) in
                        if case .success(_) = result {
                            self.tableOfPets.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PetInfoViewController, let pet = sender as? Pet {
            destination.pet = pet
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableOfPets.reloadData()
    }
}

extension PetListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser.pets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableOfPets.dequeueReusableCell(withIdentifier: reusableCell)!
        
        cell.textLabel?.text = currentUser.pets[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            PetManager.shared.remove(currentUser.pets[indexPath.row], completion: nil)
            currentUser.pets.remove(at: indexPath.row)
            PersonManager.shared.save(&currentUser, completion: nil)
            
            tableOfPets.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension PetListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pet = currentUser.pets[indexPath.row]
        performSegue(withIdentifier: petInfoSegue, sender: pet)
    }
}
