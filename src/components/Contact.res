@module("../img/contact-icons/twitter.svg") external twitter_logo: string = "default"
@module("../img/contact-icons/github.svg") external github_logo: string = "default"
@module("../img/contact-icons/medium.svg") external medium_logo: string = "default"
@module("../img/contact-icons/telegram.svg") external telegram_logo: string = "default"
@module("../img/contact-icons/youtube.svg") external youtube_logo: string = "default"
@module("../img/contact-icons/linkedin.svg") external linkedin_logo: string = "default"
@module("../img/contact-icons/discord.svg") external discord_logo: string = "default"

@react.component
let make = () => {
    <div className="contact">
        <div>
            <p>{"Do you want to get in touch?"->React.string}</p>
            <p>{"Do you have questions about front-end or blockchain development?"->React.string}</p>
            <p>{"Don't hesitate to contact me 🙂"->React.string}</p>
            <p>{"Here are the platforms where you can reach me:"->React.string}</p>
            <div className="contact__links">
                <a 
                    href="https://twitter.com/claudebarde"
                    target="_blank"
                    rel="noopener noreferrer nofollow"
                >
                    <img src=twitter_logo alt="twitter-logo" />
                    <span>{"Twitter"->React.string}</span>
                </a>
                <a 
                    href="https://github.com/claudebarde"
                    target="_blank"
                    rel="noopener noreferrer nofollow"
                >                        
                    <img src=github_logo alt="github-logo" />
                    <span>{"GitHub"->React.string}</span>
                </a>
                <a 
                    href="https://www.medium.com/claudebarde/"
                    target="_blank"
                    rel="noopener noreferrer nofollow"
                >                        
                    <img src=medium_logo alt="medium-logo" />
                    <span>{"Medium"->React.string}</span>
                </a>
                <a 
                    href="https://t.me/claudebarde"
                    target="_blank"
                    rel="noopener noreferrer nofollow"
                >                        
                    <img src=telegram_logo alt="telegram-logo" />
                    <span>{"Telegram"->React.string}</span>
                </a>
                <a 
                    href="https://www.youtube.com/@letzgetbaked"
                    target="_blank"
                    rel="noopener noreferrer nofollow"
                >                        
                    <img src=youtube_logo alt="youtube-logo" />
                    <span>{"YouTube"->React.string}</span>
                </a>
                <a 
                    href="https://www.linkedin.com/in/claudebarde/"
                    target="_blank"
                    rel="noopener noreferrer nofollow"
                >                        
                    <img src=linkedin_logo alt="linkedin-logo" />
                    <span>{"LinkedIn"->React.string}</span>
                </a>
                <a 
                    href="https://discordapp.com/users/840562293510111232"
                    target="_blank"
                    rel="noopener noreferrer nofollow"
                >                        
                    <img src=discord_logo alt="discord-logo" />
                    <span>{"Discord"->React.string}</span>
                </a>
            </div>
            // <div className="contact__links-list">
            // </div>
        </div>
    </div>
}