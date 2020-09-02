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


kintoRoutes : Parser (KintoRoutes -> a) a
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


kintoPath : KintoRoutes -> List String
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


bucketsRoutes : Parser (BucketsRoutes -> a) a
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


bucketsPath : BucketsRoutes -> List String
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


collectionsRoutes : Parser (CollectionsRoutes -> a) a
collectionsRoutes =
    s "records"
        </> oneOf
                [ map Records string
                , map RecordsAll top
                ]


collectionsPath : CollectionsRoutes -> List String
collectionsPath route =
    "records"
        :: (case route of
                Records id ->
                    [ id ]

                RecordsAll ->
                    []
           )
