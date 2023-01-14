@react.component
let make = () => {
  React.array([
      <Header key={"header-el"} />,
      <Body key={"body-el"} />,
      <Footer key={"footer-el"} />
    ])
}