module IsConstFoldable

using InteractiveUtils
using Rematch

export @is_const_foldable

"""
    @is_const_foldable foo(1, 2)

A macro which will return true if we are *sure* that an expression const-folds, and false
otherwise. Note that there may be false negatives (because LLVM does its own optimization
passes), but there should not be false positives.

Note that it tests this by checking the @code_typed of a helper function whose body is your
expression, allowing the optimizer the chance to fold away the logic with awareness of the
context of being called with Const inputs.

You can use this within a Unit Test, e.g.:

```julia
@test @is_const_foldable zero(Int)
@test @is_const_foldable zero(Rational)  # Fails
```
"""
macro is_const_foldable(expr)
    return quote
        # We embed the expr in a wrapper() function, which ensures that during compliation
        # and optimization, the optimizer has access to all static constants provided.
        function wrapper() $(esc(expr)) end
        function _test_wrapper()
            # If the code in wrapper() is reduced to only a single return statement, then
            # the logic in `expr` has been const-folded away.
            # This single return statment would be something like this: `:(return 0)`
            codeinfo = ($InteractiveUtils.@code_typed wrapper())[1]
            if length(codeinfo.code) == 1
                # Ensure that the statement is a return line of some kind
                # (This also works for empty functions)
                codeinfo.code[end].head == :return && return true
            end
            # Otherwise, the optimizer was not able to eliminate the entirety of the operation.
            return false
        end
        _test_wrapper()
    end
end

end
