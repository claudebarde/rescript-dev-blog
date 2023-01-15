@react.component
let make = () => {
    let initial_docs: array<Firestore.doc_with_id> = []
    let (last_posts, set_last_posts) = React.useState(_ => initial_docs)

    React.useEffect0(() => {
        let fetch_docs = async () => {
            let docs = switch await Utils.fetch_previews() {
                | data => switch data {
                    | None => []
                    | Some(val) => val
                }
                | exception JsError(_) => []
            }
            Js.Global.setTimeout(() => set_last_posts(_ => docs), 2000)            
        }

        let _ = fetch_docs()
        
        None
    })

    if last_posts->Js.Array2.length == 0 {
        <div className="loading-home">
            <div>
                // https://www.rareprogrammer.com/bouncing-cube-css-loader/
                <div className="cube-wrapper">
                    <div className="cube">
                        <div className="cube-faces">
                            <div className="cube-face shadow"></div>
                            <div className="cube-face bottom"></div>
                            <div className="cube-face top"></div>
                            <div className="cube-face left"></div>
                            <div className="cube-face right"></div>
                            <div className="cube-face back"></div>
                            <div className="cube-face front"></div>
                        </div>
                    </div>
                </div>
                <div 
                    style={ReactDOM.Style.make(~marginTop="100px", ())}
                >
                    {"Loading..."->React.string}
                </div>
            </div>
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