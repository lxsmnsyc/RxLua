return function (evaluateSuccess, argNo, context, expectedType, receivedType)
    argNo = argNo or 1
    if(context) then 
        context = " to '"..context.."'"
    else 
        context = ""
    end

    local appended = ")."
    if(receivedType) then 
        appended = ", got "..receivedType..")."
    end 
    assert(evaluateSuccess, "bad argument #"..argNo..context.." ("..expectedType.." expected"..appended)
end 