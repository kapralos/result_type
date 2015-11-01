import typetraits

type
    ResultType {.pure.} = enum Failure, Success
    Result*[T, E] = object
        case kind: ResultType
        of ResultType.Success: val: T
        of ResultType.Failure: err: E

converter toBool*[T, E](self: Result[T, E]): bool =
    self.kind == ResultType.Success

proc ResultSuccess*[T, E](value: T): Result[T, E] =
    result.kind = ResultType.Success
    result.val = value
    when compiles(value != nil):
        if value == nil: raise newException(ValueError, "Value cannot be nil")

proc ResultFailure*[T, E](error: E): Result[T, E] =
    result.kind = ResultType.Failure
    result.err = error
    when compiles(error != nil):
        if error == nil: raise newException(ValueError, "Error cannot be nil")

proc value*[T, E](self: Result[T, E]): T =
    if self: return self.val
    else: raise newException(FieldError, "Cannot fetch a value from error")

proc value*[T, E](self: Result[T, E], default: T): T =
    if self: return self.val
    else: return default

proc error*[T, E](self: Result[T, E]): E =
    if not self: return self.err
    else: raise newException(FieldError, "Cannot fetch an error from value")

proc map*[T, E, R](self: Result[T, E], oper: proc (param: T): R): Result[R, E] =
    if self: return ResultSuccess[R, E](oper(self.val))
    else: return ResultFailure[R, E](self.err)

proc `==`*[T, E](res1, res2: Result[T, E]): bool =
    (res1 and res2 and res1.val == res2.val) or
        (not res1 and not res2 and res1.err == res2.err)

proc `$`*[T, E](self: Result[T, E]): string =
    if self: return "Success(" & $self.value & ")"
    else: return "Failure(" & $self.error & ")"

    

when isMainModule:
    import strutils

    proc tests() =
        block testToBool:
            var res: Result[float, int]
            res.kind = ResultType.Success
            res.val = 5.0
            assert res

            var res2: Result[float, int]
            res2.kind = ResultType.Failure
            res2.err = 1
            assert(not res2)

        block testSuccess:
            let res = ResultSuccess[float, int](10.0)
            assert res

            try:
                let res2 = ResultSuccess[string, int](nil)
                assert false
            except ValueError:
                assert true
            except:
                assert false

        block testFailure:
            let res = ResultFailure[float, int](4)
            assert(not res)

            try:
                let res2 = ResultFailure[float, string](nil)
                assert false
            except ValueError:
                assert true
            except:
                assert false
        
        block testGetValue:
            let res = ResultSuccess[int, int](3)
            assert(res.value == 3)

            let res2 = ResultFailure[int, int](5)
            assert(res2.value(2) == 2)

            try:
                let res3 = ResultFailure[int, int](5)
                let val = res3.value
                assert false
            except FieldError:
                assert true
            except:
                assert false

        block testGetError:
            let res = ResultFailure[int, int](5)
            assert(res.error == 5)

            try:
                let res2 = ResultSuccess[int, int](1)
                let err = res2.error
                assert false
            except FieldError:
                assert true
            except:
                assert false

        block testMap:
            let res = ResultSuccess[string, int]("17")
            let parsed = res.map(parseInt)
            assert(parsed.value == 17)

            let res2 = ResultFailure[string, int](4)
            let parsed2 = res2.map(parseInt)
            assert(parsed2.error == 4)

        block testEqual:
            let res1 = ResultSuccess[int, int](5)
            let res2 = ResultSuccess[int, int](5)
            assert(res1 == res2)

            let res3 = ResultFailure[int, int](5)
            let res4 = ResultFailure[int, int](5)
            assert(res3 == res4)

            assert(res1 != res3)

        block testToString:
            let res = ResultSuccess[string, string]("success")
            assert($res == "Success(success)")

            let res2 = ResultFailure[string, string]("failure")
            assert($res2 == "Failure(failure)")

    tests()
