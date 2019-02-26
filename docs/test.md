## Classes

<dl>
<dt><a href="#Disposable">Disposable</a></dt>
<dd><p>Represents a disposable resource.</p>
</dd>
<dt><a href="#CompletableEmitter">CompletableEmitter</a></dt>
<dd><p>Abstraction over an RxLua <a href="CompletableObserver">CompletableObserver</a> that allows associating
a resource with it.</p>
<p>Calling <a href="#CompletableEmitter+onComplete">onComplete()</a> multiple times has no effect.
Calling <a href="#CompletableEmitter+onError">onError(Throwable)</a> multiple times or after onComplete will route the
exception into the global error handler via HostError.</p>
<p>The emitter allows the registration of a single resource, in the form of a <a href="#Disposable">Disposable</a>
via <a href="#CompletableEmitter+setDisposable">setDisposable(Disposable)</a> respectively. The emitter implementations will 
dispose/cancel this instance when the downstream cancels the flow or after the event 
generator logic calls <a href="#CompletableEmitter+onError">onError(Throwable)</a> or <a href="#CompletableEmitter+onComplete">onComplete()</a> succeeds.</p>
<p>Only one <a href="#Disposable">Disposable</a> object can be associated with the emitter at
a time. Calling <a href="setDisposable">setDisposable</a> method will dispose/cancel any previous object. If there
is a need for handling multiple resources, one can create a <a href="CompositeDisposable">CompositeDisposable</a>
and associate that with the emitter instead.</p>
</dd>
</dl>

<a name="Disposable"></a>

## Disposable
Represents a disposable resource.

**Kind**: global class  

* [Disposable](#Disposable)
    * [.isDisposed()](#Disposable+isDisposed) ⇒ <code>Boolean</code>
    * [.dispose()](#Disposable+dispose)

<a name="Disposable+isDisposed"></a>

### disposable.isDisposed() ⇒ <code>Boolean</code>
Returns true if this resource has been disposed.

**Kind**: instance method of [<code>Disposable</code>](#Disposable)  
**Returns**: <code>Boolean</code> - - true if this resource has been disposed  
<a name="Disposable+dispose"></a>

### disposable.dispose()
Dispose the resource, the operation should be idempotent.

**Kind**: instance method of [<code>Disposable</code>](#Disposable)  
<a name="CompletableEmitter"></a>

## CompletableEmitter
Abstraction over an RxLua [CompletableObserver](CompletableObserver) that allows associating
a resource with it.

Calling [onComplete()](#CompletableEmitter+onComplete) multiple times has no effect.
Calling [onError(Throwable)](#CompletableEmitter+onError) multiple times or after onComplete will route the
exception into the global error handler via HostError.

The emitter allows the registration of a single resource, in the form of a [Disposable](#Disposable)
via [setDisposable(Disposable)](#CompletableEmitter+setDisposable) respectively. The emitter implementations will 
dispose/cancel this instance when the downstream cancels the flow or after the event 
generator logic calls [onError(Throwable)](#CompletableEmitter+onError) or [onComplete()](#CompletableEmitter+onComplete) succeeds.

Only one [Disposable](#Disposable) object can be associated with the emitter at
a time. Calling [setDisposable](setDisposable) method will dispose/cancel any previous object. If there
is a need for handling multiple resources, one can create a [CompositeDisposable](CompositeDisposable)
and associate that with the emitter instead.

**Kind**: global class  

* [CompletableEmitter](#CompletableEmitter)
    * [.onComplete()](#CompletableEmitter+onComplete)
    * [.onError(t)](#CompletableEmitter+onError)
    * [.setDisposable(d)](#CompletableEmitter+setDisposable)
    * [.isDisposed()](#CompletableEmitter+isDisposed) ⇒ <code>Boolean</code>

<a name="CompletableEmitter+onComplete"></a>

### completableEmitter.onComplete()
Signal the completion.

**Kind**: instance method of [<code>CompletableEmitter</code>](#CompletableEmitter)  
<a name="CompletableEmitter+onError"></a>

### completableEmitter.onError(t)
Signal an exception.

**Kind**: instance method of [<code>CompletableEmitter</code>](#CompletableEmitter)  

| Param | Description |
| --- | --- |
| t | the exception, not null |

<a name="CompletableEmitter+setDisposable"></a>

### completableEmitter.setDisposable(d)
Sets a Disposable on this emitter; any previous [Disposable](#Disposable)
will be disposed/cancelled.

**Kind**: instance method of [<code>CompletableEmitter</code>](#CompletableEmitter)  

| Param | Description |
| --- | --- |
| d | the disposable, null is allowed |

<a name="CompletableEmitter+isDisposed"></a>

### completableEmitter.isDisposed() ⇒ <code>Boolean</code>
Returns true if the downstream disposed the sequence or the
emitter was terminated via [onError(Throwable)](#CompletableEmitter+onError) or
[onComplete()](#CompletableEmitter+onComplete)

**Kind**: instance method of [<code>CompletableEmitter</code>](#CompletableEmitter)  
**Returns**: <code>Boolean</code> - true if the downstream disposed the sequence or the emitter was terminated