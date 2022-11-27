truncate table [HubMapperSummary]
	declare @HubCount int,@HubId1 nvarchar(500), @Id nvarchar(128),@PTitle nvarchar(500),@Title nvarchar(500),@SlugTitle nvarchar(500),@Pack nvarchar(500),
	@MRP decimal(18,2), @Strength nvarchar(500), @Keywords varchar(500),@NumberOfMatchingId int

		DECLARE curHubClosingStockDump CURSOR FOR (
		select Id, Title ,SlugTitle,MRP from HubClosingStockDump
		)
			OPEN curHubClosingStockDump
			fetch next from curHubClosingStockDump into  @HubId1,@Title,@SlugTitle,@MRP
			while (@@fetch_status=0)
			begin
				SET @Keywords = '"*' +dbo.SlugProductTitle(dbo.RemoveNonAlphaCharacters(@Title))+ '*"'
				if len(@Keywords)>5
					begin
						select @HubCount=count(1) from Product where Freetext(Title,@Keywords) 
						if @HubCount>0
							begin  
								INSERT INTO HubMapperSummary
								(HubId,ICTitle,HubTitle,ICMRP,HubMRP,ICStrength,HubStrength,ICPack,HubPack,MatchCount,[Status])
								select @HubId1,product.Title,@Title,MRP,@MRP ,MasterStrength.title,@Strength,MasterPack.Title,@Pack,@HubCount,1
								from product 
								left join MasterPack on Product.MasterPackId=MasterPack.Id
								left join MasterStrength on product.MasterStrengthID=MasterStrength.Id
								where product.Title in	(select Title from Product where Freetext(Title,@Keywords)  )
								and MRP =@MRP and MRP>0 --and (MasterPack.Title=@Pack or MasterStrength.Title=@Strength) 

------------------------------------------------------------------
			--				--Ranking the HubId 
			--				declare @Ranking table(Hubid nvarchar(Max),Numberofmatchingid int, ICTitle nvarchar(Max))
			--					insert into @Ranking (Hubid,ICTitle, Numberofmatchingid)
			--					select Hubid,ICTitle,ROW_NUMBER()Over(partition by Hubid order by hubtitle) as NumberOfmatchingid from HubMapperSummary
			--					update HubMapperSummary 
			--					set NumberOfMatchingId= b.Numberofmatchingid
			--					from HubMapperSummary 
			--					inner join @Ranking b on HubMapperSummary.Hubid=b.Hubid
			--					where HubMapperSummary.ICTitle=b.ICTitle
			--
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

	
------------------------------------------------------------------------
------------------------------------------------------------------------



								------------
							end
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
						(HubId,ICTitle,HubTitle,ICMRP,HubMRP,ICStrength,HubStrength,ICPack,HubPack,MatchCount,[Status])
						values( @HubId1,'',@Title,0,@MRP ,'',@Strength,'',@Pack,@HubCount,3)
					end
			fetch next from curHubClosingStockDump into @HubId1,@Title,@SlugTitle,@MRP 
		    end
	      CLOSE curHubClosingStockDump
	  DEALLOCATE curHubClosingStockDump



