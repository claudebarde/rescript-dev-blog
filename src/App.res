@react.component
let make = () => {

  React.useEffect0(() => {
    open Firebase
    open Firestore
    // creates Firebase app instance
    let app = initialize_app(firebase_config)
    app.name->Js.log
    // creates Firestore instance
    let db = get_firestore(app)
    // creates the collection instance
    let collection_ref = collection(db, "posts")
    // gets the snapshots
    let get_query_snapshots = async (coll) => {
      let q = query(coll, [order_by("timestamp"), limit(5)])
      let query_snapshots = await get_docs(q)
      query_snapshots->QuerySnapshot.size->Js.log
    }

    let _ = get_query_snapshots(collection_ref)
    
    None
  })

  React.array([
    <Header key={"header-el"} />,
    <Body key={"body-el"} />,
    <Footer key={"footer-el"} />
  ])
}