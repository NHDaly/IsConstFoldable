using Test
using IsConstFoldable

# Simple functions with constant arguments should definitely fold away!
@testset "simple functions const args should fold" begin
    @test @is_const_foldable 5+5
    @test @is_const_foldable zero(Int)
end

# An operation that has non-const arguments cannot fold away.
@testset "nonconst args shouldn't fold" begin
    # Global args aren't const
    global x,y = 3,2
    @test !@is_const_foldable x+y
end

@testset "called from inside functions" begin
    # Can be called from inside functions (typically via an @assert)
    foo(x) = @is_const_foldable typemax(x)
    @test foo(x)

    # Operations on runtime argument will not const-fold.
    foo(x) = @is_const_foldable x+1
    @test !foo(x)
end

@testset "empty functions" begin
    function empty_f() end
    @test @is_const_foldable empty_f()
end

# Whether g() will const-fold depends entirely on the function's body.
@generated function g(x)
    if x <: Int
        # Will const-fold
        return :(typemax(x))
    else
        # Won't const-fold (because relies on runtime values)
        return :(x+x)
    end
end

@testset "@generated functions" begin
    @assert g(0) == typemax(Int)
    @assert g(1.0) == 2.0

    # Use a runtime-argument to prevent const-folding of complex expressions.
    f(x) = @is_const_foldable g(x)
    # The foldable case
    @test f(0)
    # The non-foldable case
    @test !f(1.0)
end
