import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeysP)
import XMonad.Util.SpawnOnce
import XMonad.Config.Desktop
import XMonad.Layout.Spacing
import System.IO(hPutStrLn)

myTerminal :: String
myTerminal = "alacritty"

myStartupHook :: X ()
myStartupHook = do
        spawnOnce "variety &"
        spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x282c34  --height 20 &"
        spawnOnce "nm-applet &"
        spawnOnce "blueberry-tray &"
        spawnOnce "picom &"


main :: IO ()
main = do
  xmproc <- spawnPipe ("xmobar")

  xmonad $ desktopConfig
        { manageHook = manageDocks <+> manageHook desktopConfig
        , layoutHook = spacing 10 $ avoidStruts $  layoutHook desktopConfig
        , logHook = dynamicLogWithPP $ xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 100
                        }
        , borderWidth = 2
        , modMask = mod4Mask
        , terminal = myTerminal
        , startupHook = myStartupHook
        , normalBorderColor = "#cccccc"
        , focusedBorderColor = "#cd8b00" }
