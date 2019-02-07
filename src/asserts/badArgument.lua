return function (evaluateSuccess, argNo, context, expectedType, receivedType)
    argNo = argNo or 1
    local appended = ")."
    if(receivedType) then 
        appended = ", got "..receivedType..")."
    end 
    assert(evaluateSuccess, "bad argument #"..argNo.." to '"..context.."' ("..expectedType.." expected"..appended)
end 