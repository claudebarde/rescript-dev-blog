@react.component
let make = (~id: string) => {
    <div>{"Blog post id:"->React.string} {id->React.string}</div>
}