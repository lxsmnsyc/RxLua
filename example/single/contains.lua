local Rx = require "RxLua"

Rx.Single.create(function (e)
    e:onSuccess("Hello World")
end)
:contains("Hello World")
:subscribe(
    function (x)
        print("Contains result:", x)
    end, 
    print
)

Rx.Single.create(function (e)
    e:onSuccess("Not Hello World")
end)
:contains("Hello World")
:subscribe(
    function (x)
        print("Contains result:", x)
    end, 
    print
)


Rx.Single.create(function (e)
    e:onSuccess(0xDEADBEEF)
end)
:contains(2, function (received, base)
    return received % base == 0
end)
:subscribe(
    function (x)
        print("Found even:", x)
    end, 
    print
)

Rx.Single.create(function (e)
    e:onSuccess(0xDEADBEE)
end)
:contains(2, function (received, base)
    return received % base == 0
end)
:subscribe(
    function (x)
        print("Found even:", x)
    end, 
    print
)