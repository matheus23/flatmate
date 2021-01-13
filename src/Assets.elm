module Assets exposing (..)

import Base64


signinCircle : String
signinCircle =
    """<svg width="411" height="274" viewBox="0 0 411 274" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="60" cy="-409" r="683" fill="#90B3FF"/>
</svg>""" |> Base64.encode


desktopBackground : String
desktopBackground =
    """<svg width="1440" height="760" viewBox="0 0 1440 760" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect width="1440" height="760" fill="#F5F8FF"/>
<path d="M0 374.01C159.186 437.866 332.99 473 515 473C870.594 473 1194.87 338.893 1440 118.497V0H0V374.01Z" fill="#CCDCFF"/>
</svg>
""" |> Base64.encode
