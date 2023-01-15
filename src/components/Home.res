@react.component
let make = () => {
    let initial_docs: array<Firestore.doc_with_id> = []
    let (last_posts, set_last_posts) = React.useState(_ => initial_docs)

    React.useEffect0(() => {
        let fetch_docs = async () => {
            let docs = switch await Utils.fetch_docs("previews") {
                | data => switch data {
                    | None => []
                    | Some(val) => val
                }
                | exception JsError(_) => []
            }
            set_last_posts(_ => docs)
        }

        let _ = fetch_docs()
        
        None
    })

    if last_posts->Js.Array2.length == 0 {
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