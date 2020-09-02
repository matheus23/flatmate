module Kinto.Routes exposing (..)

import Url exposing (Url)
import Url.Builder as Url
import Url.Parser exposing (..)


type KintoRoutes
    = Top
    | BucketsAll
    | BucketsWhole String
    | Buckets String BucketsRoutes


type BucketsRoutes
    = GroupsAll
    | CollectionsAll
    | CollectionsWhole String
    | Collections String CollectionsRoutes


type CollectionsRoutes
    = RecordsAll
    | Records String


kintoRoutes =
    s "v1"
        </> oneOf
                [ map Top top
                , s "buckets"
                    </> oneOf
                            [ map Buckets (string </> bucketsRoutes)
                            , map BucketsWhole string
                            , map BucketsAll top
                            ]
                ]


bucketsRoutes =
    oneOf
        [ s "groups"
            </> oneOf
                    [ map GroupsAll top
                    ]
        , s "collections"
            </> oneOf
                    [ map Collections (string </> collections.routes)
                    , map CollectionsWhole string
                    , map CollectionsAll top
                    ]
        ]


collections =
    p "records"
        { routes =
            oneOf
                [ map Records string
                , map RecordsAll top
                ]
        , path =
            \route ->
                case route of
                    Records id ->
                        [ id ]

                    RecordsAll ->
                        []
        }


addCase constructor sub { cases, paths } =
    { cases = map constructor sub.routes :: cases
    , paths = \chooser -> chooser sub.path
    }


type alias Routes a b =
    { path : b -> List String
    , routes : Parser a b
    }


type TestRoutes
    = Test String String


testRoutes =
    { routes =
        string </> s "two" </> string
    , path =
        \one two ->
            [ one, "two", two ]
    }



-- p : String -> Routes a b -> Routes a b


p name { routes, path } =
    { routes = s name </> routes
    , path = \route -> name :: path route
    }


end : a -> Routes (a -> b) b
end a =
    { routes = map a top
    , path = \_ -> []
    }


kintoPath route =
    "v1"
        :: (case route of
                Top ->
                    []

                BucketsAll ->
                    [ "buckets" ]

                BucketsWhole id ->
                    [ "buckets", id ]

                Buckets id bucketsRoute ->
                    [ "buckets", id ] ++ bucketsPath bucketsRoute
           )


bucketsPath route =
    case route of
        GroupsAll ->
            [ "groups" ]

        CollectionsAll ->
            [ "collections" ]

        CollectionsWhole id ->
            [ "collections", id ]

        Collections id collectionsRoute ->
            [ "collections", id ] ++ collections.path collectionsRoute


roundTrip route =
    Url.fromString (Url.crossOrigin "http://localhost:8888" (kintoPath route) [])
        |> Maybe.andThen (parse kintoRoutes)


exampleUrl path =
    { protocol = Url.Http
    , host = "localhost"
    , port_ = Just 8888
    , path = path
    , query = Nothing
    , fragment = Nothing
    }


exampleRoutes =
    [ Top
    , BucketsAll
    , BucketsWhole "flatmate"
    , Buckets "flatmate" GroupsAll
    , Buckets "flatmate" CollectionsAll
    , Buckets "flatmate" (CollectionsWhole "items")
    , Buckets "flatmate" (Collections "items" RecordsAll)
    , Buckets "flatmate" (Collections "items" (Records "1234"))
    ]


print ls =
    let
        _ =
            List.map
                (\x ->
                    Debug.log "" x
                )
                (List.reverse ls)
    in
    ()
