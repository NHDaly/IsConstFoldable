using Tests
using IsConstFoldable

# Tests that the Util.@is_const_foldable macro actually works
@testset "@is_const_foldable" begin
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

        # A runtime argument is not const.
        foo(x) = @is_const_foldable x+1
        @test !foo(x)
    end
end
