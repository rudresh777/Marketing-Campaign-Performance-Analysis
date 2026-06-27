use PortfolioProject_MarketingAnalytics ;

select * from products

--query for categorize produt base on price

select ProductID
,ProductName,
price ,
case 
    when price < 50 then 'Low'
    when price between 50 and 200 then 'Medium'
    else 'High'
end as pricecategories
from products

-- sql query to join dim customer with dim geography to enrich customer data with geographical information


select c.CustomerID,
c.customerName,
c.Email,
c.gender,
c.age,
case
when age < 25 then 'tenager'
when age < 50 then 'adult'
else 'seniour' 
end ageGroup,
g.Country,
g.City  from customers c
left join 
geography g
on c.GeographyID = g.GeographyID

select min(age) from customers


-- query to clean witespace issues in the reviewtext column

select ReviewID,
CustomerID,
Productid ,
ReviewDate,
Rating,
replace(ReviewText,'  ',' ') as ReviewText
from customer_reviews

select 
EngagementID,
ContentID,
CampaignID,
ProductID,
upper(replace(contentType,'Socialmedia','Social Media'))as ContentType,
format(convert(date,EngagementDate),'dd.mm.yyyy') as EngagementDate,
Likes,
left(viewsclickscombined,charindex('-',viewsclickscombined)-1) as Viewss ,
RIGHT(ViewsClicksCombined,len(ViewsClicksCombined) - CHARINDEX('-' ,ViewsClicksCombined))as likes
from engagement_data
where ContentType != 'Newsletter'




--find where the table has duplicate
select CustomerID,ProductID, count(*) from customer_journey
group by customerid , productid 
having count(*) > 1

--common table expression(cte) to identify and tag duplicate records
 with dupicaterecords as(
 select 
 CustomerID,
 ProductID,
 VisitDate,
 Stage,
 Action,
 duration,
 ROW_NUMBER() over(partition by customerid ,productid,visitdate,stage,action
 order by journeyid) as row_num
 from customer_journey
 )
 select * from dupicaterecords
 where row_num>1

 --outer query select the clean and final standardized data 

 select 
 JourneyID,
 CustomerID,
 ProductID,
 VisitDate,
 Stage,
 Action,
 coalesce(Duration,avg_duration)as Duration
 from 
 (
 select JourneyID,
 CustomerID,
 ProductID,
 VisitDate,
 UPPER(stage)as Stage,
 Action,
 Duration,
 AVG(duration) over(partition by visitdate)as avg_duration,
ROW_NUMBER() over(partition by customerid,productid,visitdate,upper(stage),action order by journeyid)as row_number
 from
 customer_journey
 )as sub_query

 where row_number = 1

