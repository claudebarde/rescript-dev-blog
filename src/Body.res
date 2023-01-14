@react.component
let make = () => {
    let url = RescriptReactRouter.useUrl()

    <main>
        <Sidebar />
        {
            switch url.path {
            | list{"blogpost", id} => <BlogPost id />
            | list{} => <Home />
            | _ => <PageNotFound />
            }
        }
        
    </main>
}