local Rx = require "RxLua"

Rx.Single.just("Hello World")
:subscribe(print, error)