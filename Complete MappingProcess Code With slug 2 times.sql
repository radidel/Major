truncate table [HubMapperSummary]
declare @HubCount int,@HubCount1 int,@HubId1 nvarchar(500), @ICTitle varchar(500), @title1 varchar(500),@Id nvarchar(128),@PTitle nvarchar(500),@Title nvarchar(500),@SlugTitle nvarchar(500),@Pack nvarchar(500),
	@MRP decimal(18,2), @Strength nvarchar(500), @Keywords varchar(500),@NumberOfMatchingId int,@Keywords1 varchar(500),@Keywords2 varchar(500),@Quanitity varchar(500)

		DECLARE curHubClosingStockDump CURSOR FOR (
		--select HubId,HubTitle, HubSlugTitle1 as Title,dbo.[RemoveNumericCharacters](HubTitle) as title1, HubMRP as MRP from [One to N hsncodemaster2ndmethod] --where HubSlugTitle2 is not null
		select ICTITLE,case when PATINDEX('% %',ICTITLE)>0 
				then 
				LEFT(ICTITLE,(PATINDEX('% %',ICTITLE)))
				else
				ICTITLE
				end as title,
				 case when len(dbo.[RemoveNumericCharacters](ICTITLE))>0 then dbo.[RemoveNumericCharacters](replace(ICTITLE,'  ',' ')) else 
			dbo.[RemoveNumericCharacters](ICTITLE) end as title1,
				Left(SubString(ICTITLE, PatIndex('%[0-9.-]%', ICTITLE), 50),PatIndex('%[^0-9.-]%', SubString(ICTITLE, PatIndex('%[0-9.-]%', ICTITLE), 50) + 'X')-1) As Quanitity ,ICMRP as MRP 
					from ICMasterTestDataforCleaning where len(dbo.[RemoveNumericCharacters](ICTITLE))>1
				)
			OPEN curHubClosingStockDump
			fetch next from curHubClosingStockDump into  @ICTitle,@Title,@title1,@Quanitity,@MRP
		
			while (@@fetch_status=0)
			 
				begin
					SET @Keywords = '"*'+dbo.RemoveNonAlphaCharacters(@Title)+'*"' 
					SET @Keywords1= '"*'+@title1+'*"'
					SET @Keywords2= '"*'+@Quanitity+'*"'
			
					if len(@Keywords)>5
					begin
					
						select @HubCount=count(1) from Product where Freetext(Title,@Keywords) and Freetext(Title,@Keywords1) and Freetext(Title,@Keywords2)
						
						if @HubCount>0
							begin  
								INSERT INTO HubMapperSummary
								(ICTitle,HubTitle,HubSlugTitle,HubSlugTitle1,ICMRP,HubMRP,HubPack,MatchCount,[Status])
								select product.Title,@ICTitle,@Title,@title1,MRP,@MRP ,@Quanitity,@HubCount,1
								from product 								
								where product.Title in	(select Title from Product where (Freetext(Title,@Keywords) and Freetext(Title,@Keywords1))  )
								and MRP =@MRP and MRP>0 --and (MasterPack.Title=@Pack or MasterStrength.Title=@Strength) 
				
				END			
					   	else
							begin
								INSERT INTO [dbo].[HubMapperSummary]
								(HubId,ICTitle,HubTitle,ICMRP,HubMRP,ICStrength,HubStrength,ICPack,HubPack,MatchCount,[Status])
								values( @HubId1,'',@Title,0,@MRP ,'',@Strength,'',@Pack,@HubCount,2)
							end
				    end
				else
					begin
						INSERT INTO [dbo].[HubMapperSummary]
						(ICTitle,HubTitle,HubSlugTitle,HubSlugTitle1,ICMRP,HubMRP,HubPack,MatchCount,[Status])
						values( '',@ICTitle,@Title,@title1,0,@MRP ,@Quanitity,@HubCount,3)
					end
				
			fetch next from curHubClosingStockDump into @ICTitle,@Title,@title1,@Quanitity, @MRP 
		    end
	      CLOSE curHubClosingStockDump
	  DEALLOCATE curHubClosingStockDump


	-- select ICTitle,HubTitle,row_number()over(partition by Hubtitle order by ICtitle desc) as NUmberOfMatching from HubMapperSummary
	-- where ICTitle <>''

	 	--Ranking the HubId 
				--	declare @Ranking table(HubTitle nvarchar(Max),NumberOfmatching int, ICTitle nvarchar(Max))
				--		insert into @Ranking (ICTitle,HubTitle, NumberOfmatching)
				--		select ICTitle,HubTitle,ROW_NUMBER()Over(partition by HubTitle order by ICTitle ) as NumberOfmatching from HubMapperSummary
				--		update HubMapperSummary 
				--		set NumberOfMatchingId= b.NumberOfmatching
				--		from HubMapperSummary 
				--		inner join @Ranking b on HubMapperSummary.HubTitle=b.HubTitle
				--		where HubMapperSummary.ICTitle=b.ICTitle
			

			--				-------------------------
			--				--For JSON Update
			--					declare @JSON Table (HubId nvarchar(Max),IC_Title nvarchar(Max),Hub_Title Nvarchar(Max),Ic_Marp decimal(18,2),status int)
			--					insert into @JSON(HubId,IC_Title,Hub_Title,Ic_Marp,status)
			--					select HubId,Ictitle,HubTitle,ICMRP,Status from HubmapperSummary where NumberOfMatchingId>1
--			--					select*from @JSON
			--	
			--				UPDATE  dbo.HubMapperSummary 
			--				SET SimilareValues = (SELECT * FROM @JSON b WHERE 
			--					b.HubId = HubMapperSummary.Hubid and HubMapperSummary.NumberOfMatchingId=1 FOR JSON AUTO)
			--				where HubMapperSummary.SimilareValues is null
			--
			--				 
			--	---delete duplicate values 
			--	
			--				delete from dbo.HubMapperSummary
			--				where NumberOfMatchingId>1
			--	
				-------------------------


	--with cte as (select ICTitle,HubTitle,Row_Number()Over(Partition by HubTitle order by ID ) as DuplicateRows from HubMapperSummary where ICTitle<>'')
	--Update HubMapperSummary
	--set NumberOfMatchingId=cte.DuplicateRows
	--from HubMapperSummary
	--inner join cte on HubMapperSummary.ICTitle=cte.ICTitle
	--where HubMapperSummary.HubTitle=cte.HubTitle
	--
	--
	--declare @JSON Table (IC_Title nvarchar(Max),Hub_Title Nvarchar(Max),Ic_Marp decimal(18,2),NumberOfMatchingId int,status int)
	--				insert into @JSON(IC_Title,Hub_Title,Ic_Marp,NumberOfMatchingId,status)
	--				select Ictitle,HubTitle,ICMRP,NumberOfMatchingId,Status from HubmapperSummary where NumberOfMatchingId>1
	--				
	--				UPDATE  dbo.HubMapperSummary 
	--			    SET SimilareValues = (SELECT * FROM @JSON b WHERE b.Hub_Title = HubMapperSummary.HubTitle and HubMapperSummary.NumberOfMatchingId=1 FOR JSON AUTO)
	--			    where HubMapperSummary.SimilareValues is null
	--			delete from dbo.HubMapperSummary
	--			where NumberOfMatchingId>1
	--	select*from HubMapperSUmmary
	--

		
		select*from updatedproduct
		where Ictitle like 'ORS%L%'

		select*from TempHubhsncodemaster
		where [Name] like 'ORS-L%'
		
 select [Name],case when PATINDEX('% %',dbo.RemoveSpecialCharacters([Name]))>0 
				then 
				LEFT(dbo.RemoveSpecialCharacters([Name]),(PATINDEX('% %',dbo.RemoveSpecialCharacters([Name]))))
				else
				dbo.RemoveSpecialCharacters([Name])
				end as title,
				 db_owner.GetStringPartByDelimeter([Name], ' ', 2) as Title1,
				Left(SubString([Name], PatIndex('%[0-9.-]%', [Name]), 50),PatIndex('%[^0-9.-]%', SubString([Name], PatIndex('%[0-9.-]%', [Name]), 50) + 'X')-1) As Quanitity ,[M#R#P#] as MRP 
					from TempHubhsncodemaster where [Name]<>'' and [Name] like 'ORS-L%'








