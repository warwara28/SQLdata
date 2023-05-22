USE Healthcare_DB
 	/*Skills used: 
	-Basic Syntax (where,group by,having, order by)
	-Aggregate Functions (sum,count,avg,max/min)
	-Joins
	-Temp Tables 
	*/

	/*Showing how many rows of data that include 
	a Gross Charge greater than $100?
	*/

	Select count(GrossCharge)
	from dbo.facttable
	where grosscharge > '100'
	

	/*Showing how many unique patients exist is our database
	*/
	
	Select count(distinct PatientNumber)
	from dbo.dimPatient

	/*Showing how many CptCodes are in each CptGrouping
	*/

	select count(distinct cptcode) as countofCPTcode, CptGrouping
	from dbo.dimCptCode
	group by CptGrouping
	order by 1 
	

	/*Showing how many physicians have submitted a Medicare insurance claim
	*/

	Select count(distinct dimPhysicianPK) as Countofphysicians, PayerName
	from dbo.FactTable
	inner join dbo.dimPayer
	on dbo.facttable.dimPayerPK = dbo.dimpayer.dimPayerPK
	group by PayerName

	/*Showing how to calculate the gross collection rate for each location given
	*/
	
	select format(-sum(payment)/sum(grosscharge),'P1')as GCR, locationname
	from dbo.FactTable 
	inner join dbo.dimLocation
	on dbo.facttable.dimLocationPK =dbo.dimLocation.dimLocationPK
	group by LocationName
	order by 1
	
	
	/*
	Showing how to find how many CptCodes have more than 100 units
	*/

	select cptcode,cptdesc,sum(CPTUnits)
	from dbo.FactTable
	Inner join dbo.dimCptCode
	on dbo.facttable.dimcptcodepk=dbo.dimcptcode.dimCPTCodePK
	group by cptcode,cptdesc
	having sum(CPTunits) > '100'
	
	

	/*
	Showing how to find  physician specialty that has received the highest
	amount of payments 
	*/

	select -sum(payment) as 'Payments',ProviderSpecialty
	from FactTable
	inner join dimPhysician
	on FactTable.dimPhysicianPK=dimPhysician.dimPhysicianPK
	group by ProviderSpecialty
	order by 1 desc

	/*
	Showing the payments by month for specific group of physicians
	*/

	select 
	dimDate.MonthYear,
	format(-sum(payment),'$#,###') as 'Payments'
	from FactTable
	inner join .dimPhysician
	on FactTable.dimPhysicianPK=dimPhysician.dimPhysicianPK
	inner join dimDate
	on dimDate.dimDatePostPK=FactTable.dimDatePostPK
	where ProviderSpecialty ='Internal Medicine'
	group by dimdate.MonthYear
	order by 1 


	/*
   Showing how many CptUnits by DiagnosisCodeGroup are assigned to 
	a "J code" Diagnosis 
	*/

select sum(CPTUnits) as 'CptUnits', DiagnosisCodeGroup
from FactTable
inner join dimDiagnosisCode
on facttable.dimDiagnosisCodePK=dimDiagnosisCode.dimDiagnosisCodePK
where dimDiagnosisCode.DiagnosisCode like 'J%'
group by DiagnosisCodeGroup
order by 1

	/*
	Create report that details patient demographics. The report should group patients
	into three buckets- Under 18, between 18-65, & over 65
	Please include the following columns:
		-First and Last name in the same column
		-Email
		-Patient Age
		-City and State in the same column
	*/

	select 
	concat(FirstName, ' ', LastName),
	Email,
	PatientAge,
	case when PatientAge <18 then 'Under 18'
	when PatientAge between '18' and '65' then '18-65'
	when PatientAge > 65 then 'Over 65'
	Else null End as 'PatientAgeBucket',
	CONCAT(City,',',State)
	From dimPatient


	/*Build a Table that includes 
	    - LocationName
		- CountofPhysicians
		- CountofPatients
		- GrossCharge
		- AverageChargeperPatients 
	*/

select LocationName,
count(Distinct ProviderNpi) as 'CountofPhysicians',
count(Distinct dimPatient.PatientNumber) as 'CountofPatients',
sum(GrossCharge)as 'Charges',
sum(GrossCharge)/sum(Distinct dimPatient.PatientNumber) as 'AverageChargeperPatient'
from FactTable
inner join dimPhysician
on facttable.dimPhysicianPK=dimPhysician.dimPhysicianPK
inner join dimLocation
on FactTable.dimLocationPK=dimLocation.dimlocationPK
inner join dimPatient
on FactTable.dimPatientPK=dimPatient.dimPatientPK
group by LocationName

 /*Creating Temp Tables
 */

 select sum(CPTUnits) as 'CptUnits', DiagnosisCodeGroup
Into #TestTable
from FactTable
inner join dimDiagnosisCode
on facttable.dimDiagnosisCodePK=dimDiagnosisCode.dimDiagnosisCodePK
where dimDiagnosisCode.DiagnosisCode like 'J%'
group by DiagnosisCodeGroup
order by 1
 
 Select * 
 From #TestTable