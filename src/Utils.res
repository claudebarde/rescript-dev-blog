module Markdown = {
  @react.component @module("react-markdown")
  external make: (~children: React.element) => React.element = "default"
}

let fetch_previews = async (): option<array<Firestore.doc_with_id>> => {
    open Firebase
    open Firestore
    // creates Firebase app instance
    let app = initialize_app(firebase_config)
    // creates Firestore instance
    let db = get_firestore(app)
    // creates the collection instance
    let collection_ref = collection(db, "previews")
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

let fetch_preview = async (preview_id: string): option<Firestore.doc_with_id> => {
    open Firebase
    open Firestore
    // creates Firebase app instance
    let app = initialize_app(firebase_config)
    // creates Firestore instance
    let db = get_firestore(app)
    // gets the snapshot
    let q = doc(db, "previews", preview_id)
    let doc_snap = await get_doc(q)
    if doc_snap->DocSnapshot.exists {
        {id: doc_snap->DocSnapshot.id, data: doc_snap->DocSnapshot.data}->Some
    } else {
        None
    }
}

let fetch_pictures = async (post_id: string, images: array<string>): option<array<Firebase_Storage.blogpost_img>> => {
    open Firebase
    open Firebase_Storage
    // creates Firebase app instance
    let app = initialize_app(firebase_config)
    // initializes the cloud storage service
    let storage = get_storage(app)
    // loops through the images to create URLs
    switch await images
        ->Js.Array2.map(img => post_id ++ "/" ++ img)
        ->Js.Array2.map(path => get_download_url(ref(storage, path)))
        ->Js.Promise.all {
            | data => {
                data
                ->Js.Array2.mapi((url, index) => { name: images[index], full_path: url })
                ->Some
            }
            | exception JsError(_) => None
        }
}