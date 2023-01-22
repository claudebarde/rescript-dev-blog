@react.component
let make = () => {
    let url = RescriptReactRouter.useUrl()

    let (last_posts, set_last_posts) = React.useState(_ => Context.state.last_posts)
    let (featured_post, set_featured_post) = React.useState(_ => Context.state.featured_post)
    let (code_theme, set_code_theme) = React.useState(_ => Context.state.code_theme)

    <main>
        <Context.Provider 
            value={
                last_posts, 
                set_last_posts,
                featured_post,
                set_featured_post,
                code_theme,
                set_code_theme
            }
            >
        <Sidebar />
            {
                switch url.path {
                | list{"blogpost", id, _} => <BlogPost id />
                | list{"contact"} => <Contact />
                | list{"articles", tag} => <Articles tag />
                | list{} => <Home />
                | _ => <PageNotFound />
                }
            }
        </Context.Provider>        
    </main>
}