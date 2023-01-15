@bs.deriving(abstract)
type options = {
  @bs.optional html: bool,
  @bs.optional linkify: bool,
  @bs.optional typographer: bool
}

type tMarkdownIt
@bs.new @bs.module external createMarkdownIt: (~options: options=?, unit) => tMarkdownIt = "markdown-it"
let createMarkdownIt = (~html: bool=false, ()) => {
  createMarkdownIt(~options=options(~html, ()), ())
}
@bs.send external render: (tMarkdownIt, string) => string = "render"