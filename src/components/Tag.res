@react.component
let make = (~tag: string) => {
    <div className={"tag" ++ " " ++ tag}>
        {"#"->React.string}{tag->React.string}
    </div>
}