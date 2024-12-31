  -- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

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
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

    -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

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

   -- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP)
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

myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"
-- myFont = "xft:JetBrainsMono Nerd Font:size=14"
myModMask :: KeyMask
myModMask = mod1Mask        -- Sets modkey to alt key
-- myModMask = mod4Mask        -- Sets modkey to super/windows key

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
    -- spawnOnce "~/.screenlayout/mylayout.sh"
    spawnOnce "/usr/libexec/polkit-gnome-authentication-agent-1 &"
    spawnOnce "picom --config $HOME/.config/picom.conf --experimental-backends &"
    spawnOnce "nm-applet &"
    spawnOnce "volumeicon &"
    spawnOnce "xscreensaver --no-splash &"
    spawnOnce "trayer-srg --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0x282c34  --height 24 --monitor 1 &"
    spawnOnce "/usr/bin/emacs --daemon &" -- emacs daemon for the emacsclient
    spawnOnce "find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output HDMI-A-0 --stretch"
    spawnOnce "find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output DVI-D-1 --stretch"
    spawnOnce "find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output DVI-D-0 --stretch"
    spawnOnOnce " <fn=5>\xf745</fn> " "firefox-bin"
    spawnOnOnce " <fn=5>\xe795</fn> " "alacritty"
    spawnOnOnce " <fn=5>\xe7cf</fn> " "emacsclient -c -a 'emacs'"
    spawnOnOnce " <fn=5>\xe5fe</fn> " "pcmanfm"
    spawnOnOnce " <fn=5>\xf0e0</fn> " "thunderbird-bin"
    spawnOnce "nextcloud --background"
    spawnOnce "gnome-encfs-manager"
    setWMName "LG3D"
    setDefaultCursor xC_left_ptr
    windows (greedyViewOnScreen 0 " <fn=5>\xf745</fn> ")
    windows (greedyViewOnScreen 1 " <fn=5>\xe7cf</fn> ")
    windows (greedyViewOnScreen 2 " <fn=5>\xe795</fn> ")

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
                 , ("Deadbeef", "deadbeef")
                 , ("Emacs", "emacsclient -c -a emacs")
                 , ("Firefox", "firefox")
                 , ("Geany", "geany")
                 , ("Geary", "geary")
                 , ("Gimp", "gimp")
                 , ("Kdenlive", "kdenlive")
                 , ("LibreOffice Impress", "loimpress")
                 , ("LibreOffice Writer", "lowriter")
                 , ("OBS", "obs")
                 , ("PCManFM", "pcmanfm")
                 ]

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "mocp" spawnMocp findMocp manageMocp
                , NS "calculator" spawnCalc findCalc manageCalc
                ]
  where
    spawnTerm  = myTerminal ++ " -t scratchpad"
    findTerm   = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnMocp  = myTerminal ++ " -t mocp -e mocp"
    findMocp   = title =? "mocp"
    manageMocp = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnCalc  = "qalculate-gtk"
    findCalc   = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
               where
                 h = 0.5
                 w = 0.4
                 t = 0.75 -h
                 l = 0.70 -w

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
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
-- magnify  = renamed [Replace "magnify"]
--            $ smartBorders
--            $ windowNavigation
--            $ addTabs shrinkText myTabTheme
--            $ subLayout [] (smartBorders Simplest)
--            $ magnifier
--            $ limitWindows 12
--            $ mySpacing 8
--            $ ResizableTall 1 (3/100) (1/2) []
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
--myShowWNameTheme :: SWNConfig
--myShowWNameTheme = def
--    { swn_font              = "xft:JetBrainsMono Nerd Font:size=60"
--    , swn_fade              = 1.0
--    , swn_bgcolor           = "#1c1f24"
--    , swn_color             = "#ffffff"
--    }

-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     withBorder myBorderWidth tall
                                 -- ||| magnify
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| grid
                                 ||| spirals
                                 ||| threeCol
                                 ||| threeRow
                                 ||| tallAccordion
                                 ||| wideAccordion

-- myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
myWorkspaces = [" <fn=5>\xf03a4</fn> ", " <fn=5>\xf03a7</fn> ", " <fn=5>\xf03aa</fn> ", " <fn=5>\xf03ad</fn> ", " <fn=5>\xf03b1</fn> ", " <fn=5>\xf03b3</fn> ", " <fn=5>\xf03b6</fn> ", " <fn=5>\xf03b9</fn> ", " <fn=5>\xf03bc</fn> "]
-- myWorkspaces = [" <fn=5>\xf269</fn> ", " <fn=5>\xe7cf</fn> ", " <fn=5>\xe795</fn> ", " <fn=5>\xf07c</fn> ", " <fn=5>\xf0e0</fn> ", " <fn=5>\xf8b2</fn> ", " <fn=5>\xf8b5</fn> ", " <fn=5>\xf8b8</fn> ", " <fn=5>\xf8bb</fn> "]
-- myWorkspaces = [" <fn=5>\xf03a4</fn> ", " <fn=5>\xf03a7</fn> ", " <fn=5>\xf03aa</fn> ", " <fn=5>\xf03ad</fn> ", " <fn=5>\xf03b1</fn> ", " <fn=5>\xf03b3</fn> ", " <fn=5>\xf03b6</fn> ", " <fn=5>\xf03b9</fn> ", " <fn=5>\xf03bc</fn> "]

myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

--clickable ws = "<action=xdotool key alt+"++show i++">"++ws++"</action>"
--    where i = fromJust $ M.lookup ws myWorkspaceIndices

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
     ] <+> namedScratchpadManageHook myScratchPads

-- START_KEYS
myKeys :: [(String, X ())]
myKeys =
    -- KB_GROUP Xmonad
        [ ("M-S-l", spawn "xmonad --recompile")  -- Recompiles xmonad
        , ("M-S-r", spawn "xmonad --restart")    -- Restarts xmonad
        , ("M-S-q", io exitSuccess)              -- Quits xmonad
        , ("M-S-/", spawn "sh ~/.xmonad/xmonad_keys.sh")

    -- KB_GROUP Run Prompt
        , ("M-S-<Return>", spawn "rofi -show drun")

    -- KB_GROUP Useful programs to have a keybinding for launch
        , ("M-<Return>", spawn (myTerminal))
        , ("M-b", spawn (myBrowser))
        , ("M-m", spawn (myMail))
        , ("M-f", spawn (myFiles))

    -- KB_GROUP Kill windows
       -- , ("M-S-c", kill1)     -- Kill the currently focused client
       -- , ("M-S-a", killAll)   -- Kill all windows on current workspace

    -- KB_GROUP Workspaces
        , ("M-,", nextScreen)  -- Switch focus to next monitor
        , ("M-.", prevScreen)  -- Switch focus to prev monitor
        , ("M-S-.", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next ws
        , ("M-S-,", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to prev ws
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
        , ("C-g t", goToSelected $ mygridConfig myColorizer)  -- goto selected window
        , ("C-g b", bringSelected $ mygridConfig myColorizer) -- bring selected window

    -- KB_GROUP Windows navigation
        , ("M-'", windows W.focusMaster)  -- Move focus to the master window
        , ("M-o", windows W.focusDown)    -- Move focus to the next window
        , ("M-a",  windows W.focusUp)      -- Move focus to the prev window
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

    -- KB_GROUP Window resizing
        , ("M-p", sendMessage Shrink)                   -- Shrink horiz window width
        , ("M-y", sendMessage Expand)                   -- Expand horiz window width
        , ("M-M1-h", sendMessage MirrorShrink)          -- Shrink vert window width
        , ("M-M1-t", sendMessage MirrorExpand)          -- Expand vert window width

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

    -- KB_GROUP Scratchpads
    -- Toggle show/hide these programs.  They run on a hidden workspace.
    -- When you toggle them to show, it brings them to your current workspace.
    -- Toggle them to hide and it sends them back to hidden workspace (NSP).
    --    , ("M-s t", namedScratchpadAction myScratchPads "terminal")
    --    , ("M-s m", namedScratchpadAction myScratchPads "mocp")
    --    , ("M-s c", namedScratchpadAction myScratchPads "calculator")

    -- KB_GROUP Set wallpaper
    -- Set wallpaper with either 'xwallwaper'. Type 'SUPER+F1' to launch sxiv in the
    -- wallpapers directory; then in sxiv, type 'C-x x' to set the wallpaper that you
    -- choose.  Or, type 'SUPER+F2' to set a random wallpaper.
        , ("M-<F1>", spawn "find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output HDMI-A-0 --stretch")
        , ("M-<F2>", spawn "find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output DVI-D-1 --stretch")
        , ("M-<F3>", spawn "find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output DVI-D-0 --stretch")

    -- KB_GROUP Emacs (CTRL-e followed by a key)
        , ("C-e e", spawn (myEmacs))   -- emacs
      --  , ("C-e b", spawn (myEmacs ++ ("--eval '(ibuffer)'")))   -- list buffers
      --  , ("C-e d", spawn (myEmacs ++ ("--eval '(dired nil)'"))) -- dired
      --  , ("C-e i", spawn (myEmacs ++ ("--eval '(erc)'")))       -- erc irc client
      --  , ("C-e n", spawn (myEmacs ++ ("--eval '(elfeed)'")))    -- elfeed rss
      --  , ("C-e s", spawn (myEmacs ++ ("--eval '(eshell)'")))    -- eshell
      --  , ("C-e t", spawn (myEmacs ++ ("--eval '(mastodon)'")))  -- mastodon.el
      --  , ("C-e v", spawn (myEmacs ++ ("--eval '(+vterm/here nil)'"))) -- vterm if on Doom Emacs
      --  , ("C-e w", spawn (myEmacs ++ ("--eval '(doom/window-maximize-buffer(eww \"distrotube.com\"))'"))) -- eww browser if on Doom Emacs
      --  , ("C-e a", spawn (myEmacs ++ ("--eval '(emms)' --eval '(emms-play-directory-tree \"~/Music/\")'")))
        ]

    -- The following lines are needed for named scratchpads.
          where nonNSP          = WSIs (return (\ws -> W.tag ws /= "NSP"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))
-- END_KEYS

myIcons :: Query [String]
myIcons = composeAll
  [ className =? "firefox" --> appIcon " <fn=5>\xe745</fn> "
  , className =? "Emacs" --> appIcon " <fn=5>\xe7cf</fn> "
  , className =? "Alacritty" --> appIcon " <fn=5>\xe795</fn> "
  , className =? "Pcmanfm" --> appIcon " <fn=5>\xe5fe</fn> "
  , className =? "thunderbird-esr" --> appIcon " <fn=5>\xf370</fn> "
  , className =? "Discord" --> appIcon " <fn=5>\xf1ff</fn> "
  ]

myIconConfig :: IconConfig
myIconConfig = def { iconConfigIcons  = myIcons
                   , iconConfigFmt    = iconsFmtReplace (wrapUnwords "|" "|")
                   , iconConfigFilter = iconsGetAll
                   }

myXmobarPP :: PP
myXmobarPP = def
     { ppCurrent = xmobarColor "#9ece6a" "#282c34:0" . wrap "<box type=Bottom width=2 mb=2 color=#e0af68>" "</box>"         -- Current workspace
     , ppVisible = xmobarColor "#9ece6a" "#282c34:0"              -- Visible but not current workspace
     , ppHidden = xmobarColor "#7da6ff" "#282c34:0" . wrap "<box type=Top width=2 mt=2 color=#7da6ff>" "</box>"             -- Hidden workspaces
     , ppHiddenNoWindows = xmobarColor "#7da6ff" "#282c34:0"     -- Hidden workspaces (no windows)
     , ppTitle = xmobarColor "#787c99" "#282c34:0" . shorten 40               -- Title of active window
     , ppSep = wrapSep " "
     , ppUrgent = xmobarColor "#C45500" "#282c34:0" . wrap "!" "!"            -- Urgent workspace
     , ppLayout = xmobarColor "#ff6c6b" "#282c34:0" . wrap """"
     , ppWsSep         = xmobarColor "#282c34" "#282c34:0" "  "
     -- , ppExtras  = [windowCount]                                     -- # of windows current workspace
     -- , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]                    -- order of things in xmobar
     }
 where
  wrapSep :: String -> String
  wrapSep = wrap "<fc=#282c34><fn=4>\xe0b4</fn></fc>""<fc=#282c34><fn=4>\xe0b6</fn></fc>"


mySBScreenCenter :: StatusBarConfig
mySBScreenCenter = statusBarProp
  "xmobar -x 0 $HOME/.config/xmobar/xmobarrc0"
  --(clickablePP =<< dynamicIconsPP myIconConfig (filterOutWsPP [scratchpadWorkspaceTag] myXmobarPP))
  --(iconsPP myIcons myXmobarPP)
  (clickablePP =<< dynamicIconsPP myIconConfig (filterOutWsPP [scratchpadWorkspaceTag] myXmobarPP))

mySBScreenLeft :: StatusBarConfig
mySBScreenLeft = statusBarProp
  "xmobar -x 1 $HOME/.config/xmobar/xmobarrc1"
  --(dynamicIconsPP myIconConfig (filterOutWsPP [scratchpadWorkspaceTag] myXmobarPP))
  --(iconsPP myIcons (filterOutWsPP [scratchpadWorkspaceTag] myXmobarPP))
  (clickablePP =<< dynamicIconsPP myIconConfig (filterOutWsPP [scratchpadWorkspaceTag] myXmobarPP))

main :: IO ()
main = do
    -- the xmonad, ya know...what the WM is named after!
    xmonad . withSB (mySBScreenCenter <> mySBScreenLeft) . ewmh $ def
        { manageHook         = manageSpawn <+> myManageHook <+> manageDocks
        , handleEventHook    = docksEventHook
                               -- Uncomment this line to enable fullscreen support on things like YouTube/Netflix.
                               -- This works perfect on SINGLE monitor systems. On multi-monitor systems,
                               -- it adds a border around the window if screen does not have focus. So, my solution
                               -- is to use a keybinding to toggle fullscreen noborders instead.  (M-<Space>)
                               -- <+> fullscreenEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = myLayoutHook --  showWName' myShowWNameTheme
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        } `additionalKeysP` myKeys
        where
             wrapSep :: String -> String
             wrapSep = wrap "<fc=#282c34><fn=4>\xe0b4</fn></fc>""<fc=#282c34><fn=4>\xe0b6</fn></fc>"
