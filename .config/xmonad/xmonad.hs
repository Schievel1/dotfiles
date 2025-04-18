{-# LANGUAGE LambdaCase #-}
-- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W
import System.Process (readProcess)

    -- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen, shiftNextScreen, shiftPrevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S
import XMonad.Actions.SpawnOn
import XMonad.Actions.TiledWindowDragging
    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import           XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks (docks, avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.WallpaperSetter
-- custom
import XMonad.Hooks.ScreenCorners

    -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.MouseResizableTile

    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import XMonad.Layout.DraggingVisualizer

   -- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.Cursor
import XMonad.Actions.OnScreen
import           XMonad.Hooks.DynamicIcons           (IconConfig (..), appIcon,
                                                        dynamicLogIconsWithPP,
                                                      dynamicIconsPP,
                                                      iconsPP,
                                                      iconsFmtReplace,
                                                      iconsGetFocus,
                                                      iconsGetAll,
                                                      wrapUnwords)
import           XMonad.Hooks.StatusBar              (StatusBarConfig,
                                                      statusBarProp,
                                                      statusBarPropTo, withSB)
import           XMonad.Hooks.StatusBar.PP           (PP (..), filterOutWsPP,
                                                      shorten', wrap,
                                                      xmobarAction,
                                                      xmobarBorder, xmobarColor,
                                                      xmobarFont, xmobarStrip)
import           XMonad.Util.ClickableWorkspaces     (clickablePP)
import XMonad.Util.Hacks (windowedFullscreenFixEventHook, javaHack, trayerAboveXmobarEventHook, trayAbovePanelEventHook, trayerPaddingXmobarEventHook, trayPaddingXmobarEventHook, trayPaddingEventHook)

-- Prompt
import XMonad.Prompt
import XMonad.Prompt.RunOrRaise

-- for wallpaper find and selection
import System.Directory (listDirectory, doesFileExist, doesDirectoryExist)
import System.FilePath ((</>))
import System.Random (randomRIO)
import Control.Monad (filterM)
import Control.Applicative ((<|>))

myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"
-- myFont = "xft:JetBrainsMono Nerd Font:size=14"

myModMask :: KeyMask
-- myModMask = mod1Mask        -- Sets modkey to alt key
myModMask = mod4Mask        -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "alacritty"    -- Sets default terminal

myBrowser :: String
myBrowser = "firefox-bin"  -- Sets firefox as Browser

myMail :: String
myMail = "thunderbird-bin"  -- Sets evolution as mail client

myFiles :: String
myFiles = "pcmanfm"  -- Sets nautilus as file browser

myEmacs :: String
myEmacs = "emacsclient -c -a 'emacs' "  -- Makes emacs keybindings easier to type

myEditor :: String
myEditor = "emacsclient -c -a 'emacs' "  -- Sets emacs as editor

myBorderWidth :: Dimension
myBorderWidth = 2           -- Sets border width for windows

myNormColor :: String
myNormColor   = "#282c34"   -- Border color of normal windows

myFocusColor :: String
myFocusColor  = "#46d9ff"   -- Border color of focused windows

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
    spawnOnce "/usr/libexec/polkit-gnome-authentication-agent-1 &"
    spawnOnce "picom --config $HOME/.config/picom.conf &"
    spawnOnce "nm-applet &"
    spawnOnce "volumeicon &"
    spawnOnce "xscreensaver --no-splash &"
    spawnOnce "trayer-srg --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0x282c34  --height 24 --monitor 1 &"
    spawnOnce "/usr/bin/emacs --daemon &" -- emacs daemon for the emacsclient
    spawnOnOnce ( myWorkspaces !! 0 ) "firefox-bin"
    spawnOnOnce ( myWorkspaces !! 1 ) "emacsclient -c -a 'emacs'"
    spawnOnOnce ( myWorkspaces !! 2 ) "alacritty"
    spawnOnOnce ( myWorkspaces !! 3 ) "pcmanfm"
    spawnOnOnce ( myWorkspaces !! 4 ) "thunderbird-bin"
    spawnOnce "nextcloud --background"
    spawnOnce "gnome-encfs-manager"
    spawnOnce "hp-systray"
    spawnOnce "flameshot"
    windows (greedyViewOnScreen 0 ( myWorkspaces !! 0 ))
    windows (greedyViewOnScreen 1 ( myWorkspaces !! 1 ))
    -- windows (greedyViewOnScreen 2 ( myWorkspaces !! 3 ))
    setDefaultCursor xC_left_ptr
   -- addMonitorCorner SCTop 0 5 (spawn "rofi -show window")
   -- addMonitorCorner SCTop 1 5 (spawn "rofi -show window")
   -- addMonitorCorner SCTop 2 5 (spawn "rofi -show window")
    addMonitorCorner SCUpperLeft 0 20 (spawn "rofi -show drun")
    addMonitorCorner SCUpperLeft 1 20 (spawn "rofi -show drun")
    addMonitorCorner SCUpperLeft 2 20 (spawn "rofi -show drun")
    setWMName "LG3D"

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                  (0x28,0x2c,0x34) -- lowest inactive bg
                  (0x28,0x2c,0x34) -- highest inactive bg
                  (0xc7,0x92,0xea) -- active bg
                  (0xc0,0xa7,0x9a) -- inactive fg
                  (0x28,0x2c,0x34) -- active fg

-- gridSelect menu layout
mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 40
    , gs_cellwidth    = 200
    , gs_cellpadding  = 6
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 200
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

myAppGrid = [ ("Audacity", "audacity")
                 , ("Emacs", "emacsclient -c -a emacs")
                 , ("Alacritty", "alacritty")
                 , ("Firefox", "firefox-bin")
                 , ("LibreOffice Impress", "loimpress")
                 , ("LibreOffice Writer", "lowriter")
                 , ("PCManFM", "pcmanfm")
                 ]

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ limitWindows 12
           $ mySpacing 8
           $ mouseResizableTile { draggerType = FixedDragger 0 30 }
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 8
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme
tallAccordion  = renamed [Replace "tallAccordion"]
           $ Accordion
wideAccordion  = renamed [Replace "wideAccordion"]
           $ Mirror Accordion

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#46d9ff"
                 , inactiveColor       = "#313846"
                 , activeBorderColor   = "#46d9ff"
                 , inactiveBorderColor = "#282c34"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#d0d0d0"
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
   { swn_font              = "xft:JetBrainsMono Nerd Font Mono:size=80"
   , swn_fade              = 1.0
   , swn_bgcolor           = "#1c1f24"
   , swn_color             = "#9ece3a"
   }

-- The layout hook
myLayoutHook = showWName' myShowWNameTheme $ screenCornerLayoutHook $ draggingVisualizer $ avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout = withBorder myBorderWidth tall
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| grid
                                 ||| spirals
                                 ||| threeCol
                                 ||| threeRow
                                 ||| tallAccordion
                                 ||| wideAccordion

myWorkspaces = ["\xf03a4", "\xf03a7", "\xf03aa", "\xf03ad", "\xf03b1", "\xf03b3", "\xf03b6", "\xf03b9", "\xf03bc"]
-- myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
-- myWorkspaces = [" <fn=5>\xf03a4</fn> ", " <fn=5>\xf03a7</fn> ", " <fn=5>\xf03aa</fn> ", " <fn=5>\xf03ad</fn> ", " <fn=5>\xf03b1</fn> ", " <fn=5>\xf03b3</fn> ", " <fn=5>\xf03b6</fn> ", " <fn=5>\xf03b9</fn> ", " <fn=5>\xf03bc</fn> "]
-- myWorkspaces = [" <fn=5>\xf269</fn> ", " <fn=5>\xe7cf</fn> ", " <fn=5>\xe795</fn> ", " <fn=5>\xf07c</fn> ", " <fn=5>\xf0e0</fn> ", " <fn=5>\xf8b2</fn> ", " <fn=5>\xf8b5</fn> ", " <fn=5>\xf8b8</fn> ", " <fn=5>\xf8bb</fn> "]

myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces and the names would be very long if using clickable workspaces.
     [ className =? "confirm"         --> doFloat
     , className =? "file_progress"   --> doFloat
     , className =? "dialog"          --> doFloat
     , className =? "download"        --> doFloat
     , className =? "error"           --> doFloat
     , className =? "Gimp"            --> doFloat
     , className =? "notification"    --> doFloat
     , className =? "pinentry-gtk-2"  --> doFloat
     , className =? "splash"          --> doFloat
     , className =? "toolbar"         --> doFloat
     , className =? "Places"         --> doFloat
     , className =? "Yad"             --> doCenterFloat
     , title =? "Mozilla Firefox"     --> doShift ( myWorkspaces !! 0 )
     , title =? "Mozilla Thunderbird" --> doShift ( myWorkspaces !! 3 )
     , className =? "Evolution"      --> doShift ( myWorkspaces !! 3 )
     , className =? "emacs"      --> doShift ( myWorkspaces !! 2 )
     , className =? "mpv"             --> doShift ( myWorkspaces !! 5 )
     , className =? "pcmanfm" --> doShift ( myWorkspaces !! 2 )
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     , (className =? "evolution" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     , isFullscreen -->  doFullFloat
     ]

-- START_KEYS

myMouseBindings :: [((ButtonMask, Button), Window -> X ())]
myMouseBindings =
                [
                 ((0, 8), \w -> focus w >> mouseResizeWindow w
                                         >> windows W.shiftMaster)
                , ((0, 9), dragWindow)
                --, ((0, 9), \w -> focus w >> mouseMoveWindow w
                                         -- >> windows W.shiftMaster)
                ]

myKeys :: [(String, X ())]
myKeys =
    -- KB_GROUP Xmonad
        [ ("M-S-l", spawn "xmonad --recompile")  -- Recompiles xmonad
        , ("M-S-r", spawn "xmonad --restart")    -- Restarts xmonad
        , ("M-S-q", io exitSuccess)              -- Quits xmonad

    -- KB_GROUP Run launcher
        , ("M-S-<Return>", spawn "rofi -show drun")
        -- , ("M-S-<Return>", runOrRaisePrompt def)

    -- KB_GROUP Useful programs to have a keybinding for launch
        , ("M-<Return>", spawn (myTerminal))
        , ("M-b", spawn (myBrowser))
        , ("M-m", spawn (myMail))
        , ("M-f", spawn (myFiles))

    -- KB_GROUP Screenshot
        , ("M-S-s", spawn "flameshot gui")

    -- KB_GROUP Kill windows
       -- , ("M-S-c", kill1)     -- Kill the currently focused client
       -- , ("M-S-a", killAll)   -- Kill all windows on current workspace

    -- KB_GROUP Workspaces
        , ("M-,", nextScreen)  -- Switch focus to next monitor
        , ("M-.", prevScreen)  -- Switch focus to prev monitor
        , ("C-,", shiftNextScreen >> nextScreen) -- Shifts focused windew to prev ws
        , ("C-.", shiftPrevScreen >> prevScreen) -- Shifts focused windew to prev ws

-- KB_GROUP Floating windows
        , ("M-f", sendMessage (T.Toggle "floats")) -- Toggles my 'floats' layout
        , ("M-t", withFocused $ windows . W.sink)  -- Push floating window back to tile
        , ("M-S-t", sinkAll)                       -- Push ALL floating windows to tile

    -- KB_GROUP Increase/decrease spacing (gaps)
        , ("C-M1-h", decWindowSpacing 4)         -- Decrease window spacing
        , ("C-M1-t", incWindowSpacing 4)         -- Increase window spacing
        , ("C-M1-d", decScreenSpacing 4)         -- Decrease screen spacing
        , ("C-M1-n", incScreenSpacing 4)         -- Increase screen spacing

    -- KB_GROUP Grid Select (CTR-g followed by a key)
        , ("C-g g", spawnSelected' myAppGrid)                 -- grid select favorite apps
        , ("C-g w", goToSelected $ mygridConfig myColorizer)  -- goto selected window
        , ("C-g b", bringSelected $ mygridConfig myColorizer) -- bring selected window

    -- KB_GROUP Windows navigation
        , ("M-'", windows W.focusMaster)  -- Move focus to the master window
        , ("M-o", windows W.focusDown)    -- Move focus to the next window
        , ("M-a",  windows W.focusUp)     -- Move focus to the prev window
        , ("M-S-'", windows W.swapMaster) -- Swap the focused window and the master window
        , ("M-S-o", windows W.swapDown)   -- Swap focused window with next window
        , ("M-S-a", windows W.swapUp)     -- Swap focused window with prev window
        , ("M-<Backspace>", promote)      -- Moves focused window to master, others maintain order
        , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
        , ("M-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack

    -- KB_GROUP Layouts
        , ("M-<Tab>", sendMessage NextLayout)           -- Switch to next layout
        , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full

    -- KB_GROUP Increase/decrease windows in the master pane or the stack
        , ("M-S-<Up>", sendMessage (IncMasterN 1))      -- Increase # of clients master pane
        , ("M-S-<Down>", sendMessage (IncMasterN (-1))) -- Decrease # of clients master pane
        , ("M-C-<Up>", increaseLimit)                   -- Increase # of windows
        , ("M-C-<Down>", decreaseLimit)                 -- Decrease # of windows

    -- KB_GROUP Sublayouts
    -- This is used to push windows to tabbed sublayouts, or pull them out of it.
        , ("M-C-d", sendMessage $ pullGroup L)
        , ("M-C-n", sendMessage $ pullGroup R)
        , ("M-C-t", sendMessage $ pullGroup U)
        , ("M-C-h", sendMessage $ pullGroup D)
        , ("M-C-m", withFocused (sendMessage . MergeAll))
        -- , ("M-C-u", withFocused (sendMessage . UnMerge))
        , ("M-C-/", withFocused (sendMessage . UnMergeAll))
        , ("M-C-,", onGroup W.focusUp')    -- Switch focus to next tab
        , ("M-C-.", onGroup W.focusDown')  -- Switch focus to prev tab

    -- KB_GROUP Set wallpaper
        , ("M-<F1>", spawn "find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output HDMI-A-0 --stretch")
        , ("M-<F2>", spawn "find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output DVI-D-1 --stretch")
        , ("M-<F3>", spawn "find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output DVI-D-0 --stretch")

    -- KB_GROUP Emacs (CTRL-e followed by a key)
        , ("C-e e", spawn (myEmacs))   -- emacs
       , ("C-e b", spawn (myEmacs ++ ("--eval '(ibuffer)'")))   -- list buffers
       , ("C-e d", spawn (myEmacs ++ ("--eval '(dired nil)'"))) -- dired
       , ("C-e i", spawn (myEmacs ++ ("--eval '(erc)'")))       -- erc irc client
       , ("C-e n", spawn (myEmacs ++ ("--eval '(elfeed)'")))    -- elfeed rss
       , ("C-e s", spawn (myEmacs ++ ("--eval '(eshell)'")))    -- eshell
       , ("C-e t", spawn (myEmacs ++ ("--eval '(mastodon)'")))  -- mastodon.el
       , ("C-e v", spawn (myEmacs ++ ("--eval '(+vterm/here nil)'"))) -- vterm if on Doom Emacs
       , ("C-e w", spawn (myEmacs ++ ("--eval '(doom/window-maximize-buffer(eww \"distrotube.com\"))'"))) -- eww browser if on Doom Emacs
       , ("C-e a", spawn (myEmacs ++ ("--eval '(emms)' --eval '(emms-play-directory-tree \"~/Music/\")'")))
        ]
-- END_KEYS

myIcons :: Query [String]
myIcons = composeAll
  [ className =? "firefox" --> appIcon "\xe745"
  , className =? "Emacs" --> appIcon "\xe7cf"
  , className =? "Alacritty" --> appIcon "\xe795"
  , className =? "Pcmanfm" --> appIcon "\xe5fe"
  , className =? "thunderbird-esr" --> appIcon "\xf370"
  , className =? "Discord" --> appIcon "\xf1ff"
  ]

myIconConfig :: IconConfig
myIconConfig = def { iconConfigIcons  = myIcons
                   , iconConfigFmt    = iconsFmtReplace concat
                   , iconConfigFilter = iconsGetAll
                   }

myXmobarPPCenter :: PP
myXmobarPPCenter = def
     { ppCurrent = xmobarColor "#9ece6a" "#282c34:0" . wrap "<box type=Bottom width=2 mb=2 color=#e0af68><fn=5>" "</fn></box>"         -- Current workspace
     , ppVisible = xmobarColor "#9ece6a" "#282c34:0" . wrap "<fn=5>" "</fn>"                                                           -- Visible but not current workspace
     , ppHidden = xmobarColor "#7da6ff" "#282c34:0" . wrap "<box type=Top width=2 mt=2 color=#7da6ff><fn=5>" "</fn></box>"             -- Hidden workspaces
     , ppHiddenNoWindows = xmobarColor "#7da6ff" "#282c34:0" . wrap "<fn=5>" "</fn>"    -- Hidden workspaces (no windows)
     , ppTitle = xmobarColor "#787c99" "#282c34:0" . shorten 40               -- Title of active window
     , ppSep = wrapSep " "
     , ppUrgent = xmobarColor "#C45500" "#282c34:0" . wrap "!" "!"            -- Urgent workspace
     , ppLayout = xmobarColor "#ff6c6b" "#282c34:0" . wrap """"
     , ppWsSep         = xmobarColor "#282c34" "#282c34:0" "    "
     -- , ppExtras  = [windowCount]                                     -- # of windows current workspace
     , ppOrder  = \(ws:l:_:_) -> [ws,l]                    -- order of things in xmobar
     }
 where
  wrapSep :: String -> String
  wrapSep = wrap "<fc=#282c34><fn=4>\xe0b4</fn></fc>""<fc=#282c34><fn=4>\xe0b6</fn></fc>"

myXmobarPPLeft :: PP
myXmobarPPLeft = def
     { ppCurrent = xmobarColor "#9ece6a" "#282c34:0" . wrap "<box type=Bottom width=2 mb=2 color=#e0af68><fn=5>" "</fn></box>"         -- Current workspace
     , ppVisible = xmobarColor "#9ece6a" "#282c34:0" . wrap "<fn=5>" "</fn>"                                                           -- Visible but not current workspace
     , ppHidden = xmobarColor "#7da6ff" "#282c34:0" . wrap "<box type=Top width=2 mt=2 color=#7da6ff><fn=5>" "</fn></box>"             -- Hidden workspaces
     , ppHiddenNoWindows = xmobarColor "#7da6ff" "#282c34:0" . wrap "<fn=5>" "</fn>"    -- Hidden workspaces (no windows)
     , ppTitle = xmobarColor "#787c99" "#282c34:0" . shorten 30               -- Title of active window
     , ppSep = wrapSep " "
     , ppUrgent = xmobarColor "#C45500" "#282c34:0" . wrap "!" "!"            -- Urgent workspace
     , ppLayout = xmobarColor "#ff6c6b" "#282c34:0" . wrap """"
     , ppWsSep  = xmobarColor "#282c34" "#282c34:0" "    "
     -- , ppExtras  = [windowCount]                                     -- # of windows current workspace
     , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]                    -- order of things in xmobar
     }
 where
  wrapSep :: String -> String
  wrapSep = wrap "<fc=#282c34><fn=4>\xe0b4</fn></fc>""<fc=#282c34><fn=4>\xe0b6</fn></fc>"

myXmobarPPRight :: PP
myXmobarPPRight = def
     { ppCurrent = xmobarColor "#9ece6a" "#282c34:0" . wrap "<box type=Bottom width=2 mb=2 color=#e0af68><fn=5>" "</fn></box>"         -- Current workspace
     , ppVisible = xmobarColor "#9ece6a" "#282c34:0" . wrap "<fn=5>" "</fn>"                                                           -- Visible but not current workspace
     , ppHidden = xmobarColor "#7da6ff" "#282c34:0" . wrap "<box type=Top width=2 mt=2 color=#7da6ff><fn=5>" "</fn></box>"             -- Hidden workspaces
     , ppHiddenNoWindows = xmobarColor "#7da6ff" "#282c34:0" . wrap "<fn=5>" "</fn>"    -- Hidden workspaces (no windows)
     , ppTitle = xmobarColor "#787c99" "#282c34:0" . shorten 80               -- Title of active window
     , ppSep = wrapSep " "
     , ppUrgent = xmobarColor "#C45500" "#282c34:0" . wrap "!" "!"            -- Urgent workspace
     , ppLayout = xmobarColor "#ff6c6b" "#282c34:0" . wrap """"
     , ppWsSep  = xmobarColor "#282c34" "#282c34:0" "    "
     -- , ppExtras  = [windowCount]                                     -- # of windows current workspace
     , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]                    -- order of things in xmobar
     }
 where
  wrapSep :: String -> String
  wrapSep = wrap "<fc=#282c34><fn=4>\xe0b4</fn></fc>""<fc=#282c34><fn=4>\xe0b6</fn></fc>"

mySBScreenCenter :: StatusBarConfig
mySBScreenCenter = statusBarPropTo "_XMONAD_LOG_0"
  "xmobar -x 0 $HOME/.config/xmobar/xmobarrc0"
  (clickablePP =<< dynamicIconsPP myIconConfig (filterOutWsPP [scratchpadWorkspaceTag] myXmobarPPCenter))

mySBScreenLeft :: StatusBarConfig
mySBScreenLeft = statusBarPropTo "_XMONAD_LOG_1"
  "xmobar -x 1 $HOME/.config/xmobar/xmobarrc1"
  (clickablePP =<< dynamicIconsPP myIconConfig (filterOutWsPP [scratchpadWorkspaceTag] myXmobarPPLeft))

mySBScreenRight :: StatusBarConfig
mySBScreenRight = statusBarPropTo "_XMONAD_LOG_2"
  "xmobar -x 2 $HOME/.config/xmobar/xmobarrc2"
  (clickablePP =<< dynamicIconsPP myIconConfig (filterOutWsPP [scratchpadWorkspaceTag] myXmobarPPRight))

-- myWallpaperConf :: WallpaperConf
-- myWallpaperConf = def
--      { wallpaperBaseDir = "/home/pascal/Pictures/wallpapers"
--      , wallpapers = WallpaperList 
--          [ (( myWorkspaces !! 0 ), WallpaperDir "./")
--          , (( myWorkspaces !! 1 ), WallpaperDir "./")
--          , (( myWorkspaces !! 2 ), WallpaperDir "./")
--          , (( myWorkspaces !! 3 ), WallpaperDir "./")
--          , (( myWorkspaces !! 4 ), WallpaperDir "./")
--          , (( myWorkspaces !! 5 ), WallpaperDir "./")
--          , (( myWorkspaces !! 6 ), WallpaperDir "./")
--          , (( myWorkspaces !! 7 ), WallpaperDir "./")
--          , (( myWorkspaces !! 8 ), WallpaperDir "./")
--          ]
--      }

myEventHook :: Event -> X All
myEventHook = screenCornerEventHook
            <> swallowEventHook (className =? "Alacritty" <||> className =? "Termite") (return True)
            <> trayerPaddingXmobarEventHook
-- Uncomment this line to enable fullscreen support on things like YouTube/Netflix.
-- This works perfect on SINGLE monitor systems. On multi-monitor systems,
-- it adds a border around the window if screen does not have focus. So, my solution
-- is to use a keybinding to toggle fullscreen noborders instead.  (M-<Space>)
-- <+> fullscreenEventHook


-- Recursively get all files (like `find`)
getAllFiles :: FilePath -> IO [FilePath]
getAllFiles path = do
    contents <- listDirectory path
    let fullPaths = map (path </>) contents
    files <- filterM doesFileExist fullPaths
    dirs  <- filterM doesDirectoryExist fullPaths
    nestedFiles <- concat <$> mapM getAllFiles dirs
    return $ files ++ nestedFiles

-- Pick a random element from a list
pickRandom :: [a] -> IO (Maybe a)
pickRandom [] = return Nothing
pickRandom xs = do
    idx <- randomRIO (0, length xs - 1)
    return $ Just (xs !! idx)

-- Pick a random wallpaper from a directory (as FilePath)
pickWallpaper :: FilePath -> IO FilePath
pickWallpaper dir = do
    files <- getAllFiles dir
    pickRandom files >>= \case
        Just f  -> return f
        Nothing -> return "/usr/share/backgrounds/cosmic/orion_nebula_nasa_heic0601a" -- fallback

main :: IO ()
main = do
    ws0wp <- pickWallpaper "/home/pascal/Pictures/wallpapers"
    ws1wp <- pickWallpaper "/home/pascal/Pictures/wallpapers"
    ws2wp <- pickWallpaper "/home/pascal/Pictures/wallpapers"
    ws3wp <- pickWallpaper "/home/pascal/Pictures/wallpapers"
    ws4wp <- pickWallpaper "/home/pascal/Pictures/wallpapers"
    ws5wp <- pickWallpaper "/home/pascal/Pictures/wallpapers"
    ws6wp <- pickWallpaper "/home/pascal/Pictures/wallpapers"
    ws7wp <- pickWallpaper "/home/pascal/Pictures/wallpapers"
    ws8wp <- pickWallpaper "/home/pascal/Pictures/wallpapers"

    -- writeFile "/tmp/xmonad-wallpapers.log" $
      -- "ws1wp: [" ++ ws1wp ++ "]\nws2wp: [" ++ ws2wp ++ "]\n"

    let myWallpaperConf = def {
          wallpapers = WallpaperList [
              (myWorkspaces !! 0, WallpaperFix ws0wp),
              (myWorkspaces !! 1, WallpaperFix ws1wp),
              (myWorkspaces !! 2, WallpaperFix ws2wp),
              (myWorkspaces !! 3, WallpaperFix ws3wp),
              (myWorkspaces !! 4, WallpaperFix ws4wp),
              (myWorkspaces !! 5, WallpaperFix ws5wp),
              (myWorkspaces !! 6, WallpaperFix ws6wp),
              (myWorkspaces !! 7, WallpaperFix ws7wp),
              (myWorkspaces !! 8, WallpaperFix ws8wp)
          ]
        }

    -- Start XMonad
    xmonad . withSB (mySBScreenCenter <> mySBScreenLeft <> mySBScreenRight) . ewmh . docks $ def
        { manageHook         = manageSpawn <+> myManageHook <+> manageDocks
        , handleEventHook    = myEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook            = wallpaperSetter myWallpaperConf
        } `additionalKeysP` myKeys `additionalMouseBindings` myMouseBindings
