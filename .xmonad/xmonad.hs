import XMonad

import qualified System.Exit as Exit
import qualified Data.Map        as M

import qualified XMonad.Actions.Volume as Volume

import qualified XMonad.Hooks.ManageDocks as Docks
import qualified XMonad.Hooks.EwmhDesktops as EWMH

import qualified XMonad.Layout.Spacing as Spacing
import qualified XMonad.Layout.Gaps as Gaps
import qualified XMonad.Layout.Grid as Grid
import qualified XMonad.Layout.Tabbed as Tabbed

import qualified XMonad.StackSet as W

import qualified XMonad.Util.Run as Run
import qualified XMonad.Util.SpawnOnce as Spawn

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal :: String
myTerminal = "alacritty"

-- Whether focus follows the mouse pointer.
--
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
--
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 10

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
--myWorkspaces    = ["1:>_","2:<>","3:__","4:__","5:__","6:__","7:__","8:~~","9:$$"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#282828"
myFocusedBorderColor = "#b16286"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch rofi application launcher
    , ((modm,               xK_p     ), spawn "rofi -modi \"drun,window,ssh\" -show drun")

    -- launch rofi ssh launcher
    , ((modm .|. shiftMask, xK_p     ), spawn "rofi -modi \"drun,window,ssh\" -show window")

    -- screenshot (full)
    -- relies on ImageMagick
    , ((modm,               xK_x     ), spawn "import -window root ${HOME}/Pictures/screenshot-$(date +%Y-%m-%d-%H-%M-%S).png")

    -- screenshot (partial)
    -- relies on ImageMagick
    , ((modm .|. shiftMask, xK_x     ), spawn "import ${HOME}/Pictures/screenshot-$(date +%Y-%m-%d-%H-%M-%S).png")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Resize viewed windows to the correct size
    , ((modm .|. shiftMask, xK_n     ), spawn "alacritty -e vifm")

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm .|. shiftMask, xK_Tab   ), windows W.focusUp)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (Exit.exitWith Exit.ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "notify-send \"Restarting XMonad...\" && killall -q polybar && xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))

    -- Use xev to get the masks for the volume and brightness function keys, as here:
    -- https://unix.stackexchange.com/a/400608

    -- Decrease volume: XF86AudioLowerVolume
    , ((0, 0x1008ff11), Volume.lowerVolume 3 >> return())

    -- Increase volume: XF86AudioRaiseVolume
    , ((0, 0x1008ff13), Volume.raiseVolume 3 >> return())

    -- Toggle mute: XF86AudioMute
    , ((0, 0x1008ff12), Volume.toggleMute >> return())

    -- Decrease brightness: XF86MonBrightnessDown
    , ((0, 0x1008ff03), spawn "xbacklight -5")

    -- Increase brightness: XF86MonBrightnessUp
    , ((0, 0x1008ff02), spawn "xbacklight +5")

    -- Play/Pause: XF86AudioPlay
    , ((0, 0x1008ff14), spawn "notify-send \"Play/Pause\"")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


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
--myTabConfig = def { inactiveBorderColor = "#FF0000"
--                  , activeTextColor = "#000000"
--                  , fontName = "Ubuntu Mono"}

-- Colors for text and backgrounds of each tab when in "Tabbed" layout.

myLayout = Docks.avoidStruts (Spacing.spacing myGap $ Gaps.gaps [(Docks.U, myGap), (Docks.L, myGap), (Docks.D, myGap), (Docks.R, myGap)] $ Grid.Grid ||| Tall 1 (3/100) (1/2) ||| Tabbed.simpleTabbed )
  where
     -- 
     myGap = 10
     tallNMaster = 1
     tallRatioIncrement = 3/100
     tallRatio = 1/2

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
--myManageHook :: Query (Data.Monoid.Endo WindowSet)
--myManageHook = composeAll
--    [ className =? "MPlayer"        --> doFloat
--    , className =? "Gimp"           --> doFloat
--    , resource  =? "desktop_window" --> doIgnore
--    , resource  =? "kdesktop"       --> doIgnore ]

--myManageHook :: Query (Data.Monoid.Endo WindowSet)
--myManageHook = composeAll
--     [ className =? "Firefox"   --> doShift ( myWorkspaces !! 1)
--     , className =? "Signal"    --> doShift ( myWorkspaces !! 7)
--     , className =? "Bitwarden" --> doShift ( myWorkspaces !! 8)
--     , className =? "Enpass"    --> doShift ( myWorkspaces !! 8)
--     , (className =? "Firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
--     ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
--myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--myLogHook = return ()
------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
-- myStartupHook = return ()
myStartupHook = do
--	Spawn.spawnOnce "nitrogen --restore &" -- Wallpaper
--	Spawn.spawnOnce "picom &" -- Transparency
	Spawn.spawnOnce "alacritty" -- Terminal
--	Spawn.spawnOnce "dropbox start &" -- Dropbox
--	Spawn.spawnOnce "signal-desktop &" -- Signal
--	Spawn.spawnOnce "bitwarden &" -- Bitwarden
--	Spawn.spawnOnce "Enpass &" -- Enpass
--	Spawn.spawnOnce "firefox &" -- Firefox
--	Spawn.spawnOnce "nm-applet &" -- Network Manager
--	Spawn.spawnOnce "volumeicon &" -- Volume
--	Spawn.spawnOnce "trayer --edge top --align right --margin 5 --width 5 --height 25 --SetDockType true --SetPartialStrut true --transparent true --alpha 0 --tint 0x292d3e --padding 5 --expand true --monitor 0 &"
--
--------------------------------------------------------------------------
---- Now run xmonad with all the defaults we set up.
--
---- Run xmonad with the settings you specify. No need to modify this.
----
---- main = xmonad defaults
main = do
	xmproc <- Run.spawnPipe "xmobar -x 0 /home/davis/.config/xmobar/xmobar.config"
	pbproc0 <- Run.spawnPipe "polybar -c=/home/davis/.config/polybar/config pulse"
--	pbproc1 <- Run.spawnPipe "polybar -c=/home/davis/.config/polybar/config desk"
	xmonad $ EWMH.ewmh $ Docks.docks def {
          terminal           = myTerminal
        , focusFollowsMouse  = myFocusFollowsMouse
        , clickJustFocuses   = myClickJustFocuses
        , borderWidth        = myBorderWidth
        , modMask            = myModMask
--        , workspaces         = myWorkspaces
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , keys               = myKeys
        , mouseBindings      = myMouseBindings
        , layoutHook         = myLayout
--        , manageHook         = myManageHook
--        , handleEventHook    = myEventHook
        , logHook = EWMH.ewmhDesktopsLogHook
--        , logHook            = dynamicLogWithPP xmobarPP
--                        { ppOutput = hPutStrLn xmproc
--                        , ppCurrent = xmobarColor "#c3e88d" "" . wrap "[" "]" -- Current workspace in xmobar
--                        , ppVisible = xmobarColor "#c3e88d" ""                -- Visible but not current workspace
--                        , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" ""   -- Hidden workspaces in xmobar
--                        , ppHiddenNoWindows = xmobarColor "#F07178" ""        -- Hidden workspaces (no windows)
--                        , ppTitle = return ""                                 -- Title of active window in xmobar
--                        , ppLayout = return ""                                -- Name of active layout
--                        , ppSep =  "|"                                        -- Separators in xmobar
--                        , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"  -- Urgent workspace
--                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
--                        }
        , startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
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
