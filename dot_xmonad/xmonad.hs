import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig (additionalKeysP)
import qualified Data.Map as M
import XMonad.Layout.Spacing
import System.IO
--- Layouts
-- Resizable tile layout
import XMonad.Layout.ResizableTile
-- Simple two pane layout.
import XMonad.Layout.TwoPane
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.Dwindle

main = do
  xmproc <- spawnPipe "xmobar"
  xmonad $ docks def
    { layoutHook = spacing 5 $ avoidStruts $ layoutHook def
    , logHook = dynamicLogWithPP xmobarPP
      { ppOutput = hPutStrLn xmproc
      , ppTitle = xmobarColor "green" "" . shorten 50 }
    , terminal = myTerminal
    , modMask = myModMask
    , borderWidth = myBorderWidth
    } `additionalKeysP` myKeys

myTerminal :: String
myTerminal = "alacritty"

myBorderWidth :: Dimension
myBorderWidth = 3

myDmenu :: String
myDmenu = "dmenu_run -fn 'FiraCode-10'"

-- Keys
myModMask :: KeyMask
myModMask = mod4Mask

myKeys :: [(String, X ())]
myKeys =
    [
      (("M-p"), spawn myDmenu)

    ]
