@react.component
let make = (~id: string) => {
    let (post_details, set_post_details) = React.useState(_ => None)

    let html = MarkdownIt.render(MarkdownIt.createMarkdownIt(), MarkdownMockup.test)

    React.useEffect0(() => {
        let fetch_post_details = async () => {
            let details = switch await Utils.fetch_preview(id) {
                | data => data
                | exception JsError(_) => None
            }
            let _ = set_post_details(_ => details)
        }

        let _ = fetch_post_details()
        
        None
    })

    <div className="blogpost">
        <div />
        {
            switch post_details {
                | None => <div>{"Loading"->React.string}</div>
                | Some(details) => 
                    <div>
                        <h1>
                            {details.data.title->React.string}
                        </h1>
                        <h2>
                            {details.data.subtitle->React.string}
                        </h2>
                        <img src={details.data.header} alt="header" />
                        <div dangerouslySetInnerHTML={{"__html": html}} />
                    </div>
            }
        }
        <div />
    </div>
}