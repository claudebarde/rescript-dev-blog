@react.component
let make = () => {
    let initial_docs: array<Firestore.doc_with_id> = []
    let (last_posts, set_last_posts) = React.useState(_ => initial_docs)
    let (featured_post, set_featured_post) = React.useState(_ => None)

    React.useEffect0(() => {
        let fetch_docs = async () => {
            // fetches featured article
            let featured_post = switch await Utils.fetch_preview_featured() {
                | data => data
                | exception JsError(_) => None
            }
            set_featured_post(_ => featured_post)
            // fetches previews
            let docs = switch await Utils.fetch_previews() {
                | data => switch data {
                    | None => []
                    | Some(val) => val
                }
                | exception JsError(_) => []
            }
            // removes featured article from array if any
            let docs =
                switch featured_post {
                    | Some(f_post) => docs->Js.Array2.filter(doc => doc.id !== f_post.id)
                    | None => docs
                }
            // setTimeout is used to let the initial animation play for x seconds
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
            {
                switch featured_post {
                    | Some(post) => {
                        <>
                            <h1>{"Featured article"->React.string}</h1>
                            <div className="home__blogposts-preview">
                                <BlogPostPreview key=post.id post preview_pos=0 has_animation=true />
                            </div>
                        </>
                    }
                    | None => React.null
                }
            }
            <h1>{"Latest posts"->React.string}</h1>
            <div className="home__blogposts-preview">
                {
                    last_posts
                    ->Js.Array2.mapi((post, index) => <BlogPostPreview key=post.id post preview_pos=index has_animation=true />)
                    ->React.array
                }
            </div>
        </div>
    }
    
}