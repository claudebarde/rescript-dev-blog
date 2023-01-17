@react.component
let make = (~id: string) => {
    let (post_details, set_post_details) = React.useState(_ => None)
    let (html, set_html) = React.useState(_ => "")
    let (titles, set_titles) = React.useState(_ => [])

    let title_to_anchor = (title: string): string => {
        title->Js.String2.toLowerCase->Js.String2.replaceByRe(%re("/\s+/g"), "-")
    }

    React.useEffect0(() => {
        let init = async () => {
            // fetches post details
            let details = switch await Utils.fetch_preview(id) {
                | data => data
                | exception JsError(_) => None
            }
            let _ = set_post_details(_ => details)

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
            // replaces local markdown pictures with full markdown img tags and respective URLs
            let markdown = 
                if images->Js.Array2.length > 0 {
                    // fetches the picture URLs
                    let pictures = switch await Utils.fetch_pictures(id, images) {
                        | data => data
                        | exception JsError(_) => None
                    }
                    switch pictures {
                        | None => markdown
                        | Some(imgs) => {
                            // replaces `![[pic-name]]` with `![pic-name](full-path)`
                            imgs
                            ->Js.Array2.reduce(
                                (markdown, img) => {
                                    let regex = Js.Re.fromString(
                                        "!\\[\\[" ++ 
                                        img.name
                                        ->Js.String2.replaceByRe(%re("/\-/"), "\\-")
                                        ->Js.String2.replaceByRe(%re("/\./"), "\\.") ++ 
                                        "\\]\\]"
                                        )
                                    let replacement = "![" ++ img.name ++ "](" ++ img.full_path ++ ")"
                                    markdown
                                    ->Js.String2.replaceByRe(
                                        regex, 
                                        replacement
                                    )
                                }, 
                                markdown
                            )
                        }
                    }
                } else {
                    markdown
                }
            // searches for titles to build the content table
            let titles: array<string> = {
                let rec find_title = (str: string, titles: array<string>): array<string> => {
                    switch Js.Re.exec_(%re("/#\s{1}(.*)\n/g"), str) {
                        | None => titles
                        | Some(matches) => {
                            let capture = matches->Js.Re.captures
                            if capture->Js.Array2.length > 0 {
                                let title = capture[1]->Js.Nullable.toOption
                                // pushes the new found title into the array
                                switch title {
                                    | Some(title) => {
                                        let _ = titles->Js.Array2.push(title)
                                        // recursive call
                                        find_title(
                                            matches
                                            ->Js.Re.input
                                            ->Js.String2.sliceToEnd(~from=(matches->Js.Re.index + title->Js.String2.length)), 
                                            titles
                                        )
                                    }
                                    | _ => titles
                                }                            
                            } else {
                                titles
                            }
                        }
                    }
                }

                find_title(markdown, [])
            }
            set_titles(_ => titles)
            // renders the HTML
            let rendered_markdown = MarkdownIt.render(MarkdownIt.createMarkdownIt(), markdown)
            // makes links open in a different tab
            let target_blank_links = (str: string): string => {
                str->Js.String2.replaceByRe(%re("/<a href=\"(.*?)\">/g"), "<a href=\"$1\" target=\"_blank\" rel=\"noopener noreferrer nofollow\">")
            }
            // adds anchor links to h1 tags
            let add_anchor_links = (str: string): string => {
                titles
                ->Js.Array2.reduce(
                    (str, title) => {
                        let to_replace = "<h1>" ++ title
                        let replacement = "<h1 id=\"" ++ title->title_to_anchor ++ "\">" ++ title
                        str->Js.String2.replace(to_replace, replacement)
                    },
                    str
                )
            }
            let html = rendered_markdown->target_blank_links->add_anchor_links
            set_html(_ => html)
        }

        let _ = init()
        None
    })

    <div className="blogpost">
        <div />
        {
            switch post_details {
                | None => <div>{"Loading"->React.string}</div>
                | Some(details) => 
                    <div>
                        <h1 className="blogpost__title">
                            {details.data.title->React.string}
                        </h1>
                        <h2>
                            {details.data.subtitle->React.string}
                        </h2>
                        <p className="published-date">
                            {"Published on\u00A0"->React.string}
                            {
                                (details.data.timestamp.seconds *. 1000.0)
                                ->Js.Date.fromFloat
                                ->Js.Date.toLocaleString
                                ->React.string
                            }
                        </p>
                        <img src={details.data.header} alt="header" />
                        <div className="blogpost__content">
                            <p>{"Content"->React.string}</p>
                            <ul>
                                {
                                    titles
                                    ->Js.Array2.map(
                                        title => 
                                            <li key=title>
                                                <a href={"#" ++ title->title_to_anchor}>
                                                    {title->React.string}
                                                </a>
                                            </li>
                                    )
                                    ->React.array
                                }
                            </ul>
                        </div>
                        <div dangerouslySetInnerHTML={{"__html": html}} />
                    </div>
            }
        }
        <div />
    </div>
}