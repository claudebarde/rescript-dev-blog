@react.component
let make = () => {
    let (last_posts, set_last_posts) = React.useState(_ => [])

    React.useEffect0(() => {
        open Firebase
        open Firestore
        // creates Firebase app instance
        let app = initialize_app(firebase_config)
        // creates Firestore instance
        let db = get_firestore(app)
        // creates the collection instance
        let collection_ref = collection(db, "posts")
        // gets the snapshots
        let get_query_snapshots = async (coll) => {
            let q = query(coll, [order_by("timestamp"), limit(4)])
            let query_snapshots = await get_docs(q)
            query_snapshots->QuerySnapshot.size->Js.log
            let docs_array = query_snapshots->QuerySnapshot.docs
            if docs_array->Js.Array2.length > 0 {
                let docs = docs_array->Js.Array2.map(doc => {id: doc->DocSnapshot.id, data: doc->DocSnapshot.data})
                set_last_posts(_ => docs)
            } else {
                ()
            }
        }

        let _ = get_query_snapshots(collection_ref)
        
        None
    })

    
    if last_posts->Js.Array2.length === 0 {
        <div className="home">
            {"Loading"->React.string}
        </div>
    } else {
        <div className="home">
            <h1>{"Latest posts"->React.string}</h1>
            <div className="home__blogposts-preview">
                {
                    last_posts
                    ->Js.Array2.map(post => <BlogPostPreview key=post.id post />)
                    ->React.array
                }
            </div>
        </div>
    }
    
}