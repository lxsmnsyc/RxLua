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
--]] 
local new = require "RxLua.observable.new"

local dispose = require "RxLua.disposable.dispose"
local isDisposed = require "RxLua.disposable.isDisposed"

local function subscribeActual(self, observer)
    local source = self._source 
    local amount = self._amount 

    local upstream 

    local disposable = {
        dispose = function ()
            dispose(upstream)
        end,
        isDisposed = function ()
            return isDisposed(upstream)
        end
    }

    local onNext = observer.onNext
    local onError = observer.onError 
    local onComplete = observer.onComplete

    local function resub()
        source:subscribe{
            onSubscribe = function (d)
                upstream = d
            end,
            onNext = function (x)
                pcall(onNext, x)
            end,
            onError = function (x)
                pcall(onError, x)
                
                if(not isDisposed(upstream)) then 
                    if(amount) then 
                        amount = amount - 1 
                        if(amount >= 0) then 
                            resub()
                        end
                    else 
                        resub()
                    end
                end
            end,
            onComplete = function ()
                pcall(onComplete)
                
                if(not isDisposed(upstream)) then 
                    if(amount) then 
                        amount = amount - 1 
                        if(amount >= 0) then 
                            resub()
                        end
                    else 
                        resub()
                    end
                end
            end,
        }
    end

    pcall(observer.onSubscribe, disposable)
    resub()

    return disposable
end

return function (self, amount)
    local observable = new()
    observable._source = self
    observable._amount = amount
    observable.subscribe = subscribeActual 
    return observable
end