import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
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
    , borderWidth = myBorderWidth }

myTerminal = "alacritty"
myModMask = mod4Mask
myBorderWidth = 3
