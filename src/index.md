---
sql:
  pricepaid: data/ppd-processed.parquet
---

# HM Registry Price Paid

```sql id = [{latest}]
select max(TransferDate) as latest from pricepaid limit 1;
```
Prices paid for property in the UK updated by ${new Date(latest).toLocaleDateString("en-GB") }.

```sql id = timeline
select 
    first(TransferDate)::Date as first_day,
    month(TransferDate) as month, 
    year(TransferDate) as year, 
    count(*) as num_transactions
from pricepaid
where TransferDate >= '2010-01-01'
group by year, month
order by year, month;
```


```js
Plot.plot({
    title: "Number of transactions each month",
    x : {label : "Tranfer Date", transform : (x) => new Date(x)},
    y : {label : "Number of Transactions", grid: true},
    marginLeft: 50, 
    marks: [
        Plot.ruleY([0]),
        Plot.lineY(timeline, 
        {x: "first_day", y: "num_transactions", stroke: "#f5401e", tip: true}),
    ]
})
```

<!-- Generate list of counties and order based on number of transactions -->
```js 
const counties = await sql`select County from (select County, count(*) from pricepaid group by County order by count(*) desc);`;

function toSentenceCase(s) {
    return s.split(' ').map(w => w[0].toUpperCase() + w.slice(1).toLowerCase()).join(' ');
}

const countySelected = view(
    Inputs.select(
        Array.from(counties).map(c => c.County), 
    {label: "County", 
    value: 'GREATER LONDON', 
    format: c => toSentenceCase(c)}));
```

```sql id = median_price
select 
    first(TransferDate)::Date as first_day,
    year(TransferDate) as year,
    PropertyType,
    median(Price) as median_price
from pricepaid
where PropertyType <> 'Other' and County = ${countySelected}
group by PropertyType, year
order by year;
```

```js 
Plot.plot({
    title: "Median price by property type per year",
    color: {legend: true},
    x : {label : "Tranfer Date", transform : (x) => new Date(x)},
    y : {label : "Median Price ('000s £)", grid: true, tickFormat: x => x / 1000},
    marginLeft: 50, 
    marks: [
        Plot.ruleY([0]),
        Plot.lineY(median_price, {x: "first_day", y: "median_price", 
        stroke: "PropertyType", tip:true}),
        ]
})
```
