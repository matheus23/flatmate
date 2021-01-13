module Tailwind.Breakpoints exposing (..)

import Css
import Css.Media


sm : List Css.Style -> Css.Style
sm =
    Css.Media.withMediaQuery [ "(min-width: 641px)" ]


md : List Css.Style -> Css.Style
md =
    Css.Media.withMediaQuery [ "(min-width: 769px)" ]


lg : List Css.Style -> Css.Style
lg =
    Css.Media.withMediaQuery [ "(min-width: 1025px)" ]


xl : List Css.Style -> Css.Style
xl =
    Css.Media.withMediaQuery [ "(min-width: 1281px)" ]


xxl : List Css.Style -> Css.Style
xxl =
    Css.Media.withMediaQuery [ "(min-width: 1537px)" ]
