## Disposable
Represents a disposable resource.

**Kind**: global class  

- [Disposable](#disposable)
  - [disposable:isDisposed() ⇒ <code>Boolean</code>](#disposableisdisposed-%E2%87%92-codebooleancode)
  - [disposable:dispose()](#disposabledispose)

<a name="Disposable+isDisposed"></a>

### disposable:isDisposed() ⇒ <code>Boolean</code>
Returns true if this resource has been disposed.

**Kind**: instance method of [<code>Disposable</code>](#Disposable)  
**Returns**: <code>Boolean</code> - - true if this resource has been disposed  
<a name="Disposable+dispose"></a>

### disposable:dispose()
Dispose the resource, the operation should be idempotent.

**Kind**: instance method of [<code>Disposable</code>](#Disposable)