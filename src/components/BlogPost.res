type scroll_direction = Up(float) | Down(float) | Unknown_dir // each breanch saves the last known scroll position

@react.component
let make = (~id: string) => {
    let (post_details, set_post_details) = React.useState(_ => None)
    let (titles, set_titles) = React.useState(_ => [])
    let (markdown, set_markdown) = React.useState(_ => None)
    let (markdown_rendered_check, check_markdown_rendered) = React.useState(_ => None)
    let (current_p_title, set_current_p_title) = React.useState(_ => None)
    let (current_p_index, set_current_p_index) = React.useState(_ => None)
    let (article_read, set_article_read) = React.useState(_ => 0)
    let scroll_direction = React.useRef(Unknown_dir)

    let title_to_anchor = (title: string): string => {
        title->Js.String2.toLowerCase->Js.String2.replaceByRe(%re("/\s+/g"), "-")
    }

    let handle_scroll = (ev: ReactEvent.UI.t) => {
        // sets the percentage of the article read until now
        let height = ReactEvent.UI.target(ev)["scrollHeight"]->Js.Int.toFloat -. ReactEvent.UI.target(ev)["clientHeight"]->Js.Int.toFloat
        let scrolled = ReactEvent.UI.target(ev)["scrollHeight"]->Js.Int.toFloat -. ReactEvent.UI.target(ev)["clientHeight"]->Js.Int.toFloat -. ReactEvent.UI.target(ev)["scrollTop"]->Js.Int.toFloat
        let percentage_read = (((height -. scrolled) /. height) *. 100.0)->Belt.Float.toInt
        set_article_read(_ => percentage_read)
        // saves scroll direction
        let new_scroll_direction =
            switch scroll_direction.current {
                | Up(prev_scroll) => {
                    if prev_scroll > scrolled {
                        // user is scrolling down
                        Down(scrolled)
                    } else {
                        Up(scrolled)
                    }
                }
                | Down(prev_scroll) => {
                    if prev_scroll > scrolled {
                        // user is scrolling down
                        Down(scrolled)
                    } else {
                        Up(scrolled)
                    }
                }
                | Unknown_dir => {
                    // initial value before any scroll happened
                    Down(scrolled)
                }
            }
        scroll_direction.current = new_scroll_direction
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
            set_markdown(_ => Some(markdown))  

            // setting up the Intersection Observer API
            let interval = Utils.set_interval(() => {
                open Utils
                switch document->query_selector(".blogpost_body")->Js.Nullable.toOption {
                    | None => "No .blogpost_body"->Js.log
                    | Some(_) => set_current_p_title(_ => Some(""))
                }
            }, 500)
            check_markdown_rendered(_ => Some(interval))
        }

        let _ = init()

        None
    })

    React.useEffect(() => {
        switch (current_p_title, markdown_rendered_check) {
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
                                ->Js.Array2.mapi((el, index) => {
                                    el->Dom_element.set_attribute("id", el->Dom_element.text_content->title_to_anchor)
                                    el->Dom_element.set_attribute("data-order", "title-" ++ index->Belt.Int.toString)
                                })
                            // setting up the observer
                            let observer_options: IntersectionObserver.observer_options = {
                                root: None,
                                rootMargin: "0px",
                                threshold: 1.0
                            }
                            let callback: (array<IntersectionObserver.entry>, IntersectionObserver.t) => () = 
                                (entries, _) => {
                                    let _ = entries->Js.Array2.map(entry => {
                                        if entry.isIntersecting {
                                            // finds the title index
                                            let p_title = entry.target->Dom_element.text_content
                                            let index = titles->Js.Array2.findIndex(el => el === p_title)
                                            if index !== -1 {
                                                set_current_p_index(_ => Some(index))
                                                set_current_p_title(_ => Some(p_title))                                                 
                                            }                                            
                                        } else if !entry.isIntersecting && entry.target->Dom_element.id === titles[0]->title_to_anchor {
                                            // user is scrolling back to the top
                                            switch scroll_direction.current {
                                                | Up(_) => {
                                                    // resets right column when user passes the first title
                                                    set_current_p_index(_ => None)
                                                    set_current_p_title(_ => None)
                                                }
                                                | _ => ()
                                            }                                            
                                        } else {
                                            switch scroll_direction.current {
                                                | Up(_) => {
                                                    // data-order has format `title-{index}`
                                                    let data_order = 
                                                        switch entry.target->Dom_element.get_attribute("data-order")->Js.Nullable.toOption {
                                                            | None => -1
                                                            | Some(data_order) => {
                                                                let order = data_order->Js.String2.split("-")
                                                                if order->Js.Array2.length === 2 {
                                                                    switch order[1]->Belt.Int.fromString {
                                                                        | None => -1
                                                                        | Some(res) => res
                                                                    }
                                                                } else {
                                                                    -1
                                                                }
                                                            }
                                                        }
                                                        if data_order !== -1 && data_order < titles->Js.Array2.length {
                                                            set_current_p_index(_ => Some(data_order - 1))
                                                            set_current_p_title(_ => Some(titles[data_order - 1]))  
                                                        }
                                                }
                                                | _ => ()
                                            }
                                        }
                                    })
                                    ()
                                }

                            let observer = IntersectionObserver.new(callback, observer_options)
                            let _ = 
                                root
                                ->query_selector_all("h1")
                                ->Js.Array2.from
                                ->Js.Array2.map(el => IntersectionObserver.observe(observer, el))

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

    <div 
        className="blogpost" 
        id="blogpost" 
        onScroll=(handle_scroll)
    >
        <div className="blogpost__left-column">
            {
                switch post_details {
                    | Some(post) =>
                        <div>
                            <p>
                            <span>{"Share"->React.string}</span>
                            <br />
                            <Utils.TwitterShare 
                                url={
                                    open Utils
                                    Window.window->Window.location->Window.href
                                }
                                title={post.data.title ++ " by @claudebarde\n"}
                                hashtags=post.data.tags
                            >
                                <Utils.TwitterShareIcon size=40 round=true />
                            </Utils.TwitterShare>
                            </p>
                        </div>
                    | None => React.null
                }
            }
        </ div>
        {
            switch post_details {
                | None => <div>{"Loading"->React.string}</div>
                | Some(details) => 
                    <div className="blogpost__middle-column">
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
        <div className="blogpost__right-column">
            <div>
                <p id="percentage-read">
                    {article_read->React.int} {"\u00A0% read"->React.string}
                </p>
                <p id="current-paragraph">
                    <span>
                        {
                            switch current_p_index {
                                | None => React.null
                                | Some(i) => ("Part\u00A0" ++ (i + 1)->Js.Int.toString ++ ":")->React.string
                            }
                        }
                    </span>
                    <br />
                    <span>
                        {
                            switch current_p_title {
                                | None => React.null
                                | Some(p) => p->React.string
                            }
                        }
                    </span>
                </p>
            </div>
        </div>
    </div>
}