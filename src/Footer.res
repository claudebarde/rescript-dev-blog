@react.component
let make = () => {
    <footer>
        <span>{"Written with love and\u00A0"->React.string}</span>
        <a 
            href="https://rescript-lang.org/"
            target="_blank"
            rel="noopener noreferrer nofollow"
        >
            {"ReScript"->React.string}
        </a>
    </footer>
}