create or replace function fib_f_loop(a numeric, b numeric, c numeric)
returns numeric
as $$
declare
        tmp numeric;
begin
	if c < 1 then return null;
	elsif c = 1 then return a;
	elsif c = 2 then return b;
	end if;
	
	loop
		tmp := a;
		a := b;
		b := tmp + b;
		c := c - 1;
		exit when c = 1;
	end loop;

	return a;
end;
$$ language plpgsql         -- using PL/pgSQL
returns null on null input; -- returns null if any input arguemnt is null