@react.component
let make = (~tag: option<string>) => {
    let (docs, set_docs) = React.useState(_ => None)

    React.useEffect1(() => {
        let fetch_docs = async () => {
            let docs = 
                switch tag {
                    | Some(tag) => {
                        // articles with a tag in common
                        await Utils.fetch_posts_by_tags([tag], false)
                    }
                    | None => {
                        // all the articles
                        await Utils.fetch_previews(10)
                    }
                }
            set_docs(_ => docs)
        }

        let _ = fetch_docs()

        None
    }, [tag])

    <div className="home">
        <h1>
            {
                switch tag {
                    | None => "All articles"
                    | Some(tag) => ("Articles about\u00A0" ++ tag)
                }
                ->React.string
            }
        </h1>
        <div className="home__blogposts-preview">
            {
                switch docs {
                    | Some(articles) => {
                        open Firestore

                        articles
                        ->Js.Array2.map(article => {
                            <BlogPostPreview key=article.id post=article preview_pos=0 has_animation=false />
                        })
                        ->React.array
                    }
                    | None => <p>{"No article"->React.string}</p>
                }
            }
        </div>
    </div>
}