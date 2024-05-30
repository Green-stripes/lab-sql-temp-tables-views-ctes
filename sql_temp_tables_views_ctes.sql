-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's 
-- ID, name, email address, and total number of rentals (rental_count).

use sakila;
create view rental_info as 
select customer.customer_id, customer.first_name, customer.last_name, customer.email, count(rental.inventory_id) as number_of_rentals from customer
inner join rental
using (customer_id)
group by customer_id
;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and 
-- calculate the total amount paid by each customer.
create temporary table tt_cust_rental_payment_info3 as
select customer.customer_id, customer.first_name, customer.last_name, customer.email, count(rental.inventory_id) as number_of_rentals , sum(payment.amount) as total_paid from customer
inner join rental
	using (customer_id)
inner join payment
	using (rental_id)
group by customer_id
order by total_paid desc
;

select * from tt_cust_rental_payment_info3;

-- Step 3: Create a CTE and the Customer Summary Report
-- The CTE should include the customer's name, email address, rental count, and total amount paid.


with total_paid as 
(select customer_id, sum(amount) as total from payment 
group by customer_id),

rental_nos as
(select customer_id, count(rental_id) as rentals from rental
group by customer_id),

cust_info as 
(select customer.first_name, customer.last_name, customer.email, customer_id from customer)

select *from total_paid
inner join rental_nos
using (customer_id)
inner join cust_info
using (customer_id)
;

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: 
-- customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived 
-- column from total_paid and rental_count.

with total_paid as 
(select customer_id, sum(amount) as total from payment 
group by customer_id),

rental_nos as
(select customer_id, count(rental_id) as rentals from rental
group by customer_id),

cust_info as 
(select customer.first_name, customer.last_name, customer.email, customer_id from customer),

average_payment as
(
select total_paid.customer_id, (total/rentals) as average from total_paid
inner join rental_nos
using (customer_id)
group by customer_id
)

select * from total_paid
inner join rental_nos
using (customer_id)
inner join cust_info
using (customer_id)
inner join average_payment
using (customer_id)
;
