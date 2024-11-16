--adding total_cost column with addition of shipping charges and price
alter table df_Items
add total_cost DECIMAL(10, 2);

update df_Items
set total_cost=shipping_charges+price;


--adding volume column
alter table df_Products
add volume float;

update df_Products
set volume =product_length_cm*product_weight_g*product_height_cm;


--ading lead_time column
alter table df_Orders
add lead_time int;

update df_Orders
set lead_time=datediff(day,order_approved_at,order_delivered_timestamp);


--Top customers
select top 10 c.customer_id,sum(i.total_cost) as total_cost,COUNT(p.product_id) as product_count
FROM df_Customers c
JOIN df_Orders o ON c.customer_id = o.customer_id
JOIN df_Items i ON o.order_id = i.order_id
JOIN df_Products p ON i.product_id = p.product_id
GROUP BY c.customer_id
ORDER BY total_cost DESC;


--Ordered products
select top 10 p.product_id, count(o.order_id) as total_orders
from df_Products p 
join df_Items i on p.product_id=i.product_id
join df_Orders o on i.order_id=o.order_id
group by p.product_id
order by total_orders desc;


--profitable months
select format(o.order_purchase_timestamp, 'MMMM')  purchase_month, round(sum(i.price),2) as total_price
from df_Orders o 
join df_Items i on o.order_id=i.order_id
group by format(o.order_purchase_timestamp, 'MMMM')
order by total_price desc;


--Frequent seller
select seller_id,count(order_id) total_orders
from df_Items
group by seller_id
having count(order_id)>1
order by total_orders desc;


--payment methods
select payment_type,count(payment_type)  no_of_used
from df_Payments
group by payment_type;


--most installment used
select c.customer_id, count(py.payment_installments) total_installmets, max(p.product_id) product_used_in
from df_Payments py 
join df_Orders o on py.order_id=o.order_id 
join df_Customers c on o.customer_id=c.customer_id 
join df_Items i on o.order_id=i.order_id 
join df_Products p on i.product_id=p.product_id
group by c.customer_id
order by total_installmets desc;


-- products by shipping charges & weight 
select p.product_id, round(avg(i.shipping_charges),2) average_shipping_charges,avg(p.volume) average_volume
from df_Products p join df_Items i on p.product_id=i.product_id
group by p.product_id;


--month with shipping chargers
select format(o.order_purchase_timestamp,'MMMM') month_name, round(avg(i.shipping_charges),2) average_shipping_charges
from df_Orders o join df_Items i on o.order_id=i.order_id
group by format(o.order_purchase_timestamp,'MMMM');


--order status
select order_status,count(order_id) as status_count,
round(count(order_id) * 100.0 / sum(count(order_id)) OVER (),3)  status_percentage
from df_Orders
group by order_status;


--category with sales percentage
select p.product_category_name,round(sum(i.price) * 100.0 / sum(sum(i.price)) over (),5)  status_percentage
from df_Items i join df_Products p on i.product_id=p.product_id
group by p.product_category_name;


--delivery success & failure rate
select round(
(select count(order_id)*100.
from df_Orders
where lead_time>0 or lead_time=0)/count(order_id),2) success_rate,

round(
(select count(order_id)*100.0
from df_Orders
where lead_time<0 or lead_time is null)/count(order_id),2) failure_rate
from df_Orders;






select * from df_Orders;
select *from df_Products;
select *from df_Customers;
select *from df_Items;
select *from df_Payments;




