@react.component
let make = (~id: string) => {
    let (post_details, set_post_details) = React.useState(_ => None)
    let (html, set_html) = React.useState(_ => "")

    

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

        // finds the pictures in the Markdown code
        let markdown = MarkdownMockup.test
        let images: array<string> = {
            let rec find_image = (str: string, images: array<string>): array<string> => {
                switch Js.Re.exec_(%re("/!\[\[(.*)\.(png|jpeg|jpg|gif)\]\]/g"), str) {
                    | None => images
                    | Some(matches) => {
                        let capture = matches->Js.Re.captures
                        if capture->Js.Array2.length > 0 {
                            let full_match = capture[0]->Js.Nullable.toOption
                            let img_name = capture[1]->Js.Nullable.toOption
                            let img_ext = capture[2]->Js.Nullable.toOption
                            // pushes the new found image into the array
                            switch (full_match, img_name, img_ext) {
                                | (Some(full_match), Some(img_name), Some(img_ext)) => {
                                    let _ = images->Js.Array2.push(img_name ++ "." ++ img_ext)
                                    // recursive call
                                    find_image(
                                        matches
                                        ->Js.Re.input
                                        ->Js.String2.sliceToEnd(~from=(matches->Js.Re.index + full_match->Js.String2.length)), 
                                        images
                                    )
                                }
                                | _ => images
                            }                            
                        } else {
                            images
                        }
                    }
                }
            }

            find_image(markdown, [])
        }
        images->Js.log
        // renders the HTML
        let rendered_markdown = MarkdownIt.render(MarkdownIt.createMarkdownIt(), markdown)
        let target_blank_links = (str: string): string => {
            str->Js.String2.replaceByRe(%re("/<a href=\"(.*?)\">/g"), "<a href=\"$1\" target=\"_blank\" rel=\"noopener noreferrer nofollow\">")
        }
        let html = rendered_markdown->target_blank_links
        set_html(_ => html)

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