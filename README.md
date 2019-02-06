# RxLua
Reactive Extensions for Lua

## Usage
Requiring
```lua
local Rx = require "Rx"
```

Using Observables:
```lua
 local observable = Rx.Observable(Rx.ObservableOnSubscribe(function (emitter)
  for i = 1, 10 do
    emitter.next(i)
    if(emitter:isDisposed()) then
      return
    end
  end
  emitter.complete()
 end)
 
 local disposable = observable:subscribe(Rx.Observer{
  onNext = function (x)
    print("Received: ", x)
  end,
  onError = print,
  onComplete = function ()
    print("Completed!")
  end
 })
```
