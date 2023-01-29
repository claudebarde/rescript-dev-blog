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