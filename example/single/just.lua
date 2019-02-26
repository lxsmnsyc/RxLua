local Rx = require "RxLua"

Rx.Single.create("Hello World")
:subscribe(print, error)