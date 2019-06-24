//
//  Titles.swift
//  FirestorePlayground
//
//  Created by Lyunho Kim on 21/06/2019.
//  Copyright © 2019 Lyunho Kim. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Title {
    var firebaseDocId: String?
    var mainTitle: String?
    var subTitle: String?
    
    
    init(_ data: QueryDocumentSnapshot) {
        let documentData = data.data()
        
        self.firebaseDocId = data.documentID
        self.mainTitle = documentData["mainTitle"] as? String
        self.subTitle = documentData["subTitle"] as? String
        
        
    }
    
    
    init(_ doc: (key: String, value: Any)) {
        
        self.mainTitle = doc.key
        self.subTitle = doc.value as? String
    }
    
    
}
