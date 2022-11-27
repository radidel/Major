
drop table tempHubDumpData

select * into tempHubDumpData from HubMapperSummary
where ICTitle=''

delete from HubMapperSummary
where ICTitle=''


declare  @Hubtitle nvarchar(500),@HubSlugTitle nvarchar(500),@HubSlugtitle1 nvarchar(500),@HubSlugNumber nvarchar(500),@HubMRP decimal(18,2),
@Keywords nvarchar(500), @Keywords1 nvarchar(500), @Keywords2 nvarchar(500),@ICKeywords nvarchar(500),@ICKeywords2 nvarchar(500),@HubCount int,
@Ictitle2 nvarchar(500),@Hubtitle2 nvarchar(500),@HubSlugTitle2 nvarchar(500),@HubSlugTitle23 nvarchar(500),@ICMRP2 decimal(18,2),@HubMRP2 decimal(18,2),@NumberOfMatching int,
 @Keywords3 nvarchar(500),@Keywords4 nvarchar(500),@Keywords5 nvarchar(500),@HubSlugTitle3 nvarchar(500),@HubSlugTitle4 nvarchar(500),@HubSlugTitle5 nvarchar(500),
 @HubCount1 int,@HubCount2 int,@HubCount3 int, @HubCount4 int,@HubCount5 int




--For hub data
DECLARE curHubClosingStockDump1 CURSOR FOR ( 
											select HubTitle,  db_owner.GetStringPartByDelimeter(HubTitle, ' ', 1) as title,
		
    	case when len(db_owner.GetStringPartByDelimeter(HubTitle, ' ', 2))>0 then db_owner.GetStringPartByDelimeter(HubTitle, ' ', 2) else db_owner.GetStringPartByDelimeter(HubTitle, ' ',3) end as Title1,

		case when len(db_owner.GetStringPartByDelimeter(HubTitle, ' ', 3))>0 then db_owner.GetStringPartByDelimeter(HubTitle, ' ', 3) else db_owner.GetStringPartByDelimeter(HubTitle, ' ', 4) end AS title3,

		case when len(db_owner.GetStringPartByDelimeter(HubTitle, ' ', 4))>0 then db_owner.GetStringPartByDelimeter(HubTitle, ' ', 4) else db_owner.GetStringPartByDelimeter(HubTitle, ' ', 5) end as title4,

        Left(SubString(HubTitle, PatIndex('%[0-9.-]%', HubTitle), 50),PatIndex('%[^0-9.-]%', SubString(HubTitle, PatIndex('%[0-9.-]%', HubTitle), 50) + 'X')-1) as title5,HubMRP as MRP 
			from tempHubDumpData	
		
		)
	OPEN curHubClosingStockDump1 
	fetch next from curHubClosingStockDump1 into  @HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,@HubMRP
	
	while (@@fetch_status=0)	
								 
							begin
								SET @Keywords1 = '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle1)+'*"'
								SET @Keywords2= '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle2)+'*"'
								SET @Keywords3= '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle3)+'*"'
								SET @Keywords4= '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle4)+'*"'
								SET @Keywords5= '"*'+dbo.RemoveSpecialCharacters(@HubSlugTitle5)+'*"'
								
								begin
								
								
					if len(@HubSlugTitle1)<8
								
								

								
								select @HubCount1= count(*) from UpdatedProduct where ICTitle like ''+@HubSlugTitle1+' %' and ICTitle like '%'+@HubSlugTitle2+' %' and ICTitle like '% '+@HubSlugTitle3+' %'
								if @HubCount1>0
										begin
											INSERT INTO HubMapperSummary
											(ICTitle,HubTitle,HubSlugTitle1,HubSlugTitle2,HubSlugTitle3,HubSlugTitle4,HubSlugTitle5,ICMRP,HubMRP,ProcessingStatus)
											select ICTitle,@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,MRP,@HubMRP,20 from UpdatedProduct 
											where ICTitle like ''+@HubSlugTitle1+' %' and ICTitle like '%'+@HubSlugTitle2+' %' and ICTitle like '% '+@HubSlugTitle3+' %'
										end
								
								else
								select @HubCount2= count(*) from UpdatedProduct where ICTitle like ''+@HubSlugTitle1+'%' and ICTitle like '%'+@HubSlugTitle2+' %' and ICTitle like '% '+@HubSlugTitle3+' %'
								if @HubCount2>0
										begin
											INSERT INTO HubMapperSummary
											(ICTitle,HubTitle,HubSlugTitle1,HubSlugTitle2,HubSlugTitle3,HubSlugTitle4,HubSlugTitle5,ICMRP,HubMRP,ProcessingStatus)
											select ICTitle,@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,MRP,@HubMRP,21 from UpdatedProduct 
											where ICTitle like ''+@HubSlugTitle1+'%' and ICTitle like '%'+@HubSlugTitle2+' %' and ICTitle like '% '+@HubSlugTitle3+' %' 
										end
								else
								select @HubCount3= count(*) from UpdatedProduct where ICTitle like ''+@HubSlugTitle1+'%'  and (@HubSlugTitle3 is  null or @HubSlugTitle3='') and len(@HubSlugTitle)>10
								if @HubCount3>0
									 begin
												INSERT INTO HubMapperSummary
												(ICTitle,HubTitle,HubSlugTitle1,HubSlugTitle2,HubSlugTitle3,HubSlugTitle4,HubSlugTitle5,ICMRP,HubMRP,ProcessingStatus)
												select ICTitle,@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,MRP,@HubMRP,22 from UpdatedProduct 
												where ICTitle like ''+@HubSlugTitle1+'%' and len(@HubSlugTitle2)<2 and (@HubSlugTitle3 is null or @HubSlugTitle3='') and len(@HubSlugTitle)>10
									 end
								 else
										begin

											INSERT INTO HubMapperSummary
											(ICTitle,HubTitle,HubSlugTitle1,HubSlugTitle2,HubSlugTitle3,HubSlugTitle4,HubSlugTitle5,HubMRP,ProcessingStatus)
											values( '',@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,@HubMRP,23)
										end

					--			if @Keywords1 is not null and @Keywords2 is not null and @Keywords3 is not null and @Keywords4 is not null and @Keywords5 is not null  
					--			--5th char same
					--			begin
					--
					--			select @HubCount1=count(*) from UpdatedProduct  where ICTitle like '%'+@Keywords1+'%' 
					--			and ICTitle like '%'+@Keywords2+'%'  and ICTitle like '%'+@Keywords3+'%'  and ICtitle like '%'+@Keywords4+'%' and ICtitle like '%'+@Keywords5+'%'	
					--			if @HubCount1>0
					--		
					--			begin
					--					INSERT INTO HubMapperSummary
					--					(ICTitle,HubTitle,HubSlugTitle1,HubSlugTitle2,HubSlugTitle3,HubSlugTitle4,HubSlugTitle5,ICMRP,HubMRP,ProcessingStatus)
					--					select ICTitle,@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,MRP,@HubMRP,9 from UpdatedProduct 	
					--					where  ICTitle like '%'+@Keywords1+'%' 
					--			and ICTitle like '%'+@Keywords2+'%' and ICTitle like '%'+@Keywords3+'%' and ICtitle like '%'+@Keywords4+'%' and ICtitle like '%'+@Keywords5+'%'	
					--			end
					--			
					--			--4th char same
					--			else
					--			if @Keywords1 is not null and @Keywords2 is not null and @Keywords3 is not null and @Keywords4 is not null  
					--
					--			begin
					--				select @HubCount2=count(*) from UpdatedProduct  where  ICTitle like '%'+@Keywords1+'%' 
					--			and ICTitle like '%'+@Keywords2+'%' and ICTitle like '%'+@Keywords3+'%' and ICtitle like '%'+@Keywords4+'%'	 
					--			
					--			if @HubCount2>0
					--			begin
					--					INSERT INTO HubMapperSummary
					--					(ICTitle,HubTitle,HubSlugTitle1,HubSlugTitle2,HubSlugTitle3,HubSlugTitle4,HubSlugTitle5,ICMRP,HubMRP,ProcessingStatus)
					--					select ICTitle,@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,MRP,@HubMRP,11 from UpdatedProduct 	
					--					where  ICTitle like '%'+@Keywords1+'%' 
					--			and ICTitle like '%'+@Keywords2+'%' and ICTitle like '%'+@Keywords3+'%' and ICtitle like '%'+@Keywords4+'%'
					--			end
					--			
					--			--3rd char same
					--			else
					--
					--			if @Keywords1 is not null and @Keywords2 is not null and @Keywords3 is not null
					--			begin
					--					select @HubCount3=count(*) from UpdatedProduct  where  ICTitle like '%'+@Keywords1+'%' 
					--			and ICTitle like '%'+@Keywords2+'%' and ICTitle like '%'+@Keywords3+'%'
					--				if @HubCount3>0
					--				begin
					--					INSERT INTO HubMapperSummary
					--					(ICTitle,HubTitle,HubSlugTitle1,HubSlugTitle2,HubSlugTitle3,HubSlugTitle4,HubSlugTitle5,ICMRP,HubMRP,ProcessingStatus)
					--					select ICTitle,@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,MRP,@HubMRP,13 from UpdatedProduct 	
					--					where   ICTitle like '%'+@Keywords1+'%' 
					--			and ICTitle like '%'+@Keywords2+'%' and ICTitle like '%'+@Keywords3+'%'
					--				end
					--				
					--			--2nd char same
					--				else
					--				if @Keywords1 is not null and @Keywords2 is not null 
					--						begin
					--						select @HubCount4=count(*) from UpdatedProduct  where ICTitle like '%'+@Keywords1+'%' 
					--			and ICTitle like '%'+@Keywords2+'%' 
					--					if @HubCount4>0
					--						begin
					--							INSERT INTO HubMapperSummary
					--							(ICTitle,HubTitle,HubSlugTitle1,HubSlugTitle2,HubSlugTitle3,HubSlugTitle4,HubSlugTitle5,ICMRP,HubMRP,ProcessingStatus)
					--							select ICTitle,@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,MRP,@HubMRP,15 from UpdatedProduct 	
					--							where ICTitle like '%'+@Keywords1+'%' 
					--			and ICTitle like '%'+@Keywords2+'%' 
					--						end
					--						
					--			--select @HubCount4=count(*) from UpdatedProduct
					--
					--			else 
					--				begin
					--					select @HubCount4=count(*) from UpdatedProduct  where ICTitle like '%'+@Keywords1+'%' 
					--	
					--							
					--				if @HubCount4>0
					--					begin
					--						INSERT INTO HubMapperSummary
					--						(ICTitle,HubTitle,HubSlugTitle1,HubSlugTitle2,HubSlugTitle3,HubSlugTitle4,HubSlugTitle5,ICMRP,HubMRP,ProcessingStatus)
					--						select ICTitle,@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,MRP,@HubMRP,17 from UpdatedProduct 	
					--						where ICTitle like '%'+@Keywords1+'%' 
					--					
					--					end
					--
					--					end
					--					end
					--			
					--
					--			
					--			
					--		end
					--else
					--		
					--				begin
					--						INSERT INTO HubMapperSummary
					--						(ICTitle,HubTitle,HubSlugTitle1,HubSlugTitle2,HubSlugTitle3,HubSlugTitle4,HubSlugTitle5,HubMRP,ProcessingStatus)
					--						values( '',@HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,@HubMRP,19)
					--				end
					--				end
					--	end
					--		end
					--		
					end
 fetch next from curHubClosingStockDump1 into  @HubTitle,@HubSlugTitle1,@HubSlugTitle2,@HubSlugTitle3,@HubSlugTitle4,@HubSlugTitle5,@HubMRP
 end
 CLOSE curHubClosingStockDump1
 DEALLOCATE curHubClosingStockDump1
 

delete from HubMapperSummary
where HubTitle in (select HubTitle from HubMapperSummary where ICTitle<>'')
and ProcessingStatus=23


