# @is_const_foldable

**NOTE: This package is extremely experimental, and very likely just doesn't work! This is exploratory work.**

A macro which will return true if we are *sure* that an expression const-folds, and false
otherwise. Note that there may be false negatives (because LLVM does its own optimization
passes), but there should not be false positives.

Note that it tests this by checking the @code_typed of a helper function whose body is your
expression, allowing the optimizer the chance to fold away the logic with awareness of the
context of being called with Const inputs.

You can use this within a Unit Test, to check if a function will const-fold for a given input.

## Example:

```julia
@test @is_const_foldable zero(Int)
@test @is_const_foldable zero(Rational)  # Fails
```
