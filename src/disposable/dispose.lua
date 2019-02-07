--[[
    Reactive Extensions for Lua
	
    MIT License
    Copyright (c) 2019 Alexis Munsayac
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]  
local is = require "RxLua.src.disposable.is"

local isDisposable = require "RxLua.src.is.disposable"

local isDisposed = require "RxLua.src.disposable.isDisposed"

local CompositeDisposable = require "RxLua.src.disposable.composite.dispose"
local DisposableObserver = require "RxLua.src.observer.disposable.dispose"
local DisposableMaybeObserver = require "RxLua.src.observer.maybe.disposable.dispose"
local DisposableCompletableObserver = require "RxLua.src.observer.completable.disposable.dispose"
local DisposableSingleObserver = require "RxLua.src.observer.single.disposable.dispose"

local function dispose(disposable)
    if(is(disposable)) then 
        local cleanup = disposable.cleanup
        disposable._isDisposed = true 

        if(type(cleanup) == "function") then 
            disposable.cleanup()

            disposable.cleanup = nil
        end

        return true 
    end
    return false
end

return function (disposable)
    assert(isDisposable(disposable), "bad argument #1 to '"..debug.getinfo(1).name.."' (Disposable expected)")

    
    return dispose(disposable)
        or CompositeDisposable(disposable)
        or DisposableObserver(disposable)
        or DisposableMaybeObserver(disposable)
        or DisposableCompletableObserver(disposable)
        or DisposableSingleObserver(disposable)
end 