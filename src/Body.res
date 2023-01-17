@react.component
let make = () => {
    let url = RescriptReactRouter.useUrl()

    <main>
        <Sidebar />
        {
            switch url.path {
            | list{"blogpost", id, _} => <BlogPost id />
            | list{"contact"} => <Contact />
            | list{} => <Home />
            | _ => <PageNotFound />
            }
        }
        
    </main>
}