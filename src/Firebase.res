type firebase
type firebaseConfig = {
  apiKey: string,
  authDomain: string,
  projectId: string,
  storageBucket: string,
  messagingSenderId: string,
  appId: string,
  measurementId: string
}

type firebaseOptions = {
    apiKey: string,
    appId: string,
    authDomain: string,
    databaseURL: string,
    measurementId: string,
    projectId: string,
    storageBucket: string
}
type firebaseApp = {
    name: string,
    options: firebaseOptions
}
@module("firebase/app") external initialize_app: (firebaseConfig) => firebaseApp = "initializeApp"

let firebase_config  = {
  apiKey: "AIzaSyB1A38AIlzmAtNH7OFq8iIuMjJoFa5gZRs",
  authDomain: "dev-blog-467f8.firebaseapp.com",
  projectId: "dev-blog-467f8",
  storageBucket: "dev-blog-467f8.appspot.com",
  messagingSenderId: "1085590877727",
  appId: "1:1085590877727:web:085e2ab8460e931411472a",
  measurementId: "G-CRFQHGRRJH"
};