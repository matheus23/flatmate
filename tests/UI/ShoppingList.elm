module UI.ShoppingList exposing (all)

import Effect
import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import Kinto
import Main
import ProgramTest as Program exposing (ProgramTest)
import SimulatedEffect.Cmd
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (id, text)
import View


start : ProgramTest Main.Model Main.Msg Effect.Effect
start =
    Program.createDocument
        { init = \_ -> Main.init
        , update = Main.update
        , view =
            \model ->
                { title = "Flatmate"
                , body = [ Main.view model ]
                }
        }
        |> Program.withSimulatedEffects
            (\effect ->
                case effect of
                    Effect.None ->
                        SimulatedEffect.Cmd.none

                    Effect.KintoSend cmd ->
                        SimulatedEffect.Ports.send
                            "kintoSend"
                            (Kinto.encodeCommand cmd)
            )
        |> Program.withSimulatedSubscriptions
            (\model ->
                SimulatedEffect.Sub.none
            )
        |> Program.start ()


all : Test
all =
    describe "shopping list frontend"
        [ test "adding a shopping list item adds it to the list" <|
            \() ->
                start
                    |> Program.fillIn View.shoppingListInputInfo.id View.shoppingListInputInfo.label "Milk"
                    |> Program.clickButton "Add"
                    |> Program.ensureOutgoingPortValues "kintoSend"
                        Decode.value
                        (Expect.equal [ Kinto.encodeCommand (Kinto.Add { title = "Milk" }) ])
                    |> Program.simulateIncomingPort "receive"
                        (Encode.list Encode.object
                            [ [ ( "title", Encode.string "Milk" )
                              , ( "id", Encode.string "1234" )
                              ]
                            ]
                        )
                    |> Program.expectView
                        (Expect.all
                            [ Query.has [ text "Milk" ]
                            , Query.find [ id View.shoppingListInputInfo.id ]
                                >> Query.hasNot [ text "Milk" ]
                            ]
                        )
        ]
