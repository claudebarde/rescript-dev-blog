@react.component
let make = () => {
    let context = React.useContext(Context.context)

    React.useEffect0(() => {
        let fetch_docs = async () => {
            // fetches featured article
            let featured_post = switch await Utils.fetch_preview_featured() {
                | data => data
                | exception JsError(_) => None
            }
            context.set_featured_post(_ => featured_post)
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
            Js.Global.setTimeout(() => context.set_last_posts(_ => docs), 2000)            
        }

        // if context.last_posts->Js.Array2.length === 0 {
        // }
        let _ = fetch_docs()
        
        None
    })

    if context.last_posts->Js.Array2.length == 0 {
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
            <div className="mobile-intro"> <Introduction /> </div>            
            {
                switch context.featured_post {
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
                    context.last_posts
                    ->Js.Array2.mapi((post, index) => <BlogPostPreview key=post.id post preview_pos=index has_animation=true />)
                    ->React.array
                }
            </div>
        </div>
    }
    
}