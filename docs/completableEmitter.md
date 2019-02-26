## CompletableEmitter
Abstraction over an RxLua [CompletableObserver](CompletableObserver) that allows associating
a resource with it.

Calling [#onComplete()](#onComplete()) multiple times has no effect.
Calling [#onError(Throwable)](#onError(Throwable)) multiple times or after {@code onComplete} will route the
exception into the global error handler via [io.reactivex.plugins.RxJavaPlugins#onError(Throwable)](io.reactivex.plugins.RxJavaPlugins#onError(Throwable)).

The emitter allows the registration of a single resource, in the form of a [Disposable](Disposable)
via [#setDisposable(Disposable)](#setDisposable(Disposable)) respectively. The emitter implementations will 
dispose/cancel this instance when the downstream cancels the flow or after the event 
generator logic calls [#onError(Throwable)](#onError(Throwable)) or [#onComplete()](#onComplete()) succeeds.

Only one {@code Disposable} object can be associated with the emitter at
a time. Calling either {@code set} method will dispose/cancel any previous object. If there
is a need for handling multiple resources, one can create a [CompositeDisposable](CompositeDisposable)
and associate that with the emitter instead.

**Kind**: global class  

- [CompletableEmitter](#completableemitter)
  - [completableEmitter.onComplete()](#completableemitteroncomplete)
  - [completableEmitter.onError(t)](#completableemitteronerrort)
  - [completableEmitter.setDisposable(d)](#completableemittersetdisposabled)
  - [completableEmitter.isDisposed() ⇒ <code>Boolean</code>](#completableemitterisdisposed-%E2%87%92-codebooleancode)

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
Sets a Disposable on this emitter; any previous [Disposable](Disposable)
will be disposed/cancelled.

**Kind**: instance method of [<code>CompletableEmitter</code>](#CompletableEmitter)  

| Param | Description |
| --- | --- |
| d | the disposable, null is allowed |

<a name="CompletableEmitter+isDisposed"></a>

### completableEmitter.isDisposed() ⇒ <code>Boolean</code>
Returns true if the downstream disposed the sequence or the
emitter was terminated via [#onError(Throwable)](#onError(Throwable)) or
[#onComplete](#onComplete)

**Kind**: instance method of [<code>CompletableEmitter</code>](#CompletableEmitter)  
**Returns**: <code>Boolean</code> - true if the downstream disposed the sequence or the emitter was terminated