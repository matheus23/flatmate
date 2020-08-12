port module Kinto exposing (Id, KintoCommand(..), receive, send)

import Html.Attributes exposing (id)
import Json.Encode as E


port kintoSend : E.Value -> Cmd msg


send : KintoCommand -> Cmd msg
send =
    encodeKintoCommand >> kintoSend


type KintoCommand
    = Add { title : String }
    | Update { title : String, id : Id }
    | FetchList
    | RemoveItem Id


encodeKintoCommand : KintoCommand -> E.Value
encodeKintoCommand cmd =
    case cmd of
        Add { title } ->
            E.object
                [ ( "command", E.string "add" )
                , ( "title", E.string title )
                ]

        Update { title, id } ->
            E.object
                [ ( "command", E.string "update" )
                , ( "item"
                  , E.object
                        [ ( "id", E.string <| unwrap id )
                        , ( "title", E.string <| title )
                        ]
                  )
                ]

        FetchList ->
            E.object
                [ ( "command", E.string "list-items" ) ]

        RemoveItem id ->
            E.object
                [ ( "command", E.string "remove" )
                , ( "id", E.string <| unwrap id )
                ]


type Id
    = Id String


unwrap : Id -> String
unwrap (Id id) =
    id


port kintoReceive : (List { title : String, id : String } -> msg) -> Sub msg


receive : (List { title : String, id : Id } -> msg) -> Sub msg
receive onMsg =
    let
        wrap { title, id } =
            { title = title, id = Id id }
    in
    kintoReceive (List.map wrap >> onMsg)
