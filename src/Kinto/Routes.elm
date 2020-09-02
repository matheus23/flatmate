module Kinto.Routes exposing (..)

import Url exposing (Url)
import Url.Builder as Url
import Url.Parser exposing (..)



-- UTILITIES


toUrl : (List String -> a) -> Kinto -> a
toUrl urlKind route =
    urlKind (kintoPath route)



-- KINTO


type Kinto
    = Top
    | BucketsAll
    | BucketsWhole String
    | Buckets String Buckets


type Buckets
    = GroupsAll
    | CollectionsAll
    | CollectionsWhole String
    | Collections String Collections


type Collections
    = RecordsAll
    | Records String


kintoRoutes : Parser (Kinto -> a) a
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


kintoPath : Kinto -> List String
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


bucketsRoutes : Parser (Buckets -> a) a
bucketsRoutes =
    oneOf
        [ s "groups"
            </> oneOf
                    [ map GroupsAll top
                    ]
        , s "collections"
            </> oneOf
                    [ map Collections (string </> collectionsRoutes)
                    , map CollectionsWhole string
                    , map CollectionsAll top
                    ]
        ]


bucketsPath : Buckets -> List String
bucketsPath route =
    case route of
        GroupsAll ->
            [ "groups" ]

        CollectionsAll ->
            [ "collections" ]

        CollectionsWhole id ->
            [ "collections", id ]

        Collections id collectionsRoute ->
            "collections" :: id :: collectionsPath collectionsRoute


collectionsRoutes : Parser (Collections -> a) a
collectionsRoutes =
    s "records"
        </> oneOf
                [ map Records string
                , map RecordsAll top
                ]


collectionsPath : Collections -> List String
collectionsPath route =
    "records"
        :: (case route of
                Records id ->
                    [ id ]

                RecordsAll ->
                    []
           )
