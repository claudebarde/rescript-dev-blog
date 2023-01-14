@react.component
let make = () => {
    <div className="intro-card">
        <div className="intro-card__title">{"Hey, I'm Claude 👋🏻"->React.string}</div>
        <div className="intro-card__description">
            {"I am a DevRel on Tezos, I am interested in front-end dev, smart contracts, 
            decentralized applications and functional programming"->React.string}
        </div>
        <div className="intro-card__languages">
            <span>{"I love coding in"->React.string}</span>
            <br />
            <span>{"ReScript 🐫, Rust 🦀 and Michelson 🌮"->React.string}</span>
        </div>
    </div>
}