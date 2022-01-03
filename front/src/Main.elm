module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser
import Html.Events exposing (onClick, onInput)
import Browser exposing (Document)

import Model exposing (..)



main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init () url key =
    ( Model key url Nothing Model.initAddfield , Cmd.none )


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | AddField AddFieldMsg


type AddFieldMsg
    = Subject String
    | Description String
    | ContractAddress String
    | TargetAmount String
    | MonthlyRemittrance String
    | Submit


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )
        
        AddField subMsg ->
            let
                addField = model.addField
                addField_ = case subMsg of
                    Subject subject ->
                        { addField | subject = subject }
                    Description desc ->
                        { addField | description = desc }
                    ContractAddress ca ->
                        { addField | contractAddress = ca }
                    TargetAmount maybeTa ->
                        case String.toFloat maybeTa of
                            Just ta ->
                                { addField | targetAmount = ta } 
                            Nothing ->
                                addField
                    MonthlyRemittrance maybeMr ->
                        case String.toFloat maybeMr of
                            Just mr ->
                                { addField | monthlyRemittrance = mr } 
                            Nothing ->
                                addField
                    Submit ->
                        -- validate
                        let
                            errors = addFormValidate addField
                        in
                        if List.length errors == 0 then
                            { addField | errors = [] }
                        else
                            { addField | errors = errors } 

            in
            ( { model | addField = addField_ }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- View


view : Model -> Browser.Document Msg
view model =
    let
        subdoc = case Url.Parser.parse Model.routeParser model.url of
            Just Index ->
                accountListView
            Just Add ->
                addView model
            Nothing ->
                notFoundView
    in
    { title = "Hardcore Bank | " ++ subdoc.title
    , body =
        [ navbar
        , main_ [] subdoc.body
        ]
    }


navbar : Html Msg
navbar =
    header []
        [ nav []
            [ a [ href "/" ]
                [ h1 [ class "logotext" ]
                    [ text "Hardcore Bank" ]
                ]
            ]
        ]


notFoundView : Document Msg
notFoundView =
    { title = "Not Found"
    , body =
        [ div [ class "not found" ]
            [ text "404 Not Found" ]
        ]
    }


accountListView : Document Msg
accountListView =
    { title = "My page"
    , body =
        [ div [ class "accounts" ]
            [ div [ class "row" ]
                [ div [ class "row-title" ]
                    [ h1 [ ]
                        [ text "Accounts" 
                        ]
                    , a [ href "/add" ]
                        [ button [ class "add" ]
                            [ text "Add" ]
                        ]
                    ]
                ]
            ]
        ]
    }


addView : Model -> Document Msg
addView model =
    { title = "Create Account"
    , body =
        [ div [ class "add" ]
            [ div [ class "row" ]
                [ div [ class "row-title" ]
                    [ h1 []
                        [ text "Create Account" ]
                    ]
                , div [ class "form" ]
                    [ label [ for "subject" ] [ text "Subject" ]
                    , input
                        [ id "subject", type_ "text"
                        , value model.addField.subject
                        , onInput <| (\x -> AddField <| Subject x)
                        ]
                        []
                    , case List.filter (\(f, _) -> f == Model.SubjectField) model.addField.errors of
                        [] ->
                            p [] []
                        (_, e) :: _ ->
                            p [ class "error" ] [ text e ]
                    , label [ for "description" ] [ text "Description" ]
                    , input
                        [ id "description", type_ "text"
                        , value model.addField.description
                        , onInput <| (\x -> AddField <| Description x)
                        ]
                        []
                    , case List.filter (\(f, _) -> f == Model.DescriptionField) model.addField.errors of
                        [] ->
                            p [] []
                        (_, e) :: _ ->
                            p [ class "error" ] [ text e ]
                    , label [ for "contract-address" ] [ text "Token Contract Address" ]
                    , input
                        [ id "contract-address", type_ "text"
                        , value model.addField.contractAddress
                        , onInput <| (\x -> AddField <| ContractAddress x)
                        ]
                        []
                    , case List.filter (\(f, _) -> f == Model.ContractAddressField) model.addField.errors of
                        [] ->
                            p [] []
                        (_, e) :: _ ->
                            p [ class "error" ] [ text e ]
                    , label [ for "target-amount", class "small" ] [ text "Target Amount" ]
                    , input
                        [ id "target-amount", type_ "number"
                        , value <| String.fromFloat model.addField.targetAmount
                        , step "0.00001"
                        , onInput <| (\x -> AddField <| TargetAmount x)
                        ]
                        []
                    , case List.filter (\(f, _) -> f == Model.TargetAmountField) model.addField.errors of
                        [] ->
                            p [] []
                        (_, e) :: _ ->
                            p [ class "error" ] [ text e ]
                    , label [ for "monthly-remittrance", class "small" ] [ text "Monthly Remittrance" ]
                    , input
                        [ id "monthly-remittrance", type_ "number"
                        , value <| String.fromFloat model.addField.monthlyRemittrance
                        , step "0.00001"
                        , onInput <| (\x -> AddField <| MonthlyRemittrance x)
                        ]
                        []
                    , case List.filter (\(f, _) -> f == Model.MonthlyRemittranceField) model.addField.errors of
                        [] ->
                            p [] []
                        (_, e) :: _ ->
                            p [ class "error" ] [ text e ]
                    , button [ class "submit", onClick <| AddField Submit ]
                        [ text "Create" ]
                    ]
                ]
            ]
        ]
    }
