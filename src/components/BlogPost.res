@react.component
let make = (~id: string) => {
    let html = MarkdownIt.render(MarkdownIt.createMarkdownIt(), MarkdownMockup.test)

    <div className="blogpost">
        <h1>
            {"Blog post id:"->React.string} {id->React.string}
        </h1>
        <div dangerouslySetInnerHTML={{"__html": html}} />
    </div>
}