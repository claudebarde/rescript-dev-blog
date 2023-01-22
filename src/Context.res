type code_theme = Light | Dark

type state = {
    last_posts: array<Firestore.doc_with_id>,
    set_last_posts: (array<Firestore.doc_with_id> => array<Firestore.doc_with_id>) => unit,
    featured_post: option<Firestore.doc_with_id>,
    set_featured_post: (option<Firestore.doc_with_id> => option<Firestore.doc_with_id>) => unit,
    code_theme: code_theme,
    set_code_theme: (code_theme => code_theme) => unit
}

let state = {
    last_posts: [],
    set_last_posts: _ => (),
    featured_post: None,
    set_featured_post: _ => (),
    code_theme: Dark,
    set_code_theme: _ => ()
}
let context = React.createContext(state)

module Provider = {
    let make = React.Context.provider(context)
}