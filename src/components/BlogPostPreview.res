@react.component
let make = (~post: Firestore.doc_with_id) => {
    <div className="blogpost-preview">
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