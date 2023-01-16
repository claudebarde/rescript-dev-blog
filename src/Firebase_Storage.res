type firebase_storage
type blogpost_img = {
    name: string,
    full_path: string
}

module StorageReference = {
    type t

    @get external name: t => string = "name"
    @get external full_path: t => string = "fullPath"
    @get external root: t => string = "root"
}

@module("firebase/storage") external get_storage: (Firebase.firebaseApp) => firebase_storage = "getStorage"
@module("firebase/storage") external ref: (firebase_storage, string) => StorageReference.t = "ref"
@module("firebase/storage") external get_download_url: (StorageReference.t) => Js.Promise.t<string> = "getDownloadURL"
