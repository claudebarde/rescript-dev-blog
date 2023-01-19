@react.component
let make = () => {
    let url = RescriptReactRouter.useUrl()

    <main>
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
        
    </main>
}