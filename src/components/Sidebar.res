@module("../img/twitter-black.svg") external twitter_black: string = "default"
@module("../img/contact-icons/github.svg") external github_black: string = "default"

@react.component
let make = () => {
    <aside>
        <Introduction />
        <button>{"Tezos development"->React.string}</button>
        <button>{"Front-end development"->React.string}</button>
        <hr />
        <a 
            href="https://github.com/claudebarde/rescript-dev-blog"
            target="_blank"
            rel="noopener noreferrer nofollow"
        >
                <span>{"Check the code of this blog"->React.string}</span>
                <img src={github_black} alt="Github logo" />
        </a>
        <a 
            href="https://www.twitter.com/claudebarde"
            target="_blank"
            rel="noopener noreferrer nofollow"
        >
                <span>{"Follow me on Twitter"->React.string}</span>
                <img src={twitter_black} alt="Twitter logo" />
        </a>
    </aside>
}