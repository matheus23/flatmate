port module Kinto exposing (Id, KintoCommand(..), keyedWith, receive, send)

import Html.Attributes exposing (id)
import Json.Encode as E


port kintoSend : { command : String, argument : E.Value } -> Cmd msg


send : KintoCommand -> Cmd msg
send =
    encodeKintoCommand >> kintoSend


type KintoCommand
    = Add { title : String }
    | Update { title : String, id : Id }
    | FetchList
    | DeleteItem Id


encodeKintoCommand : KintoCommand -> { command : String, argument : E.Value }
encodeKintoCommand cmd =
    case cmd of
        Add { title } ->
            { command = "add"
            , argument = E.string title
            }

        Update { title, id } ->
            { command = "update"
            , argument =
                E.object
                    [ ( "id", E.string <| unwrap id )
                    , ( "title", E.string <| title )
                    ]
            }

        FetchList ->
            { command = "fetchList"
            , argument = E.null
            }

        DeleteItem id ->
            { command = "delete"
            , argument = E.string <| unwrap id
            }


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


keyedWith : Id -> a -> ( String, a )
keyedWith (Id id) view =
    ( id, view )
