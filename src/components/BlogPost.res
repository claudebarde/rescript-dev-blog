@react.component
let make = (~id: string) => {
    let (post_details, set_post_details) = React.useState(_ => None)
    let (titles, set_titles) = React.useState(_ => [])
    let (markdown, set_markdown) = React.useState(_ => None)
    let (markdown_rendered_check, check_markdown_rendered) = React.useState(_ => None)
    let (current_paragraph, set_current_paragraph) = React.useState(_ => None)

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
            // let titles: array<string> = {
            //     let rec find_title = (str: string, titles: array<string>): array<string> => {
            //         switch Js.Re.exec_(%re("/#\s{1}(.*)\n/g"), str) {
            //             | None => titles
            //             | Some(matches) => {
            //                 let capture = matches->Js.Re.captures
            //                 if capture->Js.Array2.length > 0 {
            //                     let title = capture[1]->Js.Nullable.toOption
            //                     // pushes the new found title into the array
            //                     switch title {
            //                         | Some(title) => {
            //                             let _ = titles->Js.Array2.push(title)
            //                             // recursive call
            //                             find_title(
            //                                 matches
            //                                 ->Js.Re.input
            //                                 ->Js.String2.sliceToEnd(~from=(matches->Js.Re.index + title->Js.String2.length)), 
            //                                 titles
            //                             )
            //                         }
            //                         | _ => titles
            //                     }                            
            //                 } else {
            //                     titles
            //                 }
            //             }
            //         }
            //     }

            //     find_title(markdown, [])
            // }
            // set_titles(_ => titles)
            set_markdown(_ => Some(markdown))

            // setting up the Intersection Observer API
            // let interval = Utils.set_interval(() => {
            //     if titles->Js.Array2.length > 0 {
            //         let formatted_titles = titles->Js.Array2.map(title => title->title_to_anchor)

            //         let _ = {
            //             open Utils
            //             switch document->query_selector(".blogpost_body")->Js.Nullable.toOption {
            //                 | None => "No .blogpost_body"->Js.log
            //                 | Some(root) => {
            //                     let observer_options: IntersectionObserver.observer_options = {
            //                         root,
            //                         rootMargin: "0px",
            //                         threshold: 1.0
            //                     }
            //                     let callback = (entries, observer) => entries->Js.log

            //                     let observer = IntersectionObserver.new(callback, observer_options)
            //                     let target = document->query_selector("#understanding-sapling")->Js.Nullable.toOption
            //                     switch target {
            //                         | None => "No #understanding-sapling"->Js.log
            //                         | Some(target) => {
            //                             target->Js.log
            //                             IntersectionObserver.observe(observer, target)
            //                             set_current_paragraph(_ => Some("#understanding-sapling"))
            //                         }
            //                     }
            //                 }
            //             }
            //         }
            //     }
            // }, 500)
            // check_markdown_rendered(_ => Some(interval))    

            // setting up the Intersection Observer API
            let interval = Utils.set_interval(() => {
                open Utils
                switch document->query_selector(".blogpost_body")->Js.Nullable.toOption {
                    | None => "No .blogpost_body"->Js.log
                    | Some(_) => set_current_paragraph(_ => Some(""))
                }
            }, 500)
            check_markdown_rendered(_ => Some(interval))
        }

        let _ = init()

        None
    })

    React.useEffect(() => {
        switch (current_paragraph, markdown_rendered_check) {
            | (Some(_), Some(interval)) => {
                let _ = Utils.clear_interval(interval)
                let _ = {
                    open Utils
                    switch document->query_selector(".blogpost_body")->Js.Nullable.toOption {
                        | None => "No .blogpost_body"->Js.log
                        | Some(root) => {
                            // searches for titles to build the content table
                            let titles = 
                                root
                                ->query_selector_all("h1")
                                ->Js.Array2.from
                                ->Js.Array2.map(el => el->Dom_element.text_content)
                            set_titles(_ => titles)
                            // adds an id attribute to the titles
                            let _ = 
                                root
                                ->query_selector_all("h1")
                                ->Js.Array2.from
                                ->Js.Array2.map(el => el->Dom_element.set_attribute("id", el->Dom_element.text_content->title_to_anchor))
                            // setting up the observer
                            let observer_options: IntersectionObserver.observer_options = {
                                root,
                                rootMargin: "0px",
                                threshold: 1.0
                            }
                            let callback = (entries, observer) => entries->Js.log

                            let observer = IntersectionObserver.new(callback, observer_options)
                            let target = document->query_selector("#understanding-sapling")->Js.Nullable.toOption
                            switch target {
                                | None => "No #understanding-sapling"->Js.log
                                | Some(target) => {
                                    IntersectionObserver.observe(observer, target)
                                    set_current_paragraph(_ => Some("#understanding-sapling"))
                                }
                            }

                            ()
                        }
                    }
                }
                check_markdown_rendered(_ => None)
            }
            | _ => ()
        }

        None
    })

    <div className="blogpost" id="blogpost">
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
                        <Utils.Markdown linkTarget=Some("_blank") className=Some("blogpost_body")>
                            {
                                switch markdown {
                                    | None => "Loading the article..."
                                    | Some(m) => m
                                }
                                ->React.string
                            }
                        </Utils.Markdown>
                    </div>
            }
        }
        <div>
            <p>
                {
                    switch current_paragraph {
                        | None => React.null
                        | Some(p) => p->React.string
                    }
                }
            </p>
        </div>
    </div>
}