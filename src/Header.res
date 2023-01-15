@module("./img/claude.png") external logo: string = "default"

@react.component
let make = () => {
    let articlesButton = <button key="articles-nav">{"Articles"->React.string}</button>
    let linksButton = <button key="links-nav">{"Links"->React.string}</button>
    let contactButton = <button key="contact-nav">{"Contact"->React.string}</button>
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
            {"Censorship resistant"->React.string}
        </a>
        <div className="buttons">
            {
                [articlesButton, linksButton, contactButton, searchButton]->React.array
            }
        </div>
    </nav>
  </header>
}