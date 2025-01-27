select *from walmart;

select count(*) from walmart;

select 
	payment_method,
    count(*)
from walmart
group by payment_method;


select count(distinct Branch) from walmart;

select max(quantity) from walmart;
select min(quantity) from walmart;

-- Business Problems

-- Q.1) Find the different payment method and for each of it find number of transactions, number of qty sold

select 
	payment_method,
    count(*) as no_of_transactions,
    sum(quantity) as no_qty_sold
from walmart
group by payment_method;

-- Q.2) Identify the highest-rated category in each branch, displaying the branch, category and AVG rating

select * from
(
select 
	 branch,
	 category,
	 avg(rating) as avg_rating,
     rank() over(partition by branch order by avg(rating) desc) as rn
from walmart
group by 1, 2
) as x1
where rn = 1;


-- Q.3) Identify the busiest day for each branch based on the number of transactions

select *from
(
SELECT 
    branch,
    DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name,
    count(*) as no_transactions,
    rank() over(partition by branch order by count(*) desc) as rn
FROM walmart
group by 1, 2
order by 1, 3 desc
) as x1
where rn = 1;


-- Q.4) Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

select 
	payment_method,
    sum(quantity) as no_qty_sold
from walmart
group by payment_method;


-- Q.5) Determine the average, minimum and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

select 
	city,
    category,
    min(rating) as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart
group by 1, 2;

-- Q.6) Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). List category and total_profit, ordered from highest ot lowest profit.

select distinct(category) from walmart;

select 
	category,
	sum(unit_price * quantity * profit_margin) as total_profit
from walmart
group by category
order by 2 desc;


-- Q.7) Determine the most common payment method for each Branch. Display Branch and the preffered_payment_method.

select * from
(
select 
	Branch,
    payment_method,
    count(*) as total_trans,
    rank() over(partition by Branch order by count(*) desc) as rn
from walmart
group by 1, 2
) as x1
where rn = 1;


-- Q.8) Categotize sales into 3 group MORNING, AFTERNOON, EVENING
-- 		Find out which of the shift and number of invoices


SELECT 
	branch,
	case 
		when hour(STR_TO_DATE(time, '%H:%i:%s')) < 12 then 'Morning'
        when  hour(STR_TO_DATE(time, '%H:%i:%s')) between 12 and 17 then 'Afternoon'
        else 'Evening'
	end shift_time,
    count(*)
FROM walmart
group by 1, 2
order by 1, 3 desc;


-- Q.9) Identify 5 branch with highest decrease in the ratio of revenue compare to last year
-- 		(current year 2023 and last year 2022)
--         rdr = (last_rev - curr_rev) * 100 / last_rev;

select *,
year(STR_TO_DATE(date, '%d/%m/%y')) as formted_date
from walmart;




-- 2022 sales for each branch
with revenue_2022
as
(
	select 
		branch,
		sum(total) as revenue
	from walmart
	where year(STR_TO_DATE(date, '%d/%m/%y')) = 2022
	group by 1
),

revenue_2023 as
(
	select 
		branch,
		sum(total) as revenue
	from walmart
	where year(STR_TO_DATE(date, '%d/%m/%y')) = 2023
	group by 1
) 
select 
	ls.branch,
    ls.revenue as last_year_revenue,
    cs.revenue as curr_year_revenue,
    round((ls.revenue - cs.revenue) / ls.revenue * 100, 2) as rev_dec_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch = cs.branch
where 
	ls.revenue > cs.revenue
order by 4 desc
limit 5













