create or replace function fib_f_rq(a numeric, b numeric, c numeric)
returns numeric
as $$   -- PL/pgSQL requires function body to be a quoted string,
        -- but to avoid quote confusion, allows 'double dollar' notation
begin
	return (with recursive r_fib(a,b,c) as (
	                select 1,1,40
		        union
			        select r_fib.b, r_fib.a + r_fib.b, r_fib.c-1
			        from r_fib
			        where r_fib.c > 1
		        )
	            select r_fib.a
	            from r_fib
	            where r_fib.c = 1);
end
$$ language plpgsql         -- using PL/pgSQL
returns null on null input; -- returns null if any input arguemnt is null