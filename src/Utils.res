let fetch_docs = async (collection_name: string): option<array<Firestore.doc_with_id>> => {
    open Firebase
    open Firestore
    // creates Firebase app instance
    let app = initialize_app(firebase_config)
    // creates Firestore instance
    let db = get_firestore(app)
    // creates the collection instance
    let collection_ref = collection(db, collection_name)
    // let get_query_snapshots = async (coll) => {
    //     let q = query(coll, [order_by(["timestamp", "desc"]), limit(4)])
    //     let query_snapshots = await get_docs(q)
    //     query_snapshots->QuerySnapshot.size->Js.log
    //     let docs_array = query_snapshots->QuerySnapshot.docs
    //     if docs_array->Js.Array2.length > 0 {
    //         docs_array->Js.Array2.map(doc => {id: doc->DocSnapshot.id, data: doc->DocSnapshot.data})->Some
    //     } else {
    //         None
    //     }
    // }
    // gets the snapshots
    let q = query(collection_ref, [order_by(["timestamp", "desc"]), limit(4)])
    let query_snapshots = await get_docs(q)
    //query_snapshots->QuerySnapshot.size->Js.log
    let docs_array = query_snapshots->QuerySnapshot.docs
    if docs_array->Js.Array2.length > 0 {
        docs_array->Js.Array2.map(doc => {id: doc->DocSnapshot.id, data: doc->DocSnapshot.data})->Some
    } else {
        None
    }
}