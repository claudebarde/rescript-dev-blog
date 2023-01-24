@module("../img/twitter-black.svg") external twitter_black: string = "default"
@module("../img/contact-icons/github.svg") external github_black: string = "default"

@react.component
let make = () => {
    <div className="mobile-links">
        <a href="#" className="mobile-link" onClick={_ => RescriptReactRouter.replace("/articles")}>
            <span className="material-symbols-outlined">
                {"description"->React.string}
            </span>
        </a>
        <a href="#" className="mobile-link" onClick={_ => RescriptReactRouter.replace("/contact")}>
            <span className="material-symbols-outlined">
                {"mail"->React.string}
            </span>
        </a>
        <a 
            href="https://www.twitter.com/claudebarde"
            target="_blank"
            rel="noopener noreferrer nofollow"
            className="mobile-link"
        >
            <img src={twitter_black} alt="logo" />
        </a>
        <a 
            href="https://github.com/claudebarde/rescript-dev-blog"
            target="_blank"
            rel="noopener noreferrer nofollow"
            className="mobile-link"
        >
            <img src={github_black} alt="logo" />
        </a>
    </div>
}