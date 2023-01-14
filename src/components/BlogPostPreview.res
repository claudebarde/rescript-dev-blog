@react.component
let make = (~post: Firestore.doc_with_id) => {
    <div className="blogpost-preview">
        {"Blog post title:"->React.string} {post.data.title->React.string}
    </div>
}