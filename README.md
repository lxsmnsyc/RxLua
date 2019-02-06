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


## Interface
### Observers
Observer
```
interface Observer
 function onSubscribe(d : Disposable)
 function onNext(x : <any type>)
 function onError(err : <any type, mostly string>)
 function onComplete()
end
```
DisposableObserver
```
interface DisposableObserver implements Observer
 function onStart()
 function onNext(x : <any type>, dispose : DisposableObserver.dispose, isDisposed : DisposableObserver.isDisposed)
 
 function dispose()
 function isDisposed() returns boolean
end
```
DefaultObserver
```
interface DefaultObserver implements Observer
 function onNext(x : <any type>, cancel : function)
end
```
MaybeObserver
```
interface MaybeObserver
 function onSubscribe(d : Disposable)
 function onSuccess(x : <any type>)
 function onError(err : <any type, mostly string>)
 function onComplete()
end
```
DisposableMaybeObserver
```
interface DisposableMaybeObserver implements MaybeObserver
 function onStart()
 
 function dispose()
 function isDisposed() returns boolean
end
```
CompletableObserver
```
interface CompletableObserver
 function onSubscribe(d : Disposable)
 function onError(err : <any type, mostly string>)
 function onComplete()
end
```
DisposableCompletableObserver
```
interface DisposableCompletableObserver implements CompletableObserver
 function onStart()
 
 function dispose()
 function isDisposed() returns boolean
end
```

SingleObserver
```
interface SingleObserver
 function onSubscribe(d : Disposable)
 function onSuccess(x : <any type>)
 function onError(err : <any type, mostly string>)
end
```
DisposableSingleObserver
```
interface DisposableSingleObserver implements SingleObserver
 function onStart()
 
 function dispose()
 function isDisposed() returns boolean
end
```
