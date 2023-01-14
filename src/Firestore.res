type firestore = {
    app: Firebase.firebaseApp,
    @as("type") type_: string
}

type collection_reference
type query_constraint
type document_metadata

module DocSnapshot = {
  type t

  @get external exists: t => bool = "exists"
  @get external id: t => string = "id"
  @send external data: (t, unit) => 'a = "data"
}

module QuerySnapshot = {
  type t

  @get external docs: t => array<DocSnapshot.t> = "docs"
  @get external size: t => int = "size"
}

@module("firebase/firestore") external get_firestore: (Firebase.firebaseApp) => firestore = "getFirestore"
@module("firebase/firestore") external collection: (firestore, string) => collection_reference = "collection"
@module("firebase/firestore") external get_docs: collection_reference => Js.Promise.t<QuerySnapshot.t> = "getDocs"
@module("firebase/firestore") external doc: (firestore, string, string) => DocSnapshot.t = "doc"

@module("firebase/firestore") @variadic external query: (collection_reference, array<query_constraint>) => collection_reference = "query"
@module("firebase/firestore") external order_by: string => query_constraint = "orderBy"
@module("firebase/firestore") external limit: int => query_constraint = "limit"
// @module("firebase/firestore") external where: string => 