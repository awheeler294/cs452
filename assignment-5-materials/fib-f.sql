create or replace function fib_f(a numeric, b numeric, c numeric)
returns numeric
as $$   -- PL/pgSQL requires function body to be a quoted string,
        -- but to avoid quote confusion, allows 'double dollar' notation
begin
        if c < 1 then return 0;
        elsif c = 1 then return a;
        elsif c = 2 then return b;
        else return f_fib(b, a+b, c-1);
        end if;
end
$$ language plpgsql         -- using PL/pgSQL
returns null on null input; -- returns null if any input arguemnt is null