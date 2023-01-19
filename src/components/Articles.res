@react.component
let make = (~tag: string) => {
    let (docs, set_docs) = React.useState(_ => None)

    React.useEffect1(() => {
        let fetch_docs = async () => {
            let docs = await Utils.fetch_posts_by_tag(tag)
            set_docs(_ => docs)
        }

        let _ = fetch_docs()

        None
    }, [tag])

    <div className="home">
        <h1>{("Articles about\u00A0" ++ tag)->React.string}</h1>
        <div className="home__blogposts-preview">
            {
                switch docs {
                    | Some(articles) => {
                        open Firestore

                        articles
                        ->Js.Array2.map(article => {
                            let post_id = article->DocSnapshot.id
                            let post = { id: post_id, data: article->DocSnapshot.data}
                            <BlogPostPreview key=post_id post preview_pos=0 has_animation=false />
                        })
                        ->React.array
                    }
                    | None => <p>{"No article"->React.string}</p>
                }
            }
        </div>
    </div>
}