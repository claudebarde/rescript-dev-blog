type firestore = {
    app: Firebase.firebaseApp,
    @as("type") type_: string
}

type doc_snapshot_reference
type collection_reference
type query_constraint
type timestamp = {nanoseconds: float, seconds: float}
type document = {
  title: string,
  subtitle: string,
  header: string,
  timestamp: timestamp,
  tags: array<string>
}
type doc_with_id = {
  id: string,
  data: document
}

module DocSnapshot = {
  type t

  @send external exists: t => bool = "exists"
  @get external id: t => string = "id"
  @send external data: t => document = "data"
}

module QuerySnapshot = {
  type t

  @get external docs: t => array<DocSnapshot.t> = "docs"
  @get external size: t => int = "size"
}

@module("firebase/firestore") external get_firestore: (Firebase.firebaseApp) => firestore = "getFirestore"
@module("firebase/firestore") external collection: (firestore, string) => collection_reference = "collection"
@module("firebase/firestore") external get_docs: collection_reference => Js.Promise.t<QuerySnapshot.t> = "getDocs"
@module("firebase/firestore") external get_doc: doc_snapshot_reference => Js.Promise.t<DocSnapshot.t> = "getDoc"
@module("firebase/firestore") external doc: (firestore, string, string) => doc_snapshot_reference = "doc"

@module("firebase/firestore") @variadic external query: (collection_reference, array<query_constraint>) => collection_reference = "query"
@module("firebase/firestore") @variadic external order_by: array<string> => query_constraint = "orderBy"
@module("firebase/firestore") external limit: int => query_constraint = "limit"
@module("firebase/firestore") external where_string: (string, string, string) => query_constraint = "where"
@module("firebase/firestore") external where_bool: (string, string, bool) => query_constraint = "where"