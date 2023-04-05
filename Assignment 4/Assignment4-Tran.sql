

use sales;
-- 1. Project the number of items sold and total revenue for Sales Rep and Each item.
select concat(salesrep.FirstName, ' ', salesrep.LastName) as SalesRep, item.ItemName, sum(ledger.quantity) as Total, sum(ledger.quantity * item.ItemCost) as Revenue
from ledger 
inner join salesrep on salesrep.idrep = ledger.idrep
inner join item on item.iditem = ledger.iditem
group by SalesRep, item.ItemName;

-- 2. Project the Total Number of items sold for each sales rep by item
-- with the highest revenue as the beginning record and the lowest as the last record.
select concat(salesrep.FirstName, ' ', salesrep.LastName) as SalesRep, item.ItemName, sum(ledger.quantity) as Total, sum(ledger.quantity * item.ItemCost) as Revenue
from ledger 
join salesrep on ledger.idrep = salesrep.idrep
join item on ledger.iditem = item.iditem
group by salesrep.idrep, item.iditem, salesrep.FirstName, salesrep.LastName, item.ItemName
order by salesrep.idrep, Revenue desc;


-- 3. Project the Total Sales for each region with the Highest sales and quantity sold as the first record and lowest at the bottom. 
select region.region_name as Region, item.ItemName, sum(ledger.quantity) as Quantity, sum(ledger.quantity * item.ItemCost) as TotalSales
from ledger 
join salesrep on ledger.idrep = salesrep.idrep
join item on ledger.iditem = item.iditem
join repregion on salesrep.idrep = repregion.idrep
join region on region.idregion = region.idregion
group by Region, item.ItemName
order by TotalSales desc;


-- 4. Get the Total number of sales and items sold by each rep for each month ordering by Year, month, and from Greatest Revenue to lowest Revenue.
select year(ledger.purchase_date) as SYear, monthname(ledger.purchase_date) as SMonth, concat(salesrep.FirstName, ' ', salesrep.LastName) as Rep, sum(ledger.quantity) as Total, sum(ledger.quantity * item.ItemCost) as Revenue
from ledger 
inner join salesrep on salesrep.idrep = ledger.idrep
left join item on item.iditem = ledger.iditem
group by SYear, SMonth, Rep
order by SYear desc, SMonth desc, Revenue desc;

create view vwRepSales as
select 
	year(ledger.purchase_date) as Syear,
	month(ledger.purchase_date) as SMonth,
    ledger.purchase_date,
    salesrep.idrep AS Idrep,
    concat(salesrep.FirstName, ' ', salesrep.LastName) as Rep,
    item.ItemName,
    sum(ledger.quantity) as Total,
    sum(ledger.quantity * item.ItemCost) as Revenue
from ledger 
    join salesrep on ledger.idrep = salesrep.idrep
    join item on ledger.iditem = item.iditem
group by Syear, SMonth, ledger.purchase_date, salesrep.idrep, item.ItemName
order by ledger.purchase_date;

select * from vwRepSales;


-- 1. Get All the sales by month between January 1, 2019 and May 30th, 2019 ordered by the month name. 
-- Project only the month name and the total Revenue for each month.
select date_format(ledger.purchase_date, '%M') as MonthName, sum(ledger.quantity * item.ItemCost) as Revenue
from ledger
join item on ledger.iditem = item.iditem
where ledger.purchase_date between '2019-01-01' and '2019-05-30'
group by MonthName
order by Revenue desc;

-- 2.Get All the sales by month and user between January 1, 2019 and May 30th, 2019 order by Month, then Total Revenue Descending. 
-- Project only the Month name, Rep, and total revenue.
select date_format(ledger.purchase_date, '%M') as MonthName, concat(salesrep.FirstName, ' ', salesrep.LastName) as Rep, sum(ledger.quantity * item.ItemCost) as Revenue
from ledger
join salesrep on ledger.idrep = salesrep.idrep
join item on item.iditem = ledger.iditem
where ledger.purchase_date between '2019-01-01' and '2019-05-30'
group by MonthName, Rep
order by MonthName, Revenue desc;

-- 3. Get All the sales by month and user between May 1st, 2019 and December 31st,
-- 2019 order by Sales Rep ascending then Month descending.
select  concat(salesrep.FirstName, ' ', salesrep.LastName) as Rep, date_format(ledger.purchase_date, '%M') as MonthName, sum(ledger.quantity * item.ItemCost) as Revenue
from ledger 
join salesrep on ledger.idrep = salesrep.idrep 
join item on ledger.iditem = item.iditem
where ledger.purchase_date between '2019-05-01' and '2019-12-31'
group by Rep, MonthName
order by Rep, MonthName desc;

-- Create a stored procedure
delimiter $$
create definer=`root`@`localhost` procedure `RepSales` (in Repid int, in Startdate date, in EndDate date)
begin
	if Repid is null then
        -- SELECT Month(purchase_date) AS Month_Name,
        select date_format(purchase_date, '%M') as Month_Name,
			concat(LastName, ' ', FirstName) as Rep_Name,
			sum(quantity * ItemCost) as Revenue,
			sum(quantity * ItemCost) * 0.15 as Bonus
		from ledger, item, salesrep
		where salesrep.idrep = ledger.idrep
			and ledger.purchase_date between Startdate and EndDate
			and item.iditem = ledger.iditem
		
        group by salesrep.idrep, date_format(purchase_date, '%M');
    else
        -- select month(purchase_date) Month_Name,
        select date_format(purchase_date, '%M') Month_Name,
			CONCAT(LastName, ' ', FirstName) AS Rep_Name,
            -- GET SUM OF REVENUE PER MONTH
			SUM(quantity*ItemCost) AS Revenue,
            -- GET SUM OF BONUS PER MONTH
			SUM(quantity*ItemCost) * 0.15 AS Bonus
		from ledger, item, salesrep
        where salesrep.idrep = ledger.idrep
			and ledger.purchase_date between Startdate and EndDate
            and item.iditem = ledger.iditem
            and salesrep.idrep = Repid
		-- GROUP BY Month(purchase_date);
		group by date_format(purchase_date, '%M');
        
	end if;
end$$


call `sales`.`RepSales`(null, '2019-01-01', '2019-03-31')
-- call `sales`.`RepSales`(1, '2019-1-1', '2019-3-31')