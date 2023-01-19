@react.component
let make = (~tag: string) => {
    <button 
        className={"tag" ++ " " ++ tag->Js.String2.toLowerCase}
        onClick={_ => RescriptReactRouter.replace("/articles/" ++ tag)}
    >
        {"#"->React.string}{tag->React.string}
    </button>
}