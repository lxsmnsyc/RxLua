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
    local sources = self._sources 

    if(#sources == 1) then 
        return sources[1]:subscribe(observer)
    end

    local disposables = {}


    local disposed = false
    local winner 
    
    local function disposeAll()
        for k, v in pairs(disposables) do 
            if(v ~= winner) then 
                dispose(v)
            end
        end
        disposed = true
    end

    local function isDisposedAll()
        return disposed and isDisposed(winner)
    end

    for k, v in pairs(self._sources) do 
        local upstream
        v:subscribe({
            onSubscribe = function (d)
                if(upstream) then 
                    dispose(d)
                else 
                    upstream = d
                    disposables[#disposables + 1] = d 
                end
            end,
            onNext = function (x)
                if(not winner) then 
                    winner = upstream
                    disposeAll()
                end
                if(winner == upstream) then 
                    pcall(observer.onNext, x)
                end
            end,
            onError = function (t)
                if(not winner) then 
                    winner = upstream
                    disposeAll()
                end
                if(winner == upstream) then 
                    pcall(observer.onError, t)
                end
            end,
            onComplete = function ()
                if(not winner) then 
                    winner = upstream
                    disposeAll()
                end
                if(winner == upstream) then 
                    pcall(observer.onComplete)
                end
            end,
        })
    end

    return {
        dispose = disposeAll,
        isDisposed = isDisposedAll
    }
end

return function (sources)
    local observable = new()

    observable._sources = sources 
    observable.subscribe = subscribeActual

    return observable
end