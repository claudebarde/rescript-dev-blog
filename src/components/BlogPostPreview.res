@react.component
let make = (~post: Firestore.doc_with_id) => {
    let navigateToPost = _ => {
        let formatted_title = 
            post.data.title
            ->Js.String2.toLowerCase
            ->Js.String2.replaceByRe(%re("/\s+/g"), "-")
        RescriptReactRouter.replace("/blogpost/" ++ post.id ++ "/" ++ formatted_title)
    }

    <div className="blogpost-preview" onClick={navigateToPost}>
        <div>
            <img src={post.data.header} alt="header" />
        </div>
        <div className="blogpost-preview__details">
            <h3 className="blogpost-preview__details__title">{post.data.title->React.string}</h3>
            <h4 className="blogpost-preview__details__subtitle">{post.data.subtitle->React.string}</h4>
            <div>
                {"Posted on:\u00A0"->React.string}
                {
                    (post.data.timestamp.seconds *. 1000.0)
                    ->Js.Date.fromFloat
                    ->Js.Date.toLocaleString
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