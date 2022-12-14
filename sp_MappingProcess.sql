USE [indiachemist_demo_indianchemist]
GO
/****** Object:  StoredProcedure [dbo].[SpMapHubUploadData]    Script Date: 09-03-2021 11:48:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SpMapHubUploadData](                     
	@AspNetUserId nvarchar(128) ,    
	@HubId nvarchar(128) ,               
	@HubClosingStockDump nvarchar(128) ,   
	@IP varchar(20),                
	-----------------------------------                
	@Message nvarchar(500) output ,                
	@Mapped int output ,    
	@UnMapped int output ,   
	@Hidden int output ,     
	@result int output                  
)                    
AS                     
/****** Object:  StoredProcedure [SpMapHubUploadData]     Script Date: 05/30/2019 05:11:00 PM ******/                    
begin                    
	begin transaction     
	BEGIN TRY                 
		--Declare @TempTable table  
		--(  
		-- [Id] int identity(1,1),  
		-- [ProductId] nvarchar(128),  
		-- [Title] nvarchar(max),  
		-- [MRP] decimal(18,2) null,  
		-- [PACK] nvarchar(max),  
		-- [STRENGTH] nvarchar(max)  
		--);  
		--with cteProduct as(  
		-- select Id,SlugTitle as Title,  
		-- MasterPackId,MasterStrengthId,MRP from Product  
		--),  
		--cteMasterPack as(  
		-- select Id,Title from MasterPack  
		--),  
		--cteMasterStrength as(  
		-- select Id,Title from MasterStrength  
		--)  
		--insert into @TempTable([ProductId],[Title],[MRP],[PACK],[STRENGTH])  
		--select a.Id,a.Title,a.MRP,b.Title Pack,c.Title Strength  
		--from cteProduct a  
		--left join cteMasterPack b  
		--on a.MasterPackId=b.Id  
		--left join cteMasterStrength c  
		--on a.MasterStrengthId=c.Id  
    
		declare @HubCount int, @Id nvarchar(128),@PTitle nvarchar(500),@Title nvarchar(500),@Pack nvarchar(500),
		@MRP decimal(18,2),@Strength nvarchar(500)  ,  @Keywords varchar(500)
   
		DECLARE curHubClosingStockDump CURSOR FOR (  
			select   Id,Title   ,Pack ,sum(Quantity),Strength,MRP from HubClosingStockDump  
			group by 
		)  
		OPEN curHubClosingStockDump  
		fetch next from curHubClosingStockDump into @Id, @Title,@Pack ,@Strength,@MRP  
		while (@@fetch_status=0)  
		begin   
			/*SET @Keywords = '"*'+dbo.SlugProductTitle(dbo.RemoveNonAlphaCharacters(dbo.RemoveSpecialCharacters(@Title)))+'*"' 			
			select @HubCount=count(1)   from Product where freetext(Title,@Keywords) 		
			if 	  @HubCount>0
			begin
				INSERT INTO [dbo].[HubMapperSummary]  
				(ICTitle,HubTitle,ICMRP,HubMRP,ICStrength,HubStrength,ICPack,HubPack,MatchCount,[Status])  
				select Title,@Title,MRP,@MRP  ,'',@Strength,'',@Pack,@HubCount,0			
				from Product where freetext(Title,@Keywords)  
			end
			else
			begin*/  
			SET @Keywords = '"*'+dbo.SlugProductTitle(dbo.RemoveNonAlphaCharacters(@Title))+'*"'  
			if len(@Keywords)>1
			begin
					select @HubCount=count(1)   from Product where contains(Title,@Keywords) 	
					if @HubCount>0
					begin
						INSERT INTO [dbo].[HubMapperSummary]  
						(ICTitle,HubTitle,ICMRP,HubMRP,ICStrength,HubStrength,ICPack,HubPack,MatchCount,[Status])  
						select Title,@Title,MRP,@MRP  ,'',@Strength,'',@Pack,@HubCount,1			
						from Product where contains(Title,@Keywords)   
					end 
					else
					begin
						INSERT INTO [dbo].[HubMapperSummary]  
						(ICTitle,HubTitle,ICMRP,HubMRP,ICStrength,HubStrength,ICPack,HubPack,MatchCount,[Status])  
						values( '',@Title,0,@MRP  ,'',@Strength,'',@Pack,@HubCount,2)			
					end  
				end
				else
				begin
					INSERT INTO [dbo].[HubMapperSummary]  
					(ICTitle,HubTitle,ICMRP,HubMRP,ICStrength,HubStrength,ICPack,HubPack,MatchCount,[Status])  
					values( '',@Title,0,@MRP  ,'',@Strength,'',@Pack,@HubCount,2)	 
				end 
			
			fetch next from curHubClosingStockDump into   @Id, @Title,@Pack ,@Strength,@MRP   
			end  
			CLOSE curHubClosingStockDump  
			DEALLOCATE curHubClosingStockDump  
			set @Message ='Success'                
			set @Mapped =100    
			set @UnMapped =20   
			set @Hidden =20   
			set @result=1                
		commit transaction                  
	END TRY                  
	BEGIN CATCH    
		CLOSE curHubClosingStockDump  
		DEALLOCATE curHubClosingStockDump  
		set @Mapped =0    
		set @UnMapped =0   
		set @Hidden =0   
		set @result=-1              
     
		print ERROR_NUMBER()    
		print ERROR_SEVERITY()    
		print ERROR_STATE()    
		print ERROR_PROCEDURE()   
		print ERROR_LINE()   
		print ERROR_MESSAGE()                  
		rollback transaction                  
	END CATCH                  
	return --return from procedure successfully                   
end 