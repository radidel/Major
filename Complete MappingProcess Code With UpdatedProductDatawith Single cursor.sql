drop table tempHubDumpData

select * into tempHubDumpData from HubMapperSummary
where ICTitle=''

select*from HubMapperSummary

delete from HubMapperSummary
where ICTitle=''

declare  @Hubtitle nvarchar(500),@HubSlugTitle nvarchar(500),@HubSlugtitle1 nvarchar(500),@HubSlugNumber nvarchar(500),@HubMRP decimal(18,2),
@Keywords nvarchar(500), @Keywords1 nvarchar(500), @Keywords2 nvarchar(500),@ICKeywords nvarchar(500),@ICKeywords2 nvarchar(500),@HubCount int,
@Ictitle2 nvarchar(500),@Hubtitle2 nvarchar(500),@HubSlugTitle2 nvarchar(500),@HubSlugTitle23 nvarchar(500),@ICMRP2 decimal(18,2),@HubMRP2 decimal(18,2),@NumberOfMatching int,
 @Keywords3 nvarchar(500),@Keywords4 nvarchar(500),@Keywords5 nvarchar(500),@HubSlugTitle3 nvarchar(500),@HubSlugTitle4 nvarchar(500),@HubSlugTitle5 nvarchar(500),
 @HubCount1 int,@HubCount2 int,@HubCount3 int, @HubCount4 int,@HubCount5 int, @ICTitle Nvarchar(500), @HubId nvarchar(500)

 begin

	DECLARE curHubClosingStockDump1 CURSOR FOR ( 
											select HubId, HubTitle, case when PATINDEX('% %',dbo.[RemoveSpecialCharacters](HubTitle))>0 
				then 
				LEFT(dbo.[RemoveSpecialCharacters](HubTitle),(PATINDEX('% %',dbo.[RemoveSpecialCharacters](HubTitle))))
				else
				dbo.[RemoveSpecialCharacters](HubTitle)
				end as title,
		
	case when len(db_owner.GetStringPartByDelimeter(dbo.[RemoveSpecialCharacters](HubTitle), ' ', 2))>0 then db_owner.GetStringPartByDelimeter(dbo.[RemoveSpecialCharacters](HubTitle), ' ', 2) else db_owner.GetStringPartByDelimeter(dbo.[RemoveSpecialCharacters](HubTitle), ' ', 3) end as Title1,

		case when len(db_owner.GetStringPartByDelimeter(dbo.[RemoveSpecialCharacters](HubTitle), ' ', 3))>0 then db_owner.GetStringPartByDelimeter(dbo.[RemoveSpecialCharacters](HubTitle), ' ', 3) else db_owner.GetStringPartByDelimeter(dbo.[RemoveSpecialCharacters](HubTitle), ' ', 4) end AS title3,

		case when len(db_owner.GetStringPartByDelimeter(dbo.[RemoveSpecialCharacters](HubTitle), ' ', 4))>0 then db_owner.GetStringPartByDelimeter(dbo.[RemoveSpecialCharacters](HubTitle), ' ', 4) else db_owner.GetStringPartByDelimeter(dbo.[RemoveSpecialCharacters](HubTitle), ' ', 5) end as title4,

      Left(SubString(HubTitle, PatIndex('%[0-9.-]%', HubTitle), 50),PatIndex('%[^0-9.-]%', SubString(HubTitle, PatIndex('%[0-9.-]%', HubTitle), 50) + 'X')-1) as title5,
	  HubMRP as MRP 
			from tempHubDumpData
		
		)
		OPEN curHubClosingStockDump1 
	fetch next from curHubClosingStockDump1 into  @HubId,@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,@HubMRP
	
	while (@@fetch_status=0)	
								
							begin
								SET @Keywords1 = '"*'+dbo.RemoveNonAlphaCharacters(@HubSlugTitle1)+'*"'
								SET @Keywords2= '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle2)+'*"'
								SET @Keywords3= '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle3)+'*"'
								SET @Keywords4= '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle4)+'*"'
								SET @Keywords5= '"*'+dbo.RemoveSpecialCharacters(replace((@HubSlugTitle5),' ',''))+'*"'
			
			if len(@HubSlugTitle1)<50 

			

								begin
								select @HubCount=count(*) from Product where freetext(Title,@HubSlugTitle1)  and Title like '%'+@HubSlugTitle2+'%' and (Title like '%'+@HubSlugTitle3+'%' or Title like '%'+@HubSlugTitle4+'%')
								and dbo.RemoveSpecialCharacters(@HubSlugTitle2)<>''
			if @HubCount>0
			
								begin
									INSERT INTO HubMapperSummary
									(HubId,ICID,ICTitle,HubTitle,ICMRP,HubMRP,ICStrength,ICPack,MatchCount,[Status])
									select @HubId,Product.Id,Product.Title,@HubTitle,MRP,@HubMRP,MasterStrength.title,MasterPack.Title,@HubCount1,1 from Product
									left join MasterPack on Product.MasterPackId=MasterPack.Id
									left join MasterStrength on product.MasterStrengthID=MasterStrength.Id
									where freetext(Product.Title,@HubSlugTitle1)  and Product.Title like '%'+@HubSlugTitle2+'%' and (Product.Title like '%'+@HubSlugTitle3+'%' or Product.Title like '%'+@HubSlugTitle4+'%')
								end
						else
								select @HubCount1=count(*) from Product where freetext(Product.Title,@HubSlugTitle1)  and Product.Title like '%'+@HubSlugTitle2+'%' and Product.Title like '%'+@HubSlugTitle5+'%' and @HubSlugTitle5<>''
			if @HubCount1>0
								begin
										INSERT INTO HubMapperSummary
										(HubId,ICID,ICTitle,HubTitle,ICMRP,HubMRP,ICStrength,ICPack,MatchCount,[Status])
										select @HubId,Product.Id,Product.Title,@HubTitle,MRP,@HubMRP,MasterStrength.title,MasterPack.Title,@HubCount1,1  from Product 
										left join MasterPack on Product.MasterPackId=MasterPack.Id
									    left join MasterStrength on product.MasterStrengthID=MasterStrength.Id
										where freetext(Product.Title,@HubSlugTitle1)  and Product.Title like '%'+@HubSlugTitle2+'%' and Product.Title like '%'+@HubSlugTitle5+'%' and @HubSlugTitle5<>''
							  end
			else
						  select @HubCount1=count(*) from Product where freetext(Product.Title,@HubSlugTitle1)  and Product.Title like '%'+@HubSlugTitle2+'%' and @HubSlugTitle3 is null
			if @HubCount1>0
							begin
								INSERT INTO HubMapperSummary
								(HubId,ICID,ICTitle,HubTitle,ICMRP,HubMRP,ICStrength,ICPack,MatchCount,[Status])
								select @HubId,Product.Id,Product.Title,@HubTitle,MRP,@HubMRP,MasterStrength.title,MasterPack.Title,@HubCount1,1  from Product 
								left join MasterPack on Product.MasterPackId=MasterPack.Id
								left join MasterStrength on product.MasterStrengthID=MasterStrength.Id
								where freetext(Product.Title,@HubSlugTitle1)  and Product.Title like '%'+@HubSlugTitle2+'%' and @HubSlugTitle3 is null
							end
			else 
								
					begin
							INSERT INTO HubMapperSummary
							(ICTitle,HubTitle,HubSlugTitle1,HubSlugTitle2,HubSlugTitle3,HubSlugTitle4,HubSlugTitle5,HubMRP,ProcessingStatus)
							values( '',@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,@HubMRP,14) 
					end

			end
	
													
 fetch next from curHubClosingStockDump1 into @HubId, @HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,@HubMRP
 end
 CLOSE curHubClosingStockDump1
 DEALLOCATE curHubClosingStockDump1


-- delete from HubMapperSummary
--where HubTitle in (select HubTitle from HubMapperSummary where ProcessingStatus=11)
--and ProcessingStatus=14