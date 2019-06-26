//
//  ViewController.swift
//  FirestorePlayground
//
//  Created by Lyunho Kim on 19/06/2019.
//  Copyright © 2019 Lyunho Kim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var toolbar: UIToolbar!
    
    let cellIdnetifier = "cellIdnetifier"
    let rootDocument = "mainCollection"
    
    var data: [Title] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        
        
        let db: Firestore = Firestore.firestore()
        
        // Data Access 방법1. 1회성으로 한번만 가져옴
//        db.collection(rootDocument).getDocuments { (querySnapshot, err) in
//
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
//                print("document loading...")
//
//                for doc in querySnapshot.documents {
//                    self.data.append(Title(doc))
//                }
//                self.tableView.reloadData()
//            }
//
//        }
        
        
        // Data Access 방법2. 리스너를 통해서 지속적으로 값 변화 추적 가능
        db.collection(rootDocument).addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let docChanges = querySnapshot?.documentChanges {
                    for docChange in docChanges {
                        // App실행 중에 data 추가될 때 뿐만 아니라, 초기 로딩도 added로 호출됨
                        if docChange.type == .added {
                            self.data.append(Title(docChange.document))
                            print("document added")
                        } else if docChange.type == .modified {
                            print("document modified")
                        } else if docChange.type == .removed {
                            print("document removed")
                        } else {
                            // added, modified, removed 외에는 다른 값 없음. 실행되지 않음.
                            print("document ???")
                        }
                        let document = docChange.document
                        print("\(document.documentID) => \(document.data())")

                    }
                } else {
                    // 실행되지 않음
                    print("document loading...")
                    for document in querySnapshot!.documents {
                        self.data.append(Title(document))
                    }
                }
                print("tableview updating...")
                self.tableView.reloadData()
            }
        }
        
    }
    
    @IBAction func pushedAddButton(_ sender: Any) {
        showInputDialog()
    }
    @IBAction func pushedEditButton(_ sender: Any) {
        
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        toolbar.isHidden = !tableView.isEditing
        
//        if tableView.isEditing {
//            editButton.title = "Edit"
//            tableView.setEditing(false, animated: true)
//        } else {
//            editButton.title = "Cancel"
//            tableView.setEditing(true, animated: true)
//        }
    }
    @IBAction func pushedTrashButton(_ sender: Any) {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            for selectedRow in selectedRows {
                removeTitle(selectedRow.row)
                
                
            }
        }

    }
    
    // 해당 Index에 해당하는 데이터 삭제
    func removeTitle(_ index: Int) {
        if let documentId = data[index].firebaseDocId {
            let db: Firestore = Firestore.firestore()
            db.collection(rootDocument).document(documentId).delete { (err) in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    self.data.remove(at: index)
                    self.tableView.reloadData()
                }
            }
            
        } else {
                print("delete error with Firestore documentId")
        }
    }
    
    func addTitle() {
        
    }
    
    
    func showInputDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter details?", message: "Enter your name and email", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting the input values from user
            let mainTitle = alertController.textFields?[0].text
            let subTitle = alertController.textFields?[1].text
            
            let db: Firestore = Firestore.firestore()
            var ref: DocumentReference? = nil
            ref = db.collection(self.rootDocument).addDocument(data: ["mainTitle": mainTitle!, "subTitle": subTitle!]) { (error) in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
        }
        
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Main Title"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Sub Title"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController {
    
    /* TableView Functions */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdnetifier, for: indexPath)
        
        cell.textLabel?.text = data[indexPath.row].mainTitle!
        cell.detailTextLabel?.text = data[indexPath.row].subTitle!
        
        return cell
    }
}

