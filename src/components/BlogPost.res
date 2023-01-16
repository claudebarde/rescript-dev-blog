@react.component
let make = (~id: string) => {
    let (post_details, set_post_details) = React.useState(_ => None)

    let html = {
        let rendered_markdown = MarkdownIt.render(MarkdownIt.createMarkdownIt(), MarkdownMockup.test)
        let target_blank_links = (str: string): string => {
            str->Js.String2.replaceByRe(%re("/<a href=\"(.*?)\">/g"), "<a href=\"$1\" target=\"_blank\" rel=\"noopener noreferrer nofollow\">")
        }
        rendered_markdown->target_blank_links
    }

    React.useEffect0(() => {
        // fetches post details
        let fetch_post_details = async () => {
            let details = switch await Utils.fetch_preview(id) {
                | data => data
                | exception JsError(_) => None
            }
            let _ = set_post_details(_ => details)
        }

        let _ = fetch_post_details()

        // fetches pictures
        let fetch_pictures = async () => {
            let pictures = switch await Utils.fetch_pictures(id, ["sapling-flow.png", "sapling-code1.png"]) {
                | data => data
                | exception JsError(_) => None
            }
            pictures->Js.log
        }

        let _ = fetch_pictures()
        
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