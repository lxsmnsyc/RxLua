local Observable = require "RxLua.observable"

math.randomseed(os.clock())

Observable.create(function (e)
    if(math.random()*100 < 50) then 
        e:onError("lose")
    else 
        e:onComplete()
    end
end)
:retry(function (c, x)
    print(c, x)
    return c < 5
end)
:subscribe{
    onNext = function (x)
        print(x)
    end,
    onComplete = function ()
        print("completed")
    end,
}

