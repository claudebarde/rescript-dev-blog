@module("./img/claude.png") external logo: string = "default"

@react.component
let make = () => {
    let articlesButton = <button key="articles-nav">{"Articles"->React.string}</button>
    let contactButton = <button key="contact-nav" onClick={_ => RescriptReactRouter.replace("/contact")}>{"Contact"->React.string}</button>
    let searchButton = 
        <button key="search-nav">
            <span className="material-icons">{"search"->React.string}</span>
        </button>

  <header>
    <nav>
        <a href="/" className="logo">
            <img src={logo} alt="logo" />
        </a>
        <a href="/" className="title">
            {"Most Significant Bit"->React.string}
        </a>
        <div className="buttons">
            {
                [articlesButton, contactButton, searchButton]->React.array
            }
        </div>
    </nav>
  </header>
}