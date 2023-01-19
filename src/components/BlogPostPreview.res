@react.component
let make = (~post: Firestore.doc_with_id, ~preview_pos: int, ~has_animation: bool) => {
    let (is_hovered, set_is_hovered) = React.useState(_ => false)

    let navigateToPost = _ => {
        let formatted_title = 
            post.data.title
            ->Js.String2.toLowerCase
            ->Js.String2.replaceByRe(%re("/\s+/g"), "-")
        RescriptReactRouter.replace("/blogpost/" ++ post.id ++ "/" ++ formatted_title)
    }

    <div 
        className={"blogpost-preview " ++ if has_animation { "animate" } else { "" }}
        style={ReactDOM.Style.make(~animationDelay = (preview_pos * -100)->Belt.Int.toString ++ "ms", ())}
        onMouseEnter={_ => set_is_hovered(_ => true)}
        onMouseLeave={_ => set_is_hovered(_ => false)}
    >
        <div className={"blogpost-preview__image"}>
            {
                if is_hovered {
                    <div className="blogpost-preview__read-button">
                        <button onClick={navigateToPost}>
                            {"Read"->React.string}
                        </button>
                    </div>
                } else {
                    React.null
                }
            }
            <img 
                src={post.data.header} 
                alt="header"
                className={{ if is_hovered { "read" } else { "" } }}
            />
        </div>
        <div className="blogpost-preview__details">
            <h3 className="blogpost-preview__details__title">{post.data.title->React.string}</h3>
            <h4 className="blogpost-preview__details__subtitle">{post.data.subtitle->React.string}</h4>
            <div className="blogpost-preview__details__date">
                {"Posted on:\u00A0"->React.string}
                {
                    (post.data.timestamp.seconds *. 1000.0)
                    ->Js.Date.fromFloat
                    ->Js.Date.toLocaleDateString
                    ->React.string
                }
            </div>
            <div className="tags">
                {
                    React.array(post.data.tags->Js.Array2.map(tag => <Tag key=tag tag />))
                }
            </div>
        </div>
    </div>
}