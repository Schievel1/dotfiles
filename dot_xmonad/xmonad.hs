import XMonad
import XMonad.Layout.Fullscreen
    ( fullscreenEventHook, fullscreenManageHook, fullscreenSupport, fullscreenFull )
import Data.Monoid ()
import System.Exit ()
import XMonad.Util.SpawnOnce ( spawnOnce )
import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioLowerVolume, xF86XK_AudioRaiseVolume, xF86XK_AudioMute, xF86XK_MonBrightnessDown, xF86XK_MonBrightnessUp, xF86XK_AudioPlay, xF86XK_AudioPrev, xF86XK_AudioNext)
import XMonad.Hooks.EwmhDesktops ( ewmh )
import Control.Monad ( join, when )
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageDocks
    ( avoidStruts, docks, manageDocks, Direction2D(D, L, R, U) )
import XMonad.Hooks.ManageHelpers ( doFullFloat, isFullscreen )
import XMonad.Layout.Spacing ( spacingRaw, Border(Border) )
import XMonad.Layout.Gaps
    ( Direction2D(D, L, R, U),
      gaps,
      setGaps,
      GapMessage(DecGap, ToggleGaps, IncGap) )

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Maybe (maybeToList)

import XMonad.Actions.SpawnOn
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen, shiftNextScreen, shiftPrevScreen)
import XMonad.Util.EZConfig (additionalKeysP)
import System.Exit (exitSuccess)
import XMonad.Util.Cursor
import XMonad.Actions.OnScreen
import XMonad.Actions.MouseResize

-- for dock
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, dynamicLogString, wrap, xmobarPP, xmobarColor, xmonadPropLog, shorten, PP(..))
import XMonad.Util.ClickableWorkspaces
import System.IO (hPutStrLn)
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)

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
-- import XMonad.Layout.Magnifier
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
import XMonad.Hooks.DynamicIcons

import XMonad.Hooks.WindowSwallowing
-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myFont :: String
myFont = "xft:Fira Code:regular:size=15:antialias=true:hinting=true"

myTerminal :: String
myTerminal      = "alacritty"

myBrowser :: String
myBrowser = "firefox-bin"  -- Sets firefox as Browser

myMail :: String
myMail = "emacs --eval '(mu4e)'"  -- Sets evolution as mail client

myEmacs :: String
myEmacs = "emacsclient -c -a 'emacs' --socket-name=/tmp/emacs1000/server "  -- Makes emacs keybindings easier to type

myEditor :: String
myEditor = "emacsclient -c -a 'emacs' "  -- Sets emacs as editor

myEmacsEverywhere :: String
myEmacsEverywhere = "emacsclient --eval '(emacs-everywhere)'"

myFiles :: String
myFiles = "pcmanfm"
-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth :: Dimension
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod1Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
-- myWorkspaces    = ["\63083", "\63288", "\63306", "\61723", "\63107", "\63601", "\63391", "\61713", "\61884"]
-- myWorkspaces = [" \xf269 ", " \xe795 ", " \xf07c ", " \xf0e0 ", " \xf15c ", " \xfb6e ", " \xf8b5 ", " \xf8b8 ", " \xf8bb "]
myWorkspaces = [" <fn=5>\xf269</fn> ", " <fn=5>\xe795</fn> ", " <fn=5>\xf07c</fn> ", " <fn=5>\xf0e0</fn> ", " <fn=5>\xf15c</fn> ", " <fn=5>\xfb6e</fn> ", " <fn=5>\xf8b5</fn> ", " <fn=5>\xf8b8</fn> ", " <fn=5>\xf8bb</fn> "]
-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor :: String
myNormalBorderColor   = "#282c34"   -- Border color of normal windows
-- myNormalBorderColor  = "#3b4252"

myFocusedBorderColor :: String
myFocusedBorderColor  = "#46d9ff"   -- Border color of focused windows
-- myFocusedBorderColor = "#bc96da"

addNETSupported :: Atom -> X ()
addNETSupported x   = withDisplay $ \dpy -> do
    r               <- asks theRoot
    a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
    a               <- getAtom "ATOM"
    liftIO $ do
       sup <- (join . maybeToList) <$> getWindowProperty32 dpy a_NET_SUPPORTED r
       when (fromIntegral x `notElem` sup) $
         changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen   = do
    wms <- getAtom "_NET_WM_STATE"
    wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
    mapM_ addNETSupported [wms, wfs]

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
clipboardy :: MonadIO m => m () -- Don't question it 
clipboardy = spawn "rofi -modi \"\63053 :greenclip print\" -show \"\63053 \" -run-command '{cmd}' -theme ~/.config/rofi/launcher/launcher.rasi"

centerlaunch = spawn "exec ~/bin/eww open-many blur_full weather profile quote search_full disturb-icon vpn-icon home_dir screenshot power_full reboot_full lock_full logout_full suspend_full"
sidebarlaunch = spawn "exec ~/bin/eww open-many weather_side time_side smol_calendar player_side sys_side sliders_side"
ewwclose = spawn "exec ~/bin/eww close-all"
-- maimcopy = spawn "maim -s | xclip -selection clipboard -t image/png && notify-send \"Screenshot\" \"Copied to Clipboard\" -i flameshot"
-- maimsave = spawn "maim -s ~/Desktop/$(date +%Y-%m-%d_%H-%M-%S).png && notify-send \"Screenshot\" \"Saved to Desktop\" -i flameshot"
rofi_launcher = spawn "rofi -no-lazy-grab -show drun -modi run,drun,window -theme $HOME/.config/rofi/launcher/launcher -drun-icon-theme \"candy-icons\" "

myEventHook = swallowEventHook (className =? "Alacritty" <||> className =? "Termite") (return True)

myKeys :: [(String, X ())]
myKeys = [
    -- additional stuff
          ("M-C-q", spawn "xscreensaver-command -lock")
    -- launch rofi and dashboard
         , ("M-S-<Return>", rofi_launcher)
         , ("M-p", centerlaunch)
         , ("M-S-p", ewwclose)

    -- launch eww sidebar
         , ("M-s",sidebarlaunch)
         , ("M-S-s", ewwclose)

    -- My Stuff
         -- , ("M-b", spawn "exec ~/bin/bartoggle")
         , ("M-S-b", spawn "exec ~/bin/inhibit_activate")
         , ("M-S-z", spawn "exec ~/bin/inhibit_deactivate")
         , ("M-S-a", clipboardy)
    -- Turn do not disturb on and off
         , ("M-d", spawn "exec ~/bin/do_not_disturb.sh")

    -- close focused window
         , ("M-S-c", kill)
    -- KB_GROUP Xmonad
        , ("M-C-r", spawn "xmonad --recompile")  -- Recompiles xmonad
        , ("M-S-r", spawn "xmonad --restart")    -- Restarts xmonad
        , ("M-S-q", io exitSuccess)              -- Quits xmonad
    -- KB_GROUP Useful programs to have a keybinding for launch
        , ("M-<Return>", spawn (myTerminal))
        , ("M-b", spawn (myBrowser))
        , ("M-m", spawn (myMail))
        , ("M-f", spawn (myFiles))
    -- KB_GROUP Workspaces
        , ("M-,", nextScreen)  -- Switch focus to next monitor
        , ("M-.", prevScreen)  -- Switch focus to prev monitor
        , ("C-,", shiftNextScreen >> nextScreen) -- Shifts focused window to monitor on the left
        , ("C-.", shiftPrevScreen >> prevScreen) -- Shifts focused window to monitor on the right
    -- KB_GROUP Floating windows
        -- , ("M-n", sendMessage (T.Toggle "floats")) -- Toggles my 'floats' layout
        , ("M-t", withFocused $ windows . W.sink)  -- Push floating window back to tile
        -- , ("M-S-t", sinkAll)                       -- Push ALL floating windows to tile
    -- KB_GROUP Increase/decrease spacing (gaps)
        -- , ("C-M1-h", decWindowSpacing 4)         -- Decrease window spacing
        -- , ("C-M1-t", incWindowSpacing 4)         -- Increase window spacing
        -- , ("C-M1-d", decScreenSpacing 4)         -- Decrease screen spacing
        -- , ("C-M1-n", incScreenSpacing 4)         -- Increase screen spacing
    -- KB_GROUP Windows navigation
        , ("M-'", windows W.focusMaster)  -- Move focus to the master window
        , ("M-o", windows W.focusDown)    -- Move focus to the next window
        , ("M-a",  windows W.focusUp)      -- Move focus to the prev window
        , ("M-S-'", windows W.swapMaster) -- Swap the focused window and the master window
        , ("M-S-o", windows W.swapDown)   -- Swap focused window with next window
        , ("M-S-a", windows W.swapUp)     -- Swap focused window with prev window
        -- , ("M-<Backspace>", promote)      -- Moves focused window to master, others maintain order
        -- , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
        -- , ("M-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack
    -- KB_GROUP Layouts
        , ("M-<Tab>", sendMessage NextLayout)           -- Switch to next layout

    -- KB_GROUP Increase/decrease windows in the master pane or the stack
        , ("M-S-<Up>", sendMessage (IncMasterN 1))      -- Increase # of clients master pane
        , ("M-S-<Down>", sendMessage (IncMasterN (-1))) -- Decrease # of clients master pane
        -- , ("M-C-<Up>", increaseLimit)                   -- Increase # of windows
        -- , ("M-C-<Down>", decreaseLimit)                 -- Decrease # of windows
    -- KB_GROUP Window resizing
        , ("M-+", sendMessage Shrink)                   -- Shrink horiz window width
        , ("M--", sendMessage Expand)                   -- Expand horiz window width
        -- , ("M-M1-h", sendMessage MirrorShrink)          -- Shrink vert window width
        -- , ("M-M1-t", sendMessage MirrorExpand)          -- Expand vert window width
    -- choose.  Or, type 'SUPER+F2' to set a random wallpaper.
        , ("M-<F1>", spawn "find /home/pascal/Pictures/BingWallpaper -type f | shuf -n 1 | xargs xwallpaper --output HDMI-0 --stretch")
        , ("M-<F2>", spawn "find /home/pascal/Pictures/BingWallpaper -type f | shuf -n 1 | xargs xwallpaper --output DVI-I-1 --stretch")
        , ("M-<F3>", spawn "find /home/pascal/Pictures/BingWallpaper -type f | shuf -n 1 | xargs xwallpaper --output DVI-D-0 --stretch")
    -- KB_GROUP Emacs (CTRL-e followed by a key)
        , ("C-e e", spawn (myEmacs))   -- emacs
        , ("C-e b", spawn (myEmacs ++ ("--eval '(ibuffer)'")))   -- list buffers
        , ("C-e d", spawn (myEmacs ++ ("--eval '(dired nil)'"))) -- dired
        , ("C-e m", spawn (myEmacs ++ ("--eval '(mu4e)'"))) -- mu4e
          --  , ("C-e i", spawn (myEmacs ++ ("--eval '(erc)'")))       -- erc irc client
      --  , ("C-e n", spawn (myEmacs ++ ("--eval '(elfeed)'")))    -- elfeed rss
        , ("C-e s", spawn (myEmacs ++ ("--eval '(eshell)'")))    -- eshell
          --  , ("C-e t", spawn (myEmacs ++ ("--eval '(mastodon)'")))  -- mastodon.el
        , ("C-e v", spawn (myEmacs ++ ("--eval '(+vterm/here nil)'"))) -- vterm if on Doom Emacs
          --  , ("C-e w", spawn (myEmacs ++ ("--eval '(doom/window-maximize-buffer(eww \"distrotube.com\"))'"))) -- eww browser if on Doom Emacs
      --  , ("C-e a", spawn (myEmacs ++ ("--eval '(emms)' --eval '(emms-play-directory-tree \"~/Music/\")'")))
        , ("M-i", spawn (myEmacsEverywhere))
        ]

    -- ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    -- [((m .|. modm, k), windows $ f i)
    --     | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
    --     , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
-- myLayout = avoidStruts(tiled ||| Mirror tiled ||| Full)
--   where
--      -- default tiling algorithm partitions the screen into two panes
--      tiled   = Tall nmaster delta ratio

--      -- The default number of windows in the master pane
--      nmaster = 1

--      -- Default proportion of screen occupied by master pane
--      ratio   = 1/2

--      -- Percent of screen to increment by when resizing panes
--      delta   = 3/100

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
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats $ smartBorders
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     withBorder myBorderWidth tall
                                 ||| grid
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| spirals
                                 ||| threeCol
                                 ||| threeRow
                                 ||| tallAccordion
                                 ||| wideAccordion
------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = fullscreenManageHook <+> manageDocks <+> composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , className =? "confirm"         --> doFloat
    , className =? "file_progress"   --> doFloat
    , className =? "dialog"          --> doFloat
    , className =? "download"        --> doFloat
    , className =? "error"           --> doFloat
    , className =? "Gimp"            --> doFloat
    , className =? "notification"    --> doFloat
    , className =? "pinentry-gtk-2"  --> doFloat
    , className =? "splash"          --> doFloat
    , className =? "toolbar"         --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , title =? "Mozilla Firefox"     --> doShift ( myWorkspaces !! 0 )
    , title =? "Mozilla Thunderbird" --> doShift ( myWorkspaces !! 3 )
    , className =? "Evolution"       --> doShift ( myWorkspaces !! 3 )
    , className =? "Thunderbird"     --> doShift ( myWorkspaces !! 3 )
    , className =? "org.gnome.Nautilus" --> doShift ( myWorkspaces !! 2 )
    , className =? "pcmanfm" --> doShift ( myWorkspaces !! 2 )
    , className =? "discord" --> doShift ( myWorkspaces !! 5 )
    , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
    , (className =? "evolution" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
    , (className =? "thunderbird" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
    , resource  =? "desktop_window" --> doIgnore
    , isFullscreen --> doFullFloat
                                 ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--


------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook :: X ()
myStartupHook = do
  setDefaultCursor xC_left_ptr
  spawnOnce "setxkbmap us"
  spawnOnce "gentoo-pipewire-launcher &"
  spawnOnce "exec ~/bin/bartoggle"
  spawnOnce "exec ~/bin/eww daemon"
  spawnOnce "exec ~/.config/eww/scripts/getweather"
  spawn "xsetroot -cursor_name left_ptr"
  -- setDefaultCursor xC_left_ptr
  spawn "exec ~/bin/lock.sh"
  -- spawnOnce "feh --bg-scale ~/wallpapers/yosemite-lowpoly.jpg"
  spawnOnce "picom --experimental-backends"
  spawnOnce "greenclip daemon"
  spawnOnce "dunst"
  spawnOnce "nm-applet &"
  spawnOnce "volumeicon &"
  spawnOnce "/usr/libexec/polkit-gnome-authentication-agent-1 &"
  spawnOnce "xscreensaver --no-splash &"
  spawnOnce "trayer-srg --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0x282c34  --height 24 --monitor 1 &"
  -- spawnOnce "/usr/bin/emacs --daemon &" -- emacs daemon for the emacsclient
  spawnOn " <fn=5>\xe795</fn> " myTerminal
  spawnOn " <fn=5>\xf15c</fn> " myEditor
  spawnOn " <fn=5>\xf0e0</fn> " "emacs --eval '(mu4e)' '(ement-connect)'"
  spawnOn " <fn=5>\xf07c</fn> " myFiles
  spawnOn " <fn=5>\xfb6e</fn> " "discord --start-minimized"
  spawnOnce "nextcloud --background"
  spawnOnce "gnome-encfs-manager"
  spawnOnce (("sleep 5 && ") ++ (myBrowser))
  spawnOnce "sleep 3 && find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output HDMI-0 --stretch"
  spawnOnce "sleep 4 && find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output DVI-I-1 --stretch"
  spawnOnce "sleep 5 && find /home/pascal/Pictures/wallpapers -type f | shuf -n 1 | xargs xwallpaper --output DVI-D-0 --stretch"
  windows (greedyViewOnScreen 1 " <fn=5>\xf15c</fn> ")
  windows (greedyViewOnScreen 2 " <fn=5>\xe795</fn> ")
  prevScreen
  sendMessage $ NextLayout
------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

myIconConfig :: IconConfig
myIconConfig = def { iconConfigIcons  = myIcons
                   , iconConfigFmt    = iconsFmtReplace (wrapUnwords "" "")
                   , iconConfigFilter = iconsGetFocus
                   }
myIcons :: Query [String]
myIcons = composeAll
      [ className =? "discord" --> appIcon "<fn=5>\xfb6e</fn>"
      , className =? "chrome" --> appIcon "<fn=5>\xf268</fn>"
      , className =? "firefox" --> appIcon "<fn=5>\xf269</fn>"
      , className =? "Brave-browser" --> appIcon "<fn=5>\xf268</fn>"
      , className =? "St" --> appIcon "<fn=5>\xe795</fn>"
      , className =? "Emacs" --> appIcon "<fn=5>\xf15c</fn>"
      , className =? "code-oss" --> appIcon "<fn=5>\xe60c</fn>"
      , className =? "Org.gnome.Nautilus" --> appIcon "<fn=5>\xf07c</fn>"
      , className =? "pcmanfm" --> appIcon "<fn=5>\xf07c</fn>"
      , className =? "Spotify" --> appIcon "<fn=5>\xf1bc</fn>"
      , className =? "mpv" --> appIcon "<fn=5>\xf03d</fn>"
      , className =? "VirtualBox Manager" --> appIcon "<fn=5>\xea3e</fn>"
      , className =? "Lutris" --> appIcon "<fn=5>\xf11b</fn>"
      , className =? "Sxiv" --> appIcon "<fn=5>\xf03e</fn>"
      , className =? "Alacritty" --> appIcon "<fn=5>\xe795</fn>"
      , className =? "thunderbird" --> appIcon "<fn=5>\xf0e0</fn>"
      ]

-- Run xmonad with the settings you specify. No need to modify this.
--
main :: IO ()
main = do
    -- Launching three instances of xmobar on their monitors.
    xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc0"
    xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc1"
    xmproc2 <- spawnPipe "xmobar -x 2 $HOME/.config/xmobar/xmobarrc2"
    xmonad $ fullscreenSupport $ docks $ ewmh def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        -- keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        manageHook = manageSpawn <+> myManageHook <+> manageDocks,
        layoutHook = myLayoutHook,
        handleEventHook    = myEventHook,
        startupHook        = myStartupHook >> addEWMHFullscreen,
        logHook = dynamicLogIconsWithPP myIcons xmobarPP
              -- the following variables beginning with 'pp' are settings for xmobar.
              { ppOutput = \x -> hPutStrLn xmproc0 x                          -- xmobar on monitor 1
                              >> hPutStrLn xmproc1 x                          -- xmobar on monitor 2
                              >> hPutStrLn xmproc2 x                          -- xmobar on monitor 3
              , ppCurrent = xmobarColor "#9ece6a" "#282c34:0" . wrap "<box type=Bottom width=2 mb=2 color=#e0af68>" "</box>"         -- Current workspace
              , ppVisible = xmobarColor "#9ece6a" "#282c34:0"              -- Visible but not current workspace
              , ppHidden = xmobarColor "#7da6ff" "#282c34:0" . wrap "<box type=Top width=2 mt=2 color=#7da6ff>" "</box>" -- Hidden workspaces
              , ppHiddenNoWindows = xmobarColor "#7da6ff" "#282c34:0"   -- Hidden workspaces (no windows)
              , ppTitle = xmobarColor "#787c99" "#282c34:0" . shorten 40               -- Title of active window
              , ppSep = wrapSep " "
              , ppUrgent = xmobarColor "#C45500" "#282c34:0" . wrap "!" "!"            -- Urgent workspace
              , ppLayout = xmobarColor "#ff6c6b" "#282c34:0" . wrap """"
              , ppWsSep         = xmobarColor "#282c34" "#282c34:0" "  "
             -- , ppExtras  = [windowCount]                                     -- # of windows current workspace
              , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]                    -- order of things in xmobar
              }
    } `additionalKeysP` myKeys
        where
             wrapSep :: String -> String
             wrapSep = wrap "<fc=#282c34><fn=4>\xe0b4</fn></fc>""<fc=#282c34><fn=4>\xe0b6</fn></fc>"
-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'super'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
