# result_type

## What is result_type
A simple and easy-to-use library for Result[Type, Error] in Nim language.

## Usage
### Construction
- `let res = ResultSuccess[float, string](5.0)` creates a `Result[float, string]` with float value `5.0`
- `let res = ResultFailure[int, string]("some error")` creates a `Result[int, string]` with string error `"some error"`
- `var res: Result[int, string]` creates a `Result[int, string]` with `nil` string error.
- Providing `nil` value or error (like `ResultSuccess[string, string](nil)` or `ResultFailure[string, string](nil)`) is not allowed and will raise `ValueError` exception

### Operations
- `res.value` returns stored value. If `res` actually contains an error, `FieldError` exception will be raised
- `res.value(defaultValue)` does not raise an exception when `res` is an error, but returns provided `defaultValue` instead
- `res.error` returns stored error. If `res` actually contains a value, `FieldError` exception will be raised
- `res.map(someProcToMap)`: if `res` is not an error, the provided `proc someProcToMap(param: Type): NewType` will be executed with `res.value` as a parameter and returns `Result[NewType, Error]`; otherwise, it will return `Result[NewType, Error]` containing `res.error`
- `==` returns `true` if both results contain equal values or equal errors and `false` otherwise
- `$` returns `"Success(" & $res.value & ")"` or `"Failure(" & $res.error & ")"`

`Result[Type, Error]` also supports convertion to `bool`.

### Typical scenario
```
let myRes = someProcWhichReturnsResult(param)
if myRes:
    handleValue(myRes.value)
else:
    handleError(myRes.error)
```

##Tests
Library comes along with very basic and simple tests, which are executed when `result` is the main module.
