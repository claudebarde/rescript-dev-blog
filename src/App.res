@react.component
let make = () => {
  React.array([
      <Header key={"header-el"} />,
      <Body key={"body-el"} />,
      <MobileLinks key={"mobile-links"} />,
      <Footer key={"footer-el"} />
    ])
}