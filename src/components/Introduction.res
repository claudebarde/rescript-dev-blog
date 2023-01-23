@module("../img/rust-logo-blk.svg") external rust_logo: string = "default"
@module("../img/svelte-logo.svg") external svelte_logo: string = "default"
@module("../img/rescript-logo.png") external rescript_logo: string = "default"
@module("../img/michelson-logo.png") external michelson_logo: string = "default"

@react.component
let make = () => {
    <div className="intro-card">
        <div className="intro-card__title">{"Hey, I'm Claude 👋🏻"->React.string}</div>
        <div className="intro-card__description">
            {"I am a DevRel on Tezos, I am interested in front-end dev, smart contracts, 
            decentralized applications and functional programming"->React.string}
        </div>
        <div>
            <p>{"My favorite languages/frameworks:"->React.string}</p>
            <div className="intro-card__languages">
                <div>
                    <a 
                        href="https://www.rust-lang.org/"
                        target="_blank"
                        rel="noopener noreferrer nofollow"
                         className="intro-card__link"
                    >
                        <img src=rust_logo alt="Rust logo" />{"Rust"->React.string}
                    </a>
                </div>
                <div>
                    <a 
                        href="https://www.svelte.dev/"
                        target="_blank"
                        rel="noopener noreferrer nofollow"
                         className="intro-card__link"
                    >
                        <img src=svelte_logo alt="Svelte logo" />{"Svelte"->React.string}
                    </a>
                </div>
                <div>
                    <a 
                        href="https://rescript-lang.org"
                        target="_blank"
                        rel="noopener noreferrer nofollow"
                         className="intro-card__link"
                    >
                        <img src=rescript_logo alt="ReScript logo" />{"ReScript"->React.string}
                    </a>
                </div>
                <div>
                    <a 
                        href="https://tezos.gitlab.io/active/michelson.html"
                        target="_blank"
                        rel="noopener noreferrer nofollow"
                         className="intro-card__link"
                    >
                        <img src=michelson_logo alt="Michelson logo" />{"Michelson"->React.string}
                    </a>
                </div>
            </div>
        </div>
    </div>
}