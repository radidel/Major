truncate table [HubMapperSummary]
begin
declare  @HubSlugNumber nvarchar(500),
@Keywords1 nvarchar(500), @Keywords2 nvarchar(500), @Keywords3 nvarchar(500),@Keywords4 nvarchar(500),@Keywords5 nvarchar(500),@HubCount int,

@HubTitle nvarchar(500),@HubSlugTitle1 nvarchar(500),@HubSlugTitle2 nvarchar(500),@HubSlugTitle3 nvarchar(500),@HubSlugTitle4 nvarchar(500),@HubSlugTitle5 nvarchar(500),@HubMRP decimal(18,2)
	
--For hub data
DECLARE curHubClosingStockDump CURSOR FOR ( 
											select Item_Name,  db_owner.GetStringPartByDelimeter(Item_Name, ' ', 1) as title,
		
	db_owner.GetStringPartByDelimeter(Item_Name, ' ', 2) as Title1,

		case when len(db_owner.GetStringPartByDelimeter(Item_Name, ' ', 3))>0 then db_owner.GetStringPartByDelimeter(Item_Name, ' ', 3) else db_owner.GetStringPartByDelimeter(Item_Name, ' ', 4) end AS title3,

		db_owner.GetStringPartByDelimeter(Item_Name, ' ', 4) as title4,

       db_owner.GetStringPartByDelimeter(Item_Name, ' ', 5) as title5,MRP as MRP 
			from [KESHAV MEDICOS HUB]		
		)
				OPEN curHubClosingStockDump 
				fetch next from curHubClosingStockDump into  @HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,@HubMRP
	while (@@fetch_status=0)	
			begin
			SET @Keywords1 = '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle1)+'*"'
			SET @Keywords2= '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle2)+'*"'
			SET @Keywords3= '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle3)+'*"'
			SET @Keywords4= '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle4)+'*"'
			SET @Keywords5= '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle5)+'*"'

			
			begin
								select case when freetext(ICTitle,@Keywords1) then ICTitle else @Keywords1 end from UpdatedProduct
								
			end
			
			end
			
	fetch next from curHubClosingStockDump into @HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,@HubMRP
 
 CLOSE curHubClosingStockDump
 DEALLOCATE curHubClosingStockDump
 end
 
 
	





--DECLARE curHubClosingStockDump1 CURSOR FOR ( select Item_Name,  case when PATINDEX('% %',Item_Name)>0 
--		then 
--		LEFT(Item_Name,(PATINDEX('% %',Item_Name)))
--		else
--		db_owner.GetStringPartByDelimeter(LTRIM(Item_Name), ' ',1)
--		end as title,
--		
--		case when len(db_owner.GetStringPartByDelimeter(Item_Name, ' ', 2))>0
--		then 
--		db_owner.GetStringPartByDelimeter(Item_Name, ' ', 2)
--		else
--		'a'
--		end  as Title1,
--
--		Left(SubString(Item_Name, PatIndex('%[0-9.-]%', Item_Name), 50),PatIndex('%[^0-9.-]%', SubString(Item_Name, PatIndex('%[0-9.-]%', Item_Name), 50) + 'X')-1) As Quanitity ,MRP as MRP 
--			from [KESHAV MEDICOS HUB] where Item_Name like 'EXEVATE%' and Item_Name<>'' AND case when PATINDEX('% %',Item_Name)>0 
--		then 
--		LEFT(Item_Name,(PATINDEX('% %',Item_Name)))
--		else
--		db_owner.GetStringPartByDelimeter(LTRIM(Item_Name), ' ',1)
--		end IS NOT NULL AND case when PATINDEX('% %',Item_Name)>0 
--		then 
--		LEFT(Item_Name,(PATINDEX('% %',Item_Name)))
--		else
--		db_owner.GetStringPartByDelimeter(LTRIM(Item_Name), ' ',1)
--		end <>''
--		
--		)
--	OPEN curHubClosingStockDump1 
--	fetch next from curHubClosingStockDump1 into  @Hubtitle,@HubSlugTitle,@HubSlugtitle1,@HubSlugNumber,@HubMRP
--	
--	while (@@fetch_status=0)	
--								 
--							begin
--								SET @Keywords = '"*'+dbo.RemoveNonAlphaCharacters(@HubSlugTitle)+'*"'
--								SET @Keywords1= '"*'+dbo.RemoveSpecialCharacters(@HubSlugtitle1)+'*"'
--								SET @Keywords2= '"*'+@HubSlugNumber+'*"'
--								--SET @ICKeywords= '"*'+@Title+'*"'
--								--SET @ICKeywords2= '"*'+@title1+'*"'
--								
--								begin
--								select @HubCount=count(*) from UpdatedProduct where ICTitle like 'EXEVATE%' and Freetext((ICTitle,SlugTitle),@HubSlugTitle) and  (Freetext((ICTitle,SlugTitle1),@HubSlugtitle1) or COALESCE(MRP,0)=@HubMRP )
--								
--
--								if @HubCount>0
--									begin
--										INSERT INTO @TempTable
--										(ICTitle,HubTitle,HubSlugTitle,HubSlugTitle1,ICMRP,HubMRP,[Status])
--										select ICTitle,@Hubtitle,@HubSlugTitle,@HubSlugtitle1,MRP,@HubMRP,1 from UpdatedProduct 	
--										where Freetext((ICTitle,SlugTitle),@HubSlugTitle)  and  (Freetext((ICTitle,SlugTitle1),@HubSlugtitle1) or COALESCE(MRP,0)=@HubMRP )
--										order by ICTitle
--										
--								
--									end
--								else
--									begin
--										INSERT INTO @TempTable
--										(ICTitle,HubTitle,HubSlugTitle,HubSlugTitle1,HubMRP,[Status])
--										values( '',@Hubtitle,@HubSlugTitle,@HubSlugtitle1,@HubMRP ,2)
--									end
--								end
--						
--
-- fetch next from curHubClosingStockDump1 into @Hubtitle,@HubSlugTitle,@HubSlugtitle1,@HubSlugNumber,@HubMRP
-- end
-- CLOSE curHubClosingStockDump1
-- DEALLOCATE curHubClosingStockDump1
--
-- DECLARE curHubClosingStockDump1 CURSOR FOR ( 
--			
--			select HubTitle,HubSlugTitle,HubSlugTitle1,HubMRP from @TempTable where ICTitle ='')
-- 
-- 	OPEN curHubClosingStockDump1 
--	fetch next from curHubClosingStockDump1 into  @Hubtitle,@HubSlugTitle,@HubSlugtitle1,@HubSlugNumber,@HubMRP
--	
--
-- end
-- 
--select*from HubMapperSummary
--
--