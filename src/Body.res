@react.component
let make = () => {
    let url = RescriptReactRouter.useUrl()

    let (last_posts, set_last_posts) = React.useState(_ => Context.state.last_posts)
    let (featured_post, set_featured_post) = React.useState(_ => Context.state.featured_post)

    <main>
        <Context.Provider 
            value={
                last_posts: last_posts, 
                set_last_posts: set_last_posts,
                featured_post: featured_post,
                set_featured_post: set_featured_post
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