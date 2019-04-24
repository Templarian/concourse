module PipelineSideBarTests exposing (all, iAmViewingThePipelinePage, iAmViewingThePipelinePageOnANonPhoneScreen)

import Application.Application as Application
import Colors
import Common
import DashboardTests
import Expect
import Message.Callback as Callback
import Message.Message as Message
import Message.Subscription as Subscription
import Message.TopLevelMessage as TopLevelMessage
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, containing, id, style, tag, text)
import Url


all : Test
all =
    describe "pipeline sidebar"
        [ describe "hamburger icon"
            [ test "appears in the top bar on non-phone screens" <|
                given iAmViewingThePipelinePageOnANonPhoneScreen
                    >> when iAmLookingAtTheLeftHandSectionOfTheTopBar
                    >> then_ iSeeAHamburgerIcon
            , test """has a grey dividing line separating it from the concourse
                      logo""" <|
                given iAmViewingThePipelinePageOnANonPhoneScreen
                    >> when iAmLookingAtTheLeftHandSectionOfTheTopBar
                    >> then_ iSeeAGreyDividingLineToTheRight
            , test """has a white dividing line separating it from the concourse
                      logo when the pipeline is paused""" <|
                given iAmViewingThePipelinePageOnANonPhoneScreen
                    >> given thePipelineIsPaused
                    >> when iAmLookingAtTheLeftHandSectionOfTheTopBar
                    >> then_ iSeeAWhiteDividingLineToTheRight
            , test "does not appear in the top bar on phone screens" <|
                given iAmViewingThePipelinePageOnAPhoneScreen
                    >> when iAmLookingAtTheLeftHandSectionOfTheTopBar
                    >> then_ iDoNotSeeAHamburgerIcon
            , test "when shrinking viewport hamburger icon disappears" <|
                given iAmViewingThePipelinePageOnANonPhoneScreen
                    >> given iShrankTheViewport
                    >> when iAmLookingAtTheLeftHandSectionOfTheTopBar
                    >> then_ iDoNotSeeAHamburgerIcon
            , test "is clickable" <|
                given iAmViewingThePipelinePageOnANonPhoneScreen
                    >> when iAmLookingAtTheHamburgerIcon
                    >> then_ (itIsClickable Message.HamburgerMenu)
            , DashboardTests.defineHoverBehaviour
                { name = "hamburger icon"
                , setup = iAmViewingThePipelinePageOnANonPhoneScreen ()
                , query = iAmLookingAtTheHamburgerIcon
                , unhoveredSelector =
                    { description = "grey"
                    , selector = [ style "opacity" "0.5" ]
                    }
                , hoverable = Message.HamburgerMenu
                , hoveredSelector =
                    { description = "white"
                    , selector = [ style "opacity" "1" ]
                    }
                }
            , test "background becomes lighter on click" <|
                given iAmViewingThePipelinePageOnANonPhoneScreen
                    >> given iClickedTheHamburgerIcon
                    >> when iAmLookingAtTheLeftHandSectionOfTheTopBar
                    >> then_ iSeeALighterBackground
            ]
        ]


given =
    identity


when =
    identity


then_ =
    identity


iAmLookingAtTheTopBar =
    Common.queryView >> Query.find [ id "top-bar-app" ]


iAmLookingAtTheLeftHandSectionOfTheTopBar =
    iAmLookingAtTheTopBar
        >> Query.children []
        >> Query.first


iAmViewingThePipelinePageOnANonPhoneScreen =
    iAmViewingThePipelinePage
        >> Application.handleCallback
            (Callback.ScreenResized
                { scene =
                    { width = 0
                    , height = 0
                    }
                , viewport =
                    { x = 0
                    , y = 0
                    , width = 1200
                    , height = 900
                    }
                }
            )
        >> Tuple.first


iAmViewingThePipelinePageOnAPhoneScreen =
    iAmViewingThePipelinePage
        >> Application.handleCallback
            (Callback.ScreenResized
                { scene =
                    { width = 0
                    , height = 0
                    }
                , viewport =
                    { x = 0
                    , y = 0
                    , width = 360
                    , height = 640
                    }
                }
            )
        >> Tuple.first


iAmViewingThePipelinePage _ =
    Application.init
        { turbulenceImgSrc = ""
        , notFoundImgSrc = ""
        , csrfToken = ""
        , authToken = ""
        , pipelineRunningKeyframes = ""
        }
        { protocol = Url.Http
        , host = ""
        , port_ = Nothing
        , path = "/teams/team/pipelines/pipeline"
        , query = Nothing
        , fragment = Nothing
        }
        |> Tuple.first


iShrankTheViewport =
    Application.handleDelivery (Subscription.WindowResized 300 300) >> Tuple.first


thePipelineIsPaused =
    Application.handleCallback
        (Callback.PipelineFetched
            (Ok
                { id = 1
                , name = "pipeline"
                , paused = True
                , public = True
                , teamName = "team"
                , groups = []
                }
            )
        )
        >> Tuple.first


iAmLookingAtTheHamburgerIcon =
    iAmLookingAtTheTopBar
        >> Query.find [ style "background-image" "url(/public/images/baseline-menu-24px.svg)" ]


iSeeAGreyDividingLineToTheRight =
    Query.has
        [ style "border-right" <| "1px solid " ++ Colors.background
        , style "opacity" "1"
        ]


iSeeAWhiteDividingLineToTheRight =
    Query.has [ style "border-right" <| "1px solid " ++ Colors.pausedTopbarSeparator ]


itIsClickable domID =
    Expect.all
        [ Query.has [ style "cursor" "pointer" ]
        , Event.simulate Event.click
            >> Event.expect
                (TopLevelMessage.Update <|
                    Message.Click domID
                )
        ]


hamburgerIconWidth =
    "54px"


iSeeAHamburgerIcon =
    Query.has
        (DashboardTests.iconSelector
            { size = hamburgerIconWidth
            , image = "baseline-menu-24px.svg"
            }
        )


iDoNotSeeAHamburgerIcon =
    Query.hasNot
        (DashboardTests.iconSelector
            { size = hamburgerIconWidth
            , image = "baseline-menu-24px.svg"
            }
        )


iClickedTheHamburgerIcon =
    Application.update
        (TopLevelMessage.Update <| Message.Click Message.HamburgerMenu)
        >> Tuple.first


iSeeALighterBackground =
    Query.has [ style "background-color" "#333333", style "opacity" "0.5" ]
