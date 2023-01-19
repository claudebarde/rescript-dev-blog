module Markdown = {
  @react.component @module("react-markdown")
  external make: (
        ~children: React.element, 
        ~linkTarget: option<string>, 
        ~className: option<string>
    ) => React.element = "default"
}

module Dom_element = {
    type t = Dom.element

    @get external text_content: t => string = "textContent"
    @get external id: t => string = "id"
    @get external scroll_top: t => int = "scrollTop"
    @send external set_attribute: (t, string, string) => unit = "setAttribute"
    @send external get_attribute: (t, string) => Js.Nullable.t<string> = "getAttribute"
}
@val external document: Dom.document = "document"
@send external query_selector: ('a, string) => Js.Nullable.t<Dom_element.t> = "querySelector"
@send external query_selector_all: ('a, string) => Js.Array2.array_like<Dom_element.t> = "querySelectorAll"
@val external set_interval: (unit => unit, int) => float = "setInterval"
@val external clear_interval: float => unit = "clearInterval"

module IntersectionObserver = {
    type t
    type observer_options = {
        root: option<Dom.element>,
        rootMargin: string,
        threshold: float
    }
    type entry = {
        isIntersecting: bool,
        isVisible: bool,
        target: Dom.element,
        time: float
    }
    type callback = (array<entry>, t) => unit

    @new external new: (callback, observer_options) => t = "IntersectionObserver"
    @send external observe: (t, Dom.element) => unit = "observe"
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

let fetch_preview_featured = async (): option<Firestore.doc_with_id> => {
    open Firebase
    open Firestore
    // creates Firebase app instance
    let app = initialize_app(firebase_config)
    // creates Firestore instance
    let db = get_firestore(app)
    // creates the collection reference
    let collection_ref = collection(db, "previews")
    // builds the query
    let q = query(collection_ref, [where_bool("featured", "==", true)])
    // gets the snapshot
    let doc_snap = await get_docs(q)
    if doc_snap->QuerySnapshot.size === 1 {
        let doc = doc_snap->QuerySnapshot.docs

        { id: doc[0]->DocSnapshot.id, data: doc[0]->DocSnapshot.data }->Some
    } else {
        None
    }
}

let fetch_pictures = async (post_id: string, images: array<string>): option<array<Firebase_Storage.blogpost_img>> => {
    open Firebase
    // creates Firebase app instance
    let app = initialize_app(firebase_config)
    // initializes the cloud storage service
    let storage = Firebase_Storage.get_storage(app)
    // loops through the images to create URLs
    switch await images
        ->Js.Array2.map(img => post_id ++ "/" ++ img)
        ->Js.Array2.map(path => Firebase_Storage.get_download_url(Firebase_Storage.ref(storage, path)))
        ->Js.Promise.all {
            | data => {
                data
                ->Js.Array2.mapi((url, index) => ({ name: images[index], full_path: url }: Firebase_Storage.blogpost_img))
                ->Some
            }
            | exception JsError(_) => None
        }
}

let fetch_posts_by_tag = async (tag: string): option<array<Firestore.DocSnapshot.t>> => {
    open Firebase
    open Firestore
    // creates Firebase app instance
    let app = initialize_app(firebase_config)
    // creates Firestore instance
    let db = get_firestore(app)
    // creates the collection reference
    let collection_ref = collection(db, "previews")
    // builds the query
    let q = query(collection_ref, [where_string("tags", "array-contains", tag), order_by(["timestamp", "desc"])])
    // gets the snapshot
    let doc_snaps = await get_docs(q)
    if doc_snaps->QuerySnapshot.size > 0 {
        doc_snaps->QuerySnapshot.docs->Some
    } else {
        None
    }
}