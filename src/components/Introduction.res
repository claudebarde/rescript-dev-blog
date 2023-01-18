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
        <div className="intro-card__languages">
            <p>{"My favorite languages/frameworks:"->React.string}</p>
            <ul>
                <li><img src=rust_logo alt="Rust logo" />{"Rust"->React.string}</li>
                <li><img src=svelte_logo alt="Svelte logo" />{"Svelte"->React.string}</li>
                <li><img src=rescript_logo alt="ReScript logo" />{"ReScript"->React.string}</li>
                <li><img src=michelson_logo alt="Michelson logo" />{"Michelson"->React.string}</li>
            </ul>
        </div>
    </div>
}