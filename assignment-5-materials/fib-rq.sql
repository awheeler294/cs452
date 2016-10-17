with recursive fib_rq(a,b,c) as (
        select 1,1,40
    union
        select b, a+b, c-1
        from r_fib
        where c > 1
    )
select a
from r_fib
where c = 1;
