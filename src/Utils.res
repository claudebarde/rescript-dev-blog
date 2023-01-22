module SyntaxHighlighterTheme = {
    type t

    @module("react-syntax-highlighter/dist/esm/styles/prism/dark") external dark: t = "default"
    @module("react-syntax-highlighter/dist/esm/styles/prism/atom-dark") external atom_dark: t = "default"
    @module("react-syntax-highlighter/dist/esm/styles/prism/night-owl") external night_owl: t = "default"
    @module("react-syntax-highlighter/dist/esm/styles/prism/one-dark") external one_dark: t = "default"
    @module("react-syntax-highlighter/dist/esm/styles/prism/material-dark") external material_dark: t = "default"
    @module("react-syntax-highlighter/dist/esm/styles/prism/material-light") external material_light: t = "default"
}

module SyntaxHighlighter = {
    @react.component @module("react-syntax-highlighter")
    external make: (
        ~children: React.element,
        ~language: string,
        ~style: SyntaxHighlighterTheme.t
    ) => React.element = "Prism"
}


module Markdown = {
    type code_args = {
        // inline: bool, 
        className: option<string>, 
        children: React.element
    }
    type components = {
        code: code_args => React.element
    }

    @react.component @module("react-markdown")
    external make: (
            ~children: React.element, 
            ~linkTarget: option<string>, 
            ~className: option<string>,
            ~components: option<components>
        ) => React.element = "default"
}

module TwitterShare = {
    @react.component @module("react-share")
    external make: (
        ~children: React.element,
        ~url: string,
        ~title: string,
        ~hashtags: array<string>
    ) => React.element = "TwitterShareButton"
}
module TwitterShareIcon = {
    @react.component @module("react-share")
    external make: (
        ~size: int,
        ~round: bool
    ) => React.element = "TwitterIcon"
}
module FacebookShare = {
    @react.component @module("react-share")
    external make: (
        ~children: React.element,
        ~url: string,
        ~quote: string,
        ~hashtags: array<string>
    ) => React.element = "FacebookShareButton"
}
module FacebookShareIcon = {
    @react.component @module("react-share")
    external make: (
        ~size: int,
        ~round: bool
    ) => React.element = "FacebookIcon"
}
module LinkedinShare = {
    @react.component @module("react-share")
    external make: (
        ~children: React.element,
        ~url: string,
        ~title: string,
        ~summary: string,
        ~source: string
    ) => React.element = "LinkedinShareButton"
}
module LinkedinShareIcon = {
    @react.component @module("react-share")
    external make: (
        ~size: int,
        ~round: bool
    ) => React.element = "LinkedinIcon"
}

module Window = {
    type t = Dom.window
    type location = { href: string }
    
    @val external window: t = "window"
    @get external location: t => location = "location"
    @get external href: location => string = "href"
}

module Dom_element = {
    type t = Dom.element
    type bounding_client_rect = {
        x: float,
        y: float,
        width: float,
        height: float
    }

    @get external text_content: t => string = "textContent"
    @get external id: t => string = "id"
    @get external scroll_top: t => int = "scrollTop"
    @get external offset_height: t => int = "offsetHeight"
    @get external offset_width: t => int = "offsetWidth"
    @get external client_height: t => int = "clientHeight"
    @get external client_width: t => int = "clientWidth"
    @get external height: t => int = "height"
    @get external width: t => int = "width"
    @send external get_bounding_client_rect: t => bounding_client_rect = "getBoundingClientRect"
    @send external set_attribute: (t, string, string) => unit = "setAttribute"
    @send external get_attribute: (t, string) => Js.Nullable.t<string> = "getAttribute"
}
@val external document: Dom.document = "document"
@send external query_selector: ('a, string) => Js.Nullable.t<Dom_element.t> = "querySelector"
@send external query_selector_all: ('a, string) => Js.Array2.array_like<Dom_element.t> = "querySelectorAll"
@val external set_interval: (unit => unit, int) => float = "setInterval"
@val external clear_interval: float => unit = "clearInterval"
@val external set_timeout: (unit => unit, int) => float = "setTimeout"

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
        docs_array->Js.Array2.map(doc => {id: doc->DocSnapshot.id->Js.String2.trim, data: doc->DocSnapshot.data})->Some
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

let fetch_posts_by_tags = async (tags: array<string>, multiple_tags: bool): option<array<Firestore.doc_with_id>> => {
    open Firebase
    open Firestore
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
            ->Js.Array2.map(doc => { id: doc->DocSnapshot.id, data: doc->DocSnapshot.data })
            ->Some
        } else {
            None
        }
    }
}