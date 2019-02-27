local Rx = require "RxLua"

Rx.Single.never()
:subscribe(print, error)