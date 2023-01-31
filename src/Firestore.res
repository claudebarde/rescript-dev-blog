type firestore = {
    app: Firebase.firebaseApp,
    @as("type") type_: string
}

type collection_reference
type query_constraint
type timestamp = { nanoseconds: float, seconds: float }

type preview = {
  title: string,
  subtitle: string,
  header: string,
  timestamp: timestamp,
  tags: array<string>,
  ipfs_dir: string
}
type preview_with_id = {
  id: string,
  data: preview
}

type blogpost = {
  body: string
}
type blogpost_with_id = {
  id: string,
  data: blogpost
}

module DocumentReference = {
  type t

  @get external id: t => string = "id"
}

module DocSnapshot = {
  type t

  @send external exists: t => bool = "exists"
  @get external id: t => string = "id"
  @send external preview_data: t => preview = "data"
  @send external blogpost_data: t => blogpost = "data"
}

module QuerySnapshot = {
  type t

  @get external docs: t => array<DocSnapshot.t> = "docs"
  @get external size: t => int = "size"
}

@module("firebase/firestore") external get_firestore: (Firebase.firebaseApp) => firestore = "getFirestore"
@module("firebase/firestore") external collection: (firestore, string) => collection_reference = "collection"
@module("firebase/firestore") external get_docs: collection_reference => Js.Promise.t<QuerySnapshot.t> = "getDocs"
@module("firebase/firestore") external get_doc: DocumentReference.t => Js.Promise.t<DocSnapshot.t> = "getDoc"
@module("firebase/firestore") external doc: (firestore, string, string) => DocumentReference.t = "doc"

@module("firebase/firestore") @variadic external query: (collection_reference, array<query_constraint>) => collection_reference = "query"
@module("firebase/firestore") @variadic external order_by: array<string> => query_constraint = "orderBy"
@module("firebase/firestore") external limit: int => query_constraint = "limit"
@module("firebase/firestore") external where_string: (string, string, string) => query_constraint = "where"
@module("firebase/firestore") external where_strings: (string, string, array<string>) => query_constraint = "where"
@module("firebase/firestore") external where_bool: (string, string, bool) => query_constraint = "where"

let fetch_previews = async (fetch_limit: int): option<array<preview_with_id>> => {
    open Firebase

    // creates Firebase app instance
    let app = initialize_app(firebase_config)
    // creates Firestore instance
    let db = get_firestore(app)
    // creates the collection instance
    let collection_ref = collection(db, "previews")
    // gets the snapshots
    let q = query(collection_ref, [where_bool("visible", "==", true), order_by(["timestamp", "desc"]), limit(fetch_limit)])
    let query_snapshots = await get_docs(q)
    //query_snapshots->QuerySnapshot.size->Js.log
    let docs_array = query_snapshots->QuerySnapshot.docs
    if docs_array->Js.Array2.length > 0 {
        docs_array
        ->Js.Array2.map(
            doc => 
                ({ id: doc->DocSnapshot.id->Js.String2.trim, data: doc->DocSnapshot.preview_data }: preview_with_id)
        )
        ->Some
    } else {
        None
    }
}

let fetch_preview = async (preview_id: string): option<preview_with_id> => {
    open Firebase

    // creates Firebase app instance
    let app = initialize_app(firebase_config)
    // creates Firestore instance
    let db = get_firestore(app)
    // gets the snapshot
    let doc_ref = doc(db, "previews", preview_id)
    let doc_snap = await get_doc(doc_ref)
    if doc_snap->DocSnapshot.exists {
        { id: doc_snap->DocSnapshot.id, data: doc_snap->DocSnapshot.preview_data }->Some
    } else {
        None
    }
}

let fetch_preview_featured = async (): option<preview_with_id> => {
    open Firebase

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

        { id: doc[0]->DocSnapshot.id, data: doc[0]->DocSnapshot.preview_data }->Some
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

let fetch_previews_by_tags = async (tags: array<string>, multiple_tags: bool): option<array<preview_with_id>> => {
    open Firebase

    if tags->Js.Array2.length === 0 {
        None
    } else {
        // creates Firebase app instance
        let app = initialize_app(firebase_config)
        // creates Firestore instance
        let db = get_firestore(app)
        // creates the collection reference
        let collection_ref = collection(db, "previews")
        // builds the query
        let q = {
            if multiple_tags {
                query(collection_ref, [where_strings("tags", "array-contains-any", tags), order_by(["timestamp", "desc"]), limit(2)])
            } else {
                query(collection_ref, [where_string("tags", "array-contains", tags[0]), order_by(["timestamp", "desc"])])
            }
        }
        // gets the snapshot
        let doc_snaps = await get_docs(q)
        if doc_snaps->QuerySnapshot.size > 0 {
            doc_snaps
            ->QuerySnapshot.docs
            ->Js.Array2.map(doc => ({ id: doc->DocSnapshot.id, data: doc->DocSnapshot.preview_data }: preview_with_id))
            ->Some
        } else {
            None
        }
    }
}

let fetch_post_by_id = async (post_id: string): option<blogpost_with_id> => {
    open Firebase

    // creates Firebase app instance
    let app = initialize_app(firebase_config)
    // creates Firestore instance
    let db = get_firestore(app)
    // gets the snapshot
    let q = doc(db, "posts", post_id)
    let doc_snap = await get_doc(q)
    if doc_snap->DocSnapshot.exists {
        { id: doc_snap->DocSnapshot.id, data: doc_snap->DocSnapshot.blogpost_data }->Some
    } else {
        None
    }
}