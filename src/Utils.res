module SyntaxHighlighterTheme = {
    type t

    @module("react-syntax-highlighter/dist/esm/styles/prism/dark") external dark: t = "default"
    @module("react-syntax-highlighter/dist/esm/styles/prism/atom-dark") external atom_dark: t = "default"
    @module("react-syntax-highlighter/dist/esm/styles/prism/night-owl") external night_owl: t = "default"
    @module("react-syntax-highlighter/dist/esm/styles/prism/one-dark") external one_dark: t = "default"
    @module("react-syntax-highlighter/dist/esm/styles/prism/material-dark") external material_dark: t = "default"
    @module("react-syntax-highlighter/dist/esm/styles/prism/material-light") external material_light: t = "default"
}

module SyntaxHighlighter = {
    @react.component @module("react-syntax-highlighter")
    external make: (
        ~children: React.element,
        ~language: string,
        ~style: SyntaxHighlighterTheme.t
    ) => React.element = "Prism"
}


module Markdown = {
    type code_args = {
        // inline: bool, 
        className: option<string>, 
        children: React.element
    }
    type components = {
        code: code_args => React.element
    }

    @react.component @module("react-markdown")
    external make: (
            ~children: React.element, 
            ~linkTarget: option<string>, 
            ~className: option<string>,
            ~components: option<components>
        ) => React.element = "default"
}

module TwitterShare = {
    @react.component @module("react-share")
    external make: (
        ~children: React.element,
        ~url: string,
        ~title: string,
        ~hashtags: array<string>
    ) => React.element = "TwitterShareButton"
}
module TwitterShareIcon = {
    @react.component @module("react-share")
    external make: (
        ~size: int,
        ~round: bool
    ) => React.element = "TwitterIcon"
}
module FacebookShare = {
    @react.component @module("react-share")
    external make: (
        ~children: React.element,
        ~url: string,
        ~quote: string,
        ~hashtags: array<string>
    ) => React.element = "FacebookShareButton"
}
module FacebookShareIcon = {
    @react.component @module("react-share")
    external make: (
        ~size: int,
        ~round: bool
    ) => React.element = "FacebookIcon"
}
module LinkedinShare = {
    @react.component @module("react-share")
    external make: (
        ~children: React.element,
        ~url: string,
        ~title: string,
        ~summary: string,
        ~source: string
    ) => React.element = "LinkedinShareButton"
}
module LinkedinShareIcon = {
    @react.component @module("react-share")
    external make: (
        ~size: int,
        ~round: bool
    ) => React.element = "LinkedinIcon"
}

module ReactHelmet = {
    @react.component @module("react-helmet")
    external make: (
        ~children: React.element,
    ) => React.element = "Helmet"
}