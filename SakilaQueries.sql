-- 1.1.	Contribution of Countries & Cities (in hierarchy) by rental amount
SELECT co.COUNTRY, ci.CITY,sum(pay.amount) as "Rental Amount"
FROM PAYMENT pay
INNER JOIN customer c on c.customer_id = pay.customer_id
INNER JOIN address ad on ad.address_id = c.address_id
INNER JOIN city ci on ci.city_id = ad.city_id
INNER JOIN country co ON co.country_id = ci.country_id
group by co.country, ci.city
order by ci.city;


-- 1.2.	Rental amounts by countries for PG & PG-13 rated films 
SELECT country, rating,sum(pay.amount)  as Rental_Amounts from country co
INNER JOIN city ci on co.country_id = ci.country_id
INNER JOIN address ad on ci.city_id	 = ad.city_id
INNER JOIN customer cus on ad.address_id = cus.address_id
INNER JOIN payment pay on cus.customer_id = pay.customer_id
INNER JOIN rental r ON pay.rental_id = r.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON f.film_id = i.film_id
WHERE rating in ('PG','PG-13')
group by country
order by Rental_Amounts desc;


-- 1.3 Top 20 cities by number of customers who rented 
select city, customer_count
from
(SELECT c.city, count(cus.customer_id) as customer_count, dense_rank() over(order by count(customer_id) desc) as rk
from city c
join address a on c.city_id = a.city_id -- only city and address connected
join customer cus on a.address_id = cus.address_id -- only customer and address connected 
join rental r on r.customer_id = cus.customer_id
group by c.city) as a
where a.rk <= 20


-- 1.4.	Top 20 cities by number of films rented 
select city,count(i.film_id) as TOTAL from country co
INNER JOIN city ci on co.country_id = ci.country_id
INNER JOIN address ad on ci.city_id = ad.city_id
INNER JOIN customer cus on ad.address_id= cus.address_id
INNER JOIN rental r on cus.customer_id = r.customer_id
INNER JOIN inventory i on r.inventory_id = i.inventory_id 
group by i.film_id 
order by TOTAL desc 
limit 20;	


-- 1.5 Rank cities by average rental cost 
SELECT c.city, AVG(pay.amount), dense_rank() over (order by AVG(pay.amount) desc) as rk  from payment pay
INNER JOIN rental r on pay.rental_id = r.rental_id
INNER JOIN customer cus on r.customer_id = cus.customer_id
INNER JOIN address a on cus.address_id = a.address_id
INNER JOIN city c on a.city_id = c.city_id
group by c.city;


-- 2.1.	Film categories by rental amount (ranked) & rental quantity 
SELECT cat.name, sum(pay.amount) as rental_amount, count(r.rental_id) as rental_quantity,
dense_rank() over (order by sum(pay.amount) desc) as rk
from category cat
INNER JOIN film_category fc on cat.category_id = fc.category_id
INNER JOIN film f on fc.film_id = f.film_id
INNER JOIN inventory i on f.film_id = i.film_id
INNER JOIN rental r on i.inventory_id = r.inventory_id
INNER JOIN payment pay on r.rental_id = pay.rental_id
group by cat.name
order by rental_quantity, rental_amount desc;


-- 2.2.	Film categories by rental amount (ranked)
SELECT cat.name, sum(pay.amount) as rental_amount, dense_rank() over (order by sum(pay.amount) desc) as rk
from category cat
INNER JOIN film_category fc on cat.category_id = fc.category_id
INNER JOIN film f on fc.film_id = f.film_id
INNER JOIN inventory i on f.film_id = i.film_id
INNER JOIN rental r on i.inventory_id = r.inventory_id
INNER JOIN payment pay on r.rental_id = pay.rental_id
group by cat.name
order by rental_amount desc;

-- 2.4.	Contribution of Film Categories by number of customers 
SELECT fc.category_id, count(cus.customer_id) as "Number of customers" from film_category fc
INNER JOIN film f on fc.film_id = f.film_id
INNER JOIN inventory i on f.film_id = i.film_id
INNER JOIN rental r on i.inventory_id = r.inventory_id
INNER JOIN customer cus on r.customer_id = r.customer_id
group by fc.category_id;


-- 3.4.	List Films with the word “punk” in title with rental amount and number of customers 
SELECT f.title, sum(p.amount), count(c.customer_id) from film f
INNER JOIN inventory i on f.film_id = i.film_id
INNER JOIN rental r on i.inventory_id = r.inventory_id
INNER JOIN payment p on r.customer_id = p.customer_id
INNER JOIN customer c on p.customer_id = c.customer_id
where f.title like '%punk%'
group by f.title;


-- 4.1 List Customers (Last name, First Name) with rental amount, rental quantity, active status, country and city
SELECT concat(cus.last_name, " " , cus.first_name) as Customer_name, sum(pay.amount) as rental_amount, count(r.rental_id) as rental_quantity, cus.active, co.country, ci.city from customer cus
INNER JOIN payment pay on cus.customer_id = pay.customer_id
INNER JOIN rental r on pay.rental_id = r.rental_id
INNER JOIN customer c on r.customer_id = c.customer_id
INNER JOIN address ad on c.address_id = ad.address_id
INNER JOIN city ci on ad.city_id = ci.city_id
INNER JOIN country co on ci.country_id = co.country_id
where cus.active = ‘active’
group by cus.active,co.country_id, ci.city_id
order by Customer_name, rental_amount, rental_quantity;


-- 4.3.	Contribution by rental amount for customers from France, Italy or Germany
SELECT sum(pay.amount) as Rental_amount, concat(cus.last_name," ",cus.first_name) as Customer, Country from payment pay
INNER JOIN customer cus on pay.customer_id = cus.customer_id
INNER JOIN address ad on cus.address_id = ad.address_id
INNER JOIN city ci on ad.city_id = ci.city_id
INNER JOIN country co on ci.country_id = co.country_id
WHERE Country IN ('France','Italy','Germany')
GROUP by country;
